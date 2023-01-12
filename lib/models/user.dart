class User {
  int id;
  String username;
  String firstName;
  String lastName;
  int? code;
  String apiKey;
  DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.apiKey,
    required this.lastLogin,
  });

  User.fromDb(Map<String, dynamic> record)
      : id = record['id'],
        username = record['username'],
        firstName = record['first_name'],
        lastName = record['last_name'],
        code = record['code'],
        apiKey = record['api_key'],
        lastLogin = DateTime.parse(record['last_login']);

  Map<String, dynamic> toDb() {
    return {
      'username': username,
      'code': code,
      'api_key': apiKey,
      'last_login': lastLogin.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'code': code,
      'api_key': apiKey,
      'last_login': lastLogin.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  static User anonymous() {
    return User(
      id: -1,
      username: 'anonymous',
      firstName: 'Anonymous',
      lastName: 'Anonymous',
      code: null,
      apiKey: '',
      lastLogin: DateTime.now(),
    );
  }

  fullName() {
    return firstName.isNotEmpty && lastName.isNotEmpty ? '$firstName $lastName' : username;
  }
}
