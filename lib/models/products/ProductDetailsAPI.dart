import 'package:flutter/material.dart';
import 'Product.dart';
import '../cart/Cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailsAPI extends StatefulWidget {
  final Product product;

  const ProductDetailsAPI({Key? key, required this.product}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductDetailsAPIState();
}

class _ProductDetailsAPIState extends State<ProductDetailsAPI> {
  late Product product;
  late Future<List<Product>> relatedProducts;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    relatedProducts = fetchRelatedProducts();
  }

  Future<List<Product>> fetchRelatedProducts() async {
    final response = await http.get(Uri.parse("https://67b6da3a2bddacfb270c890a.mockapi.io/products"));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Product> allProducts = jsonData.map((item) => Product.fromJsonMocki(item)).toList();

      return allProducts
          .where((p) => p.category == product.category && p.id != product.id)
          .toList();
    } else {
      throw Exception('Không thể tải dữ liệu từ máy chủ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? "Không có tiêu đề"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Hero(
              tag: product.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  product.image ?? 'assets/default_image.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/default_image.png',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tên sản phẩm
            Text(
              product.title ?? "Không có tiêu đề",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Giá sản phẩm
            Text(
              product.price != null ? "\$${product.price!.toStringAsFixed(2)}" : "\$0.00",
              style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // Mô tả sản phẩm
            const Text(
              "Mô tả sản phẩm:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              product.description ?? "Không có mô tả cho sản phẩm này.",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // Nút Thêm vào giỏ hàng
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Cart.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.title} đã thêm vào giỏ hàng!')),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tiêu đề sản phẩm liên quan
            const Text(
              "Sản phẩm liên quan:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Danh sách sản phẩm liên quan
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Product>>(
                future: relatedProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có sản phẩm liên quan'));
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Product relatedProduct = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsAPI(product: relatedProduct),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                                  child: Image.network(
                                    relatedProduct.image ?? 'assets/default_image.png',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/default_image.png',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    relatedProduct.title ?? "Không có tiêu đề",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  relatedProduct.price != null
                                      ? "\$${relatedProduct.price!.toStringAsFixed(2)}"
                                      : "\$0.00",
                                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
