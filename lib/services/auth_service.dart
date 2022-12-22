import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;
import 'package:digicode/models/user.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AuthService extends ChangeNotifier {
  Future<Database>? _db;
  Map config = {};

  AuthService() {
    _initConfig();
  }

  Future<void> _initConfig() async {
    rootBundle.loadString("assets/api.yaml").then((yamlString) {
      config = loadYaml(yamlString);
    });
  }

  static Future<Map<String, String>> buildHeaders() async {
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('token');
    final apiKey = prefs.getString('apiKey');

    if (apiKey != null) {
      headers['Authorization'] = 'Api-Key $apiKey';
    } else if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<Database>? getDb() {
    _db ??= _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "auth.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            code INTEGER NOT NULL,
            api_key TEXT NOT NULL,
            last_login DATETIME
          )
          ''');
      },
    );
  }

  Future<User?> getUser() async {
    final db = await getDb();
    var res = await db!.rawQuery("SELECT * FROM user ORDER BY id DESC");
    if (res.isNotEmpty) {
      var user = User.fromDb(res.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiKey', user.apiKey);
      return user;
    }
    return null;
  }

  clearSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  connect(email, password, code) async {
    clearSharedPrefs();
    final db = await getDb();
    var response = await http.post(
      Uri.parse(join(config['base_url'], config['get-jwt-token'])),
      headers: await buildHeaders(),
      body: jsonEncode(
        {
          'username': email,
          'password': password,
        },
      ),
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      final token = json['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      response = await http.get(
        Uri.parse(join(config['base_url'], config['get-api-key'])),
        headers: await buildHeaders(),
      );
      json = jsonDecode(response.body);

      final user = User(
        id: 0,
        username: email,
        code: int.parse(code),
        apiKey: json['apiKey'],
        lastLogin: DateTime.now(),
      );
      await db!.insert(
        "user",
        user.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw Exception(response.reasonPhrase);
    }
    notifyListeners();
  }

  disconnect() async {
    clearSharedPrefs();
    final db = await getDb();
    getUser().then((user) async {
      var response = await http.post(
        Uri.parse(join(config['base_url'], config['revoke-api-key'])),
        headers: await buildHeaders(),
      );
      await db!.delete("user");
      if (response.statusCode != 200) {
        throw Exception(response.reasonPhrase);
      }
      notifyListeners();
    });
  }
}
