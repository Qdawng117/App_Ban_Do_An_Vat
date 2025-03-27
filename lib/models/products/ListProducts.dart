import 'package:flutter/material.dart';
import 'Product.dart';
import 'ProductDetails.dart';
import '../cart/Cart.dart';

class ListProducts extends StatefulWidget {
  const ListProducts({super.key});

  @override
  State<StatefulWidget> createState() {
    return TrangthaiListProducts();
  }
}

class TrangthaiListProducts extends State<ListProducts> {
  TextEditingController searchController = TextEditingController();
  List<Product> lstproducts = products;

  void filterProducts(String query) {
    List<Product> filteredList = products.where((phantu) {
      return phantu.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    setState(() {
      lstproducts = filteredList;
    });
  }

  void addToCart(Product product) {
    // setState(() {
    //   cartItems.add(product);
    // });

    Cart.addToCart(product);

    // Hiển thị thông báo khi thêm vào giỏ hàng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} đã được thêm vào giỏ hàng!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          onPressed: () {
            // Chuyển hướng đến trang giỏ hàng (nếu có)
          },
        ),
      ),
    );
  }

  @override
  Widget build(Object context) {
    return (Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "DANH SÁCH SẢN PHÂM",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterProducts(value); // Gọi hàm lọc
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: const Color(0xff7f98e7),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số cột
              crossAxisSpacing: 10, // Khoảng cách giữa các cột
              mainAxisSpacing: 10, // Khoảng cách giữa các hàng
              childAspectRatio: 0.7, // Tỷ lệ giữa chiều rộng và chiều cao
            ),
            itemCount: lstproducts.length,
            itemBuilder: (context, index) {
              Product product = lstproducts[index];
              return Card(
                color: const Color(0xfff1cee6),
                child: (Column(children: [
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: GestureDetector(
                            onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetails(product: product),
                                  ),
                                ),
                            child: Image.network(product.image.toString()))),
                  ),
                  ListTile(
                      title: Text(
                        product.title?.isNotEmpty == true
                            ? product.title!
                            : "No Title",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        product.price != null
                            ? "\$${product.price!.toStringAsFixed(2)}"
                            : "\$0.00",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          addToCart(product);
                        },
                      )),
                ])),
              );
            },
          ),
        )));
  }
}
