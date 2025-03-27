import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demoflutter_221402/models/User.dart';
import 'ProfileScreen.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController avatarController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    avatarController = TextEditingController(text: widget.user.avatar);
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone.toString());
    addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    avatarController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  //  Hàm cập nhật thông tin user lên MockAPI
  Future<void> updateUser() async {
 final url = Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/users/${widget.user.id}');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "avatar": avatarController.text,
        "username": usernameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "address": addressController.text,
      }),
    );

    if (response.statusCode == 200) {
      // ✅ Cập nhật thành công -> Quay lại ProfileScreen
      User updatedUser = User(
        id: widget.user.id,
        avatar: avatarController.text,
        username: usernameController.text,
        email: emailController.text,
        password: widget.user.password, // Giữ nguyên mật khẩu
        phone: int.tryParse(phoneController.text) ?? 0,
        address: addressController.text,
      );

Navigator.pop(context, updatedUser);
    } else {
      //  Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thất bại, vui lòng thử lại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa thông tin"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 🖼 Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                avatarController.text.isNotEmpty
                    ? avatarController.text
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: avatarController,
              decoration: InputDecoration(labelText: "Link Avatar", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Tên người dùng", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),

            //  Nút "Lưu thay đổi"
            ElevatedButton(
              onPressed: updateUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 45)),
              child: Text("Lưu thay đổi", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
