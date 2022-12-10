class User {
  int id;
  String username;
  int? code;
  String apiKey;
  DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.code,
    required this.apiKey,
    required this.lastLogin,
  });

  User.fromDb(Map<String, dynamic> record)
      : id = record['id'],
        username = record['username'],
        code = record['code'],
        apiKey = record['api_key'],
        lastLogin = DateTime.parse(record['last_login']);

  Map<String, dynamic> toDb() {
    return {
      'username': username,
      'code': code,
      'api_key': apiKey,
      'last_login': lastLogin.toIso8601String(),
    };
  }
}
