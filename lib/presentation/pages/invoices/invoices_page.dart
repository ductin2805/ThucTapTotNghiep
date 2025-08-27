import 'package:flutter/material.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: mở drawer hoặc menu
          },
        ),
        title: const Text(
          "Hóa đơn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: mở chức năng tìm kiếm
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: mở chức năng lọc
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh lọc
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Text("Tất cả : ",
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
                Text("Hôm nay",
                    style: TextStyle(fontSize: 16, color: Colors.orange)),
                Spacer(),
                Icon(Icons.filter_alt_outlined, color: Colors.black54),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // Nội dung rỗng
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.insert_drive_file_outlined,
                      size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Hôm nay bạn chưa có hóa đơn nào",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
