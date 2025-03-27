
import 'dart:convert'; 
import 'package:demoflutter_221402/models/User.dart'; 
import 'package:demoflutter_221402/models/widgets/Layout.dart'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 
import '../cart/Cart.dart'; 
import '../cart/CartItem.dart'; 
import '../products/Product.dart';

// Widget màn hình thanh toán
class CheckoutScreen extends StatefulWidget {
  final User user; // Thông tin user hiện tại

  const CheckoutScreen({required this.user, Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Các controller để quản lý input từ form
  late TextEditingController _nameController;
  late TextEditingController _phoneController; 
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  
  bool _isOrderPlaced = false; // Trạng thái đơn hàng đã đặt hay chưa
  Map<String, dynamic>? _orderDetails; // Chi tiết đơn hàng

  @override
  void initState() {  
    super.initState();
    // Khởi tạo các controller với thông tin user
    _nameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phone.toString());
    _emailController = TextEditingController(text: widget.user.email);
    _addressController = TextEditingController(text: widget.user.address);
  }

  // Hàm xử lý đặt hàng
  Future<void> _processOrder(BuildContext context) async {
    // Kiểm tra form đã điền đầy đủ chưa
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")));
      return;
    }

    // Hiển thị dialog xác nhận
    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    // Tạo danh sách sản phẩm để lưu vào API
    List<Map<String, dynamic>> items = Cart.cartItems.map((item) => {
          "product_id": item.product.id,
          "name": item.product.title,
          "image": item.product.image,
          "quantity": item.quantity,
          "price": item.product.price,
        }).toList();

    double totalPrice = Cart.getTotalPrice(); 

    // Gọi API để tạo đơn hàng
    var response = await http.post(
      Uri.parse("https://67d1856590e0670699ba72f3.mockapi.io/orders"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "customer_name": _nameController.text,
        "phone": _phoneController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "total_price": totalPrice,
        "items": items,
        "createdAt": DateTime.now().toIso8601String(),
      }),
    );

    // Xử lý response từ API
    if (response.statusCode == 201) {
      setState(() {
        _isOrderPlaced = true;
        _orderDetails = {
          "name": _nameController.text,
          "phone": _phoneController.text,
          "email": _emailController.text,
          "address": _addressController.text,
          "total_price": totalPrice,
          "items": items,
        };
        Cart.clearCart(); 
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi đặt hàng, vui lòng thử lại!")));
    }
  }

  // Hiển thị dialog xác nhận đặt hàng
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Xác nhận đơn hàng"),
            content: const Text("Bạn có chắc chắn muốn đặt hàng không?"),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Không")),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Có")),
            ],
          ),
        ) ??
        false;
  }

// Widget build chính của màn hình
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Thanh toán")),
    body: SingleChildScrollView( 
     physics: BouncingScrollPhysics(), 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị màn hình thành công nếu đã đặt hàng
            if (_isOrderPlaced) 
              _buildOrderSuccessScreen()
            else ...[
              // Hiển thị giỏ hàng trống nếu không có sản phẩm
              if (Cart.cartItems.isEmpty) 
                _buildEmptyCart()
              else ...[
                // Hiển thị danh sách sản phẩm và form thanh toán
                _buildOrderItemsList(),
                const SizedBox(height: 20),
                _buildCustomerInfoForm(),
                const SizedBox(height: 20),
                _buildTotalPrice(Cart.getTotalPrice()),
                const SizedBox(height: 20),
                _buildConfirmButton(),
              ]
            ]
          ],
        ),
      ),
    ),
  );
}

  // Widget hiển thị màn hình đặt hàng thành công
  Widget _buildOrderSuccessScreen() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị avatar user
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.user.avatar != null
                    ? NetworkImage(widget.user.avatar!)
                    : const AssetImage("assets/default_avatar.png") as ImageProvider,
              ),
              const SizedBox(height: 10),
              // Hiển thị thông tin đơn hàng
              Text(widget.user.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("📞 ${_orderDetails?['phone']}", style: const TextStyle(fontSize: 16)),
              Text("📧 ${_orderDetails?['email']}", style: const TextStyle(fontSize: 16)),
              Text("🏠 ${_orderDetails?['address']}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              // Hiển thị hình ảnh thành công
              Image.network(
                "https://img.freepik.com/premium-vector/shopping-cart-with-check-mark-wireless-paymant-icon-shopping-bag-seccessful-paymant-sign-online-paymant-level-success-online-shopping-vector_662353-911.jpg",
                width: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50, color: Colors.red);
                },
              ),

              const SizedBox(height: 20),
              const Text(
                "Đặt hàng thành công!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 10),
              const Text("Cảm ơn bạn đã mua hàng. Đơn hàng sẽ được xử lý sớm nhất.", textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _buildOrderItemsList(),
              const SizedBox(height: 20),
              // Nút quay về trang chủ
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Layout(user: widget.user)),
                    (route) => false,
                  );
                },
                child: const Text("Quay về trang chủ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget form thanh toán
  Widget _buildCheckoutForm() {
    if (Cart.cartItems.isEmpty) return _buildEmptyCart();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(child: _buildOrderItemsList()),
          _buildCustomerInfoForm(),
          const SizedBox(height: 20),
          _buildTotalPrice(Cart.getTotalPrice()),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

// Widget nút xác nhận đặt hàng
Widget _buildConfirmButton() {
  return Center(
    child: ElevatedButton(
      onPressed: () => _processOrder(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        "Xác nhận đơn hàng",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}

// Widget form thông tin khách hàng
Widget _buildCustomerInfoForm() {
  return Column(
    children: [
      _buildTextField(_nameController, "Tên khách hàng"),
      _buildTextField(_phoneController, "Số điện thoại"),
      _buildTextField(_addressController, "Địa chỉ"),
    ],
  );
}

// Widget hiển thị giỏ hàng trống
Widget _buildEmptyCart() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/empty_cart.png", width: 200),
        const SizedBox(height: 10),
        const Text("Giỏ hàng trống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// Widget input field
Widget _buildTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );
}

  // Widget hiển thị tổng tiền
  Widget _buildTotalPrice(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Tổng cộng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("\$${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

// Widget hiển thị danh sách sản phẩm đã đặt
Widget _buildOrderItemsList() {
  // Lấy danh sách sản phẩm từ đơn hàng hoặc giỏ hàng
  List<Map<String, dynamic>> items = _orderDetails?['items'] ?? Cart.cartItems.map((item) => {
        "name": item.product.title,
        "image": item.product.image,
        "quantity": item.quantity,
        "price": item.product.price,
      }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("🛒 Sản phẩm đã đặt:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4, 
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ListTile(
              leading: Image.network(
                item["image"],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
              ),
              title: Text(item["name"]),
              subtitle: Text("Số lượng: ${item["quantity"]}"),
              trailing: Text("\$${(item["price"] * item["quantity"]).toStringAsFixed(2)}"),
            );
          },
        ),
      ),
    ],
  );
}

}
