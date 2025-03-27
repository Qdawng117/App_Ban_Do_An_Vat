class User {
  int id;
  String username;
  String email;
  String password;
  String avatar;
  int phone;
  String address;
  String role; 

  User({
    this.id = 0,
    required this.email,
    this.username = "",
    required this.password,
    this.avatar = "",
    this.phone = 0,
    this.address = "",
    this.role = "user", 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      avatar: json['avatar'] ?? "",
      phone: int.tryParse(json['phone']?.toString() ?? "0") ?? 0,
      address: json['address'] ?? "",
      role: json['role'] ?? "user", 
    );
  }

  factory User.fromJsonMocki(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      username: json['username'],
      email: json['email'],
      password: json['password'],
      avatar: json['avatar'] ?? "",
      phone: int.tryParse(json['phone']?.toString() ?? "0") ?? 0,
      address: json['address'] ?? "",
      role: json['role'] ?? "user", 
    );
  }

  Map<String, dynamic> toJsonMocki() {
    return {
      'id': id.toString(),
      'username': username,
      'email': email,
      'password': password,
      'avatar': avatar,
      'phone': phone.toString(),
      'address': address,
      'role': role, 
    };
  }

  static List<User> users = [];

  static void addUser(User user) {
    users.add(user);
  }

  static List<User> getUsers() {
    return users;
  }

  static User? authenticate(String username, String password) {
    try {
      return users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
