import 'dart:ui';

import 'package:flutter/material.dart';

class TestFormField extends StatefulWidget {
  const TestFormField({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TrangthaiForm();
  }
}

class TrangthaiForm extends State<TestFormField> {
  final frm1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "NHẬP DỮ LIỆU NGƯỜI DÙNG",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      )),
      body: Form(
          key: frm1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Tên người dùng"),
                  style: const TextStyle(fontSize: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tên người dùng không được để trống";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Số điện thoại"),
                  style: const TextStyle(fontSize: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Số điện thoai không được để trống";
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Số điện thoại không hợp lệ";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  style: const TextStyle(fontSize: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email không được để trống";
                    } else if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Email nhập không hợp lệ';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (frm1.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form Submitted')));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffdfef86),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
                child: Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          )),
    );
  }
}
