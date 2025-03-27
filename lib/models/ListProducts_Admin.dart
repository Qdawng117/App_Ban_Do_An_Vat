import 'package:flutter/material.dart';
import 'products/Product.dart';
import 'products/ProductDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/ProductEdit.dart';

class ListProducts_Admin extends StatefulWidget {
  const ListProducts_Admin({super.key});

  @override
  State<StatefulWidget> createState() {
    return TrangthaiListProduct_Admin();
  }
}

class TrangthaiListProduct_Admin extends State<ListProducts_Admin> {
  late Future<List<Product>> lstproducts;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<String> categories = [];

  int currentPage = 0;
  int itemsPerPage = 10;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    lstproducts = LayDssanphamtuBackend();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://67d1856590e0670699ba72f3.mockapi.io/categories'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        categories = jsonData.map((item) => item['name'].toString()).toList();
      });
    }
  }

  Future<List<Product>> LayDssanphamtuBackend() async {
    final response = await http.get(
        Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/products'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Product> products =
          jsonData.map((item) => Product.fromJsonMocki(item)).toList();
      setState(() {
        allProducts = products;
        _applySearchAndPagination();
      });
      return products;
    } else {
      throw Exception('Không đọc được sản phẩm từ backend');
    }
  }

  void _applySearchAndPagination() {
    List<Product> tempList = allProducts
        .where((product) =>
            product.title!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    setState(() {
      filteredProducts = tempList;
    });
  }

  Future<void> SaveProduct(Product p) async {
    if (!categories.contains(p.category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Danh mục không tồn tại!")),
      );
      return;
    }

    if (p.id == null || p.id == 0) {
      final response = await http.post(
        Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(p.toJsonMocki()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          lstproducts = LayDssanphamtuBackend();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm sản phẩm thành công")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi thêm sản phẩm: ${response.statusCode}")),
        );
      }
    }
  }

  void _changePage(int newPage) {
    if (newPage >= 0 && newPage * itemsPerPage < filteredProducts.length) {
      setState(() {
        currentPage = newPage;
      });
    }
  }

  void ConfirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Xóa"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProduct(product);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final response = await http.delete(
      Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/products/${product.id}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        lstproducts = LayDssanphamtuBackend();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa sản phẩm thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa sản phẩm: ${response.statusCode}")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  List<Product> displayedProducts = filteredProducts
      .skip(currentPage * itemsPerPage)
      .take(itemsPerPage)
      .toList();

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "QUẢN TRỊ SẢN PHẨM",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductEdit(
              product: Product(),
              onSave: SaveProduct,
            ),
          ),
        );
      },
      backgroundColor: Colors.deepOrange,
      child: const Icon(Icons.add, color: Colors.white),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Tìm kiếm sản phẩm",
              prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _applySearchAndPagination();
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: lstproducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Không có dữ liệu'),
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: displayedProducts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = displayedProducts[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.image ?? "",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                                  },
                                ),
                              ),
                              title: Text(
                                product.title ?? "Chưa đặt tên",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                "${product.price ?? 0} đ",
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductEdit(
                                            product: product,
                                            onSave: SaveProduct,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      ConfirmDelete(context, product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: currentPage > 0 ? () => _changePage(currentPage - 1) : null,
                          child: const Text("Trang trước"),
                        ),
                        Text("Trang ${currentPage + 1}"),
                        TextButton(
                          onPressed: (currentPage + 1) * itemsPerPage < filteredProducts.length
                              ? () => _changePage(currentPage + 1)
                              : null,
                          child: const Text("Trang sau"),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}
}

