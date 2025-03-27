import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category_model.dart';

class ListCategoriesAdmin extends StatefulWidget {
  @override
  _ListCategoriesAdminState createState() => _ListCategoriesAdminState();
}

class _ListCategoriesAdminState extends State<ListCategoriesAdmin> {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  final String apiUrl = "https://67d1856590e0670699ba72f3.mockapi.io/categories";

  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  /// Lấy danh sách danh mục từ API
  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        categories = jsonData.map((data) => Category.fromJson(data)).toList();
        filteredCategories = categories;
      });
    }
  }

  /// Kiểm tra danh mục có tồn tại không
  bool categoryExists(String name) {
    return categories.any((category) => category.name.toLowerCase() == name.toLowerCase());
  }

  /// Thêm danh mục mới
  Future<void> addCategory(Category category) async {
    if (categoryExists(category.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Danh mục đã tồn tại!"), backgroundColor: Colors.red),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": category.name,
        "description": category.description,
        "image": category.image,
      }),
    );

    if (response.statusCode == 201) {
      fetchCategories();
    }
  }

  /// Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse("$apiUrl/${category.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": category.name,
        "description": category.description,
        "image": category.image,
      }),
    );

    if (response.statusCode == 200) {
      fetchCategories();
    }
  }

  /// Xóa danh mục
/// Hiển thị hộp thoại xác nhận xóa danh mục
void confirmDeleteCategory(String id) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa danh mục này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Đóng hộp thoại
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Đóng hộp thoại
              deleteCategory(id); // Gọi hàm xóa danh mục
            },
            child: Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

/// Xóa danh mục
Future<void> deleteCategory(String id) async {
  final response = await http.delete(Uri.parse("$apiUrl/$id"));

  if (response.statusCode == 200) {
    fetchCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Xóa danh mục thành công!"), backgroundColor: Colors.green),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Xóa danh mục thất bại!"), backgroundColor: Colors.red),
    );
  }
}


  /// Tìm kiếm danh mục theo tên
  void searchCategory(String query) {
    setState(() {
      filteredCategories = categories
          .where((category) => category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      currentPage = 1; // Reset về trang đầu tiên khi tìm kiếm
    });
  }

  /// Phân trang danh mục
  List<Category> getPaginatedCategories() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return filteredCategories.sublist(
        startIndex, endIndex > filteredCategories.length ? filteredCategories.length : endIndex);
  }

  /// Tổng số trang
  int get totalPages => (filteredCategories.length / itemsPerPage).ceil();

  /// Chuyển sang trang trước
  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  /// Chuyển sang trang sau
  void nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }


  /// Hiển thị hộp thoại thêm/sửa danh mục
  void showCategoryDialog({Category? category}) {
    final TextEditingController nameController = TextEditingController(text: category?.name ?? "");
    final TextEditingController descriptionController = TextEditingController(text: category?.description ?? "");
    final TextEditingController imageController = TextEditingController(text: category?.image ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(category == null ? "Thêm danh mục" : "Sửa danh mục"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên danh mục")),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Mô tả")),
              TextField(controller: imageController, decoration: InputDecoration(labelText: "URL hình ảnh")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    imageController.text.isNotEmpty) {
                  final newCategory = Category(
                    id: category?.id ?? "",
                    name: nameController.text,
                    description: descriptionController.text,
                    image: imageController.text,
                  );

                  if (category == null) {
                    addCategory(newCategory);
                  } else {
                    updateCategory(newCategory);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(category == null ? "Thêm" : "Lưu"),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  List<Category> paginatedCategories = getPaginatedCategories();

  return Scaffold(
    appBar: AppBar(
      title: const Text("Quản lý danh mục",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blueAccent,
      onPressed: () => showCategoryDialog(),
      child: const Icon(Icons.add, color: Colors.white),
    ),
    body: Column(
      children: [
        // Ô tìm kiếm danh mục
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Tìm kiếm danh mục",
              prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        searchController.clear();
                        searchCategory("");
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: searchCategory,
          ),
        ),

        // Danh sách danh mục dạng GridView
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 cột
                        crossAxisSpacing: 12, // Tăng khoảng cách giữa cột
                        mainAxisSpacing: 12, // Tăng khoảng cách giữa hàng
                        childAspectRatio: 0.9, // Giảm tỉ lệ để ảnh to hơn
                      ),
                      itemCount: paginatedCategories.length,
                      itemBuilder: (context, index) {
                        final category = paginatedCategories[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5, // Làm nổi bật danh mục với bóng đổ
                          shadowColor: Colors.black54,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2, // Tăng tỷ lệ ảnh chiếm nhiều diện tích hơn
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    category.image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover, // Giữ hình ảnh đầy đủ mà không méo
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2, // Giữ nội dung phía dưới nhỏ hơn ảnh
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => showCategoryDialog(category: category),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => confirmDeleteCategory(category.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        // Phân trang
        if (filteredCategories.length > itemsPerPage)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 1 ? previousPage : null,
                  color: currentPage > 1 ? Colors.blue : Colors.grey,
                ),
                Text("Trang $currentPage / $totalPages", style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < totalPages ? nextPage : null,
                  color: currentPage < totalPages ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
}