import 'package:demoflutter_221402/models/User.dart';
import 'package:demoflutter_221402/models/screens/OderHistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:demoflutter_221402/models/ListProducts_Admin.dart';
import 'package:demoflutter_221402/models/products/ListProductsAPI.dart';
import 'package:demoflutter_221402/models/screens/CartScreen.dart';
import 'package:demoflutter_221402/models/screens/ProfileScreen.dart';
import 'package:demoflutter_221402/models/ListCategories_Admin.dart';



class Layout extends StatefulWidget {
  final User user;
  Layout({required this.user});
  

  @override
  State<StatefulWidget> createState() {
    return _LayoutState();
  }
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ListProductsAPI(),
      OrderHistoryScreen(userEmail: widget.user.email),
      CartScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];
  }

  final List<String> _carouselImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhQ7hNowuI_O5fumoG__SkVnF7C_cWECAc1A&s',
    'https://suckhoedoisong.qltns.mediacdn.vn/zoom/600_315/Images/phamhiep/2016/08/09/4-ly-do-tot-de-nen-an-mon-trang-mieng-moi-ngay1470699093.jpg',
    'https://viendinhduong.vn/FileUpload/Images/thucannhanh.jpg',
    'https://static.wixstatic.com/media/e55ac8_fb8a498ae9164fd2b37649b298b83285~mv2.png/v1/fill/w_564,h_846,al_c,q_90/e55ac8_fb8a498ae9164fd2b37649b298b83285~mv2.png'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_selectedIndex == 0) _buildCarousel(),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  //  Thanh AppBar có điều kiện ẩn menu quản lý nếu không phải admin
PreferredSizeWidget _buildAppBar() {
  return AppBar(
    elevation: 0,
    toolbarHeight: 55,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.redAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    title: Text(
      "ĐỒ ĂN VẶT 3 ANH EM",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
        color: Colors.yellowAccent,
        shadows: [
          Shadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.5),
            offset: Offset(2, 2),
          )
        ],
      ),
    ),
    centerTitle: true,
    actions: [
      // Chỉ hiển thị menu nếu là admin
      if (widget.user.role == "admin") 
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'products') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListProducts_Admin()),
              );
            } else if (value == 'categories') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListCategoriesAdmin()),
              );
            }
          },
          icon: Icon(Icons.menu, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'products', child: Text('Quản lý sản phẩm')),
            PopupMenuItem(value: 'categories', child: Text('Quản lý danh mục')),
          ],
        ),
    ],
  );
}


  //  Banner (Carousel)
  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CarouselSlider(
        items: _carouselImages.map((imageUrl) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 3)),
                ],
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.85,
                height: 150,
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          enlargeCenterPage: true,
          viewportFraction: 0.8,
        ),
      ),
    );
  }

  //  BottomNavigationBar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history, size: 30), label: 'Lịch Sử'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 30), label: 'Giỏ Hàng'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Tài Khoản'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepOrangeAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 5,
          iconSize: 28,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
