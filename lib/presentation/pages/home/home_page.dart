import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Tổng quan doanh thu'),
            subtitle: Text('Doanh thu hôm nay, tuần, tháng'),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Sản phẩm'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/products'),
            ),
          ),
        ],
      ),
    );
  }
}
