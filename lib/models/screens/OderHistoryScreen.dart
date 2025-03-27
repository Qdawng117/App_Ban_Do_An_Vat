import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderHistoryScreen extends StatefulWidget {
  final String userEmail;

  const OrderHistoryScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('https://67d1856590e0670699ba72f3.mockapi.io/orders'),
    );

    if (response.statusCode == 200) {
      List<dynamic> allOrders = json.decode(response.body);
      List<dynamic> userOrders = allOrders.where((order) => order['email'] == widget.userEmail).toList();

      setState(() {
        orders = userOrders;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Lỗi khi tải đơn hàng');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 10),
            const Text("Lịch sử đơn hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : orders.isEmpty
            ? SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://vinhweb.com/assets/frontend/img/empty-cart.webp",
                      width: 180,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Bạn chưa có đơn hàng nào!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tổng giá trị đơn hàng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tổng tiền:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent[700]),
                                ),
                                Text(
                                  "${order['total_price']} \$",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Địa chỉ nhận hàng
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    order['address'],
                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // Ngày đặt hàng
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  order['createdAt'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const Divider(height: 18, thickness: 1),

                            // Danh sách sản phẩm trong đơn hàng
                            Column(
                              children: List.generate(order['items'].length, (itemIndex) {
                                var item = order['items'][itemIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      // Ảnh sản phẩm
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item['image'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Thông tin sản phẩm
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              "Số lượng: ${item['quantity']} x ${item['price']} \$",
                                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
