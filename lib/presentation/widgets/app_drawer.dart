import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🚧 Tính năng đang phát triển"),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context); // đóng Drawer sau khi chọn
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrangeAccent),
            child: Center(
              child: Text(
                "EasySale",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Mua gói"),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text("Đánh giá ứng dụng"),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Chia sẻ cho bạn bè"),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text("Đóng góp ý kiến"),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text("Báo lỗi"),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Trợ giúp"),
            onTap: () => _showComingSoon(context),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Phiên bản 2.2.0"),
          )
        ],
      ),
    );
  }
}
