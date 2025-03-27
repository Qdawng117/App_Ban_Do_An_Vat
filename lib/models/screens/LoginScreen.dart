import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'RegisterScreen.dart';
import 'package:demoflutter_221402/models/MyCrypto.dart';
import 'package:demoflutter_221402/models/User.dart';
import 'package:demoflutter_221402/models/widgets/Layout.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Trangthai_LoginScreen();
}

class Trangthai_LoginScreen extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late Future<List<User>> lstusers;

  @override
  void initState() {
    super.initState();
    lstusers = LayDsUsertuBackend();
  }

  Future<List<User>> LayDsUsertuBackend() async {
    final response = await http
        .get(Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/users'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => User.fromJsonMocki(item)).toList();
    } else {
      throw Exception('Không đọc được danh sách người dùng từ backend');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

 void Dangnhap() async {
  String email = emailController.text.trim();
  String password = MyCrypto.hashText(passwordController.text.trim());

  if (email.isEmpty || password.isEmpty) {
    showError("Vui lòng nhập đầy đủ thông tin đăng nhập");
    return;
  }

  try {
    List<User> users = await lstusers;
    User? foundUser = users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => User(email: "", password: ""),
    );

    if (foundUser.username.isNotEmpty) {
      // Kiểm tra nếu là admin thì hiển thị menu quản lý
      if (foundUser.role == "admin") {
        print("Người dùng là Admin - Hiển thị menu quản lý");
      } else {
        print("Người dùng không phải Admin");
      }

      // Chuyển đến Layout và truyền User
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Layout(user: foundUser),
        ),
      );
    } else {
      showError("Email hoặc mật khẩu không chính xác");
    }
  } catch (e) {
    showError("Lỗi kết nối đến máy chủ. Vui lòng thử lại sau");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hình tròn avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhQ7hNowuI_O5fumoG__SkVnF7C_cWECAc1A&s",
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Ô nhập email
                    TextField(
                      controller: emailController,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Email đăng nhập',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Ô nhập mật khẩu
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nút đăng nhập
                    ElevatedButton(
                      onPressed: Dangnhap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Đăng ký tài khoản
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Chưa có tài khoản? Đăng ký ngay!',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
