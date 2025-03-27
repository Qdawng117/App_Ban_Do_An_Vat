import 'package:flutter/material.dart';
import 'package:demoflutter_221402/models/User.dart';
import 'package:demoflutter_221402/models/screens/EditProfileScreen.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user; // Lưu user hiện tại
  }

  //  Điều hướng đến EditProfileScreen và nhận dữ liệu mới
  void navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: currentUser),
      ),
    );

    if (updatedUser != null && updatedUser is User) {
      setState(() {
        currentUser = updatedUser; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa hàng ngang
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 18),
            const Text(" Thông Tin Cá Nhân",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(), 
            _buildUserInfo(), 
            _buildActionButtons(), 
          ],
        ),
      ),
    );
  }

  //  Phần tiêu đề + Avatar
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                currentUser.avatar.isNotEmpty
                    ? currentUser.avatar
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            currentUser.username,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            currentUser.email,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

//  Phần thông tin người dùng
Widget _buildUserInfo() {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          _buildInfoRow(Icons.person, "Vai trò", 
            currentUser.role == "admin" ? "Quản trị viên" : "Người dùng"),
          Divider(),
          _buildInfoRow(Icons.phone, "Số điện thoại", currentUser.phone.toString()),
          Divider(),
          _buildInfoRow(Icons.home, "Địa chỉ", currentUser.address),
        ],
      ),
    ),
  );
}


  //  Row hiển thị từng thông tin
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Text(
          "$title:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  //  Nút "Chỉnh sửa" & "Đăng xuất"
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: navigateToEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Đăng xuất', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
