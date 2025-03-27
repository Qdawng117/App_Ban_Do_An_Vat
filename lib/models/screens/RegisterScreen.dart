import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'LoginScreen.dart';
import 'package:demoflutter_221402/models/MyCrypto.dart';
import 'package:flutter/services.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';
  String address = '';
  String avatarUrl = ''; 
  String errorMessage = '';

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final checkResponse = await http.get(
        Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/users?email=$email'),
      );

      print("Response check email: ${checkResponse.body}");

      try {
        final List<dynamic> users = jsonDecode(checkResponse.body);
        if (users.isNotEmpty) {
          setState(() {
            errorMessage = 'Email đã tồn tại! Vui lòng chọn email khác.';
          });
          return;
        }
      } catch (e) {
        print("Lỗi khi parse JSON: $e");
      }

      final response = await http.post(
        Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': MyCrypto.hashText(password),
          'phone': phone,
          'address': address,
          'avatar': avatarUrl.isEmpty ? "" : avatarUrl,
        }),
      );

      print("Response register: ${response.body}");

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        setState(() {
          errorMessage = 'Đăng ký thất bại: ${response.statusCode}. Vui lòng thử lại!';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Lỗi kết nối: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD), 
      appBar: AppBar(
        title: Text('Đăng ký tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF42A5F5), 
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF42A5F5), width: 3),
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
                    avatarUrl.isEmpty
                        ? "https://i.imgur.com/BoN9kdC.png"
                        : avatarUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),

              //  Hiển thị lỗi nếu có
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField('Avatar (URL)', Icons.image, (value) {
                          setState(() {
                            avatarUrl = value;
                          });
                        }),
                        buildTextField('Tên đăng nhập', Icons.person, (value) {
                          setState(() => username = value);
                        }, validator: (value) {
                          return value!.isEmpty ? 'Tên đăng nhập không được để trống' : null;
                        }),
                        buildTextField('Email', Icons.email, (value) {
                          setState(() => email = value);
                        }, validator: (value) {
                          if (value!.isEmpty) return 'Email không được để trống';
                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                            return 'Hãy nhập email hợp lệ';
                          }
                          return null;
                        }),
                        buildTextField('Mật khẩu', Icons.lock, (value) {
                          setState(() => password = value);
                        }, obscureText: true, validator: (value) {
                          if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
                          return null;
                        }),

                        buildTextField('Nhập lại mật khẩu', Icons.lock, (value) {
                          setState(() => confirmPassword = value);
                        }, obscureText: true, validator: (value) {
                          if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                          if (value != password) return 'Mật khẩu không trùng khớp';
                          return null;
                        }),
                        buildTextField(
                          'Số điện thoại',
                          Icons.phone,
                          (value) {
                            setState(() => phone = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Số điện thoại không được để trống';
                            if (!RegExp(r"^0\d{9}$").hasMatch(value)) return 'Số điện thoại không hợp lệ';
                            return null;
                          },
                          keyboardType: TextInputType.number, 
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                        ),
                        buildTextField('Địa chỉ', Icons.location_on, (value) {
                          setState(() => address = value);
                        }),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            backgroundColor: Color(0xFF42A5F5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: register,
                          child: Text('Đăng ký', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Widget tạo các ô nhập liệu đẹp hơn
  Widget buildTextField(String label, IconData icon, Function(String) onChanged,
      {bool obscureText = false, String? Function(String?)? validator,  TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF42A5F5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType, 
        inputFormatters: inputFormatters, 
        onChanged: onChanged,
      ),
    );
  }
}
