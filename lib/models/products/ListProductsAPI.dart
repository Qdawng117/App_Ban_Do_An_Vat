import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Product.dart';
import 'ProductDetailsAPI.dart';
import '../cart/Cart.dart'; 

class ListProductsAPI extends StatefulWidget {
  const ListProductsAPI({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ListProductsAPIState();
  }
}

class _ListProductsAPIState extends State<ListProductsAPI> {
  late Future<List<Product>> lstproducts;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "Tất cả";

  final List<Map<String, dynamic>> categories = [
    {"name": "Tất cả", "icon": Icons.apps},
    {"name": "Trà sữa", "icon": Icons.local_cafe},
    {"name": "Thức ăn nhanh", "icon": Icons.fastfood},
    {"name": "Ăn vặt", "icon": Icons.cake},
    {"name": "Bún/Phở/Mì/Cháo", "icon": Icons.ramen_dining},
    {"name": "Hải sản", "icon": Icons.set_meal},
    {"name": "Tráng miệng", "icon": Icons.icecream},
    {"name": "Pizza", "icon": Icons.local_pizza}
  ];

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
        Uri.parse('https://67b6da3a2bddacfb270c890a.mockapi.io/products'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Product> products =
          jsonData.map((item) => Product.fromJsonMocki(item)).toList();
      return products;
    } else {
      throw Exception('Không đọc được sản phẩm từ backend');
    }
  }

  @override
  void initState() {
    super.initState();
    lstproducts = fetchProducts();
    lstproducts.then((products) {
      setState(() {
        allProducts = products;
        filteredProducts = allProducts;
      });
    });
    searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredProducts = allProducts.where((product) {
        bool matchesSearch = product.title!.toLowerCase().contains(query);
        bool matchesCategory =
            selectedCategory == "Tất cả" || product.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }
final Map<String, String> categoryMapping = {
  "Tất cả": "All",
  "Trà sữa": "Milk Tea",
  "Thức ăn nhanh": "Fast Food",
  "Ăn vặt": "Snacks",
  "Bún/Phở/Mì/Cháo": "Noodles & Soups",
  "Hải sản": "Seafood",
  "Tráng miệng": "Desserts",
  "Pizza": "Pizza",
};

void _filterByCategory(String category) {
  setState(() {
    selectedCategory = category;
    String apiCategory = categoryMapping[category] ?? "All";

    filteredProducts = (apiCategory == "All")
        ? allProducts
        : allProducts.where((product) => product.category == apiCategory).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
              // Danh mục sản phẩm (Category)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String categoryName = categories[index]["name"];
                    IconData categoryIcon = categories[index]["icon"];

                    return GestureDetector(
                      onTap: () => _filterByCategory(categoryName),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selectedCategory == categoryName
                              ? Colors.blue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(categoryIcon,
                                color: selectedCategory == categoryName
                                    ? Colors.white
                                    : Colors.blue),
                            const SizedBox(height: 5),
                            Text(categoryName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedCategory == categoryName
                                        ? Colors.white
                                        : Colors.blue,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

          // Danh sách sản phẩm
          Expanded(
            child: FutureBuilder(
              future: lstproducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text("Đợi xíu nha người đẹp!"));
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        Product product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsAPI(
                                  product: product,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 6.0,
                            shadowColor: Colors.black54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20.0)),
                                    child: Image.network(
                                      product.image ?? "",
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Column(
                                    children: [
                                      Text(
                                        product.title ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "\$ ${(product.price ?? 0).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(20)),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 28),
                                    onPressed: () {
                                      Cart.addToCart(product);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "${product.title} đã được thêm vào giỏ hàng!"),
                                          duration: const Duration(seconds: 0, milliseconds: 500),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
