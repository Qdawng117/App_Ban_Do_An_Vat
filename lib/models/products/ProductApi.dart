import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductApi {
  final String? id;
  final String? title;
  final String? image;
  final double? price;
  final String? category;

  ProductApi({
    this.id,
    this.title,
    this.image,
    this.price,
    this.category,
  });

  // Chuyển đổi từ JSON
  factory ProductApi.fromJson(Map<String, dynamic> json) {
    return ProductApi(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'],
    );
  }

  // Gọi API để lấy danh sách sản phẩm
  static Future<List<ProductApi>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/products'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => ProductApi.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách sản phẩm từ API');
    }
  }
}
