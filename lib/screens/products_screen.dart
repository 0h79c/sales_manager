import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection("products").add({
      "name": _nameController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
      "createdAt": Timestamp.now(),
    });
    _nameController.clear();
    _priceController.clear();
  }

  Future<void> _editProduct(String id, String oldName, double oldPrice) async {
    _nameController.text = oldName;
    _priceController.text = oldPrice.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("products")
                  .doc(id)
                  .update({
                "name": _nameController.text,
                "price": double.tryParse(_priceController.text) ?? 0,
              });
              _nameController.clear();
              _priceController.clear();
              Navigator.pop(ctx);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final product = docs[i];
              return ListTile(
                title: Text(product["name"]),
                subtitle: Text("💲 ${product["price"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _editProduct(product.id, product["name"],
                          (product["price"] as num).toDouble()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance
                          .collection("products")
                          .doc(product.id)
                          .delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Add Product"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name")),
                  TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Price")),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      _addProduct();
                      Navigator.pop(ctx);
                    },
                    child: const Text("Save")),
              ],
            ),
          );
        },
      ),
    );
  }
}
