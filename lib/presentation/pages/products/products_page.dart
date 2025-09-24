import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm')),
      body: const _ProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList();
  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng ListView.builder từ provider
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.local_offer),
          title: Text('Ví dụ sản phẩm A'),
          subtitle: Text('SL: 10 | Giá: 100.000đ'),
        ),
      ],
    );
  }
}
