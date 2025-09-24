import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _customerController = TextEditingController();
  final _totalController = TextEditingController();

  Future<void> _addOrder() async {
    if (_customerController.text.isEmpty || _totalController.text.isEmpty)
      return;
    await FirebaseFirestore.instance.collection("orders").add({
      "customer": _customerController.text,
      "total": double.tryParse(_totalController.text) ?? 0,
      "createdAt": Timestamp.now(),
    });
    _customerController.clear();
    _totalController.clear();
  }

  Future<void> _editOrder(
      String id, String oldCustomer, double oldTotal) async {
    _customerController.text = oldCustomer;
    _totalController.text = oldTotal.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _customerController,
                decoration: const InputDecoration(labelText: "Customer")),
            TextField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: "Total")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("orders")
                  .doc(id)
                  .update({
                "customer": _customerController.text,
                "total": double.tryParse(_totalController.text) ?? 0,
              });
              _customerController.clear();
              _totalController.clear();
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
            .collection("orders")
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
              final order = docs[i];
              return ListTile(
                title: Text("Khách: ${order["customer"]}"),
                subtitle: Text("💲 Tổng: ${order["total"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _editOrder(
                        order.id,
                        order["customer"],
                        (order["total"] as num).toDouble(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance
                          .collection("orders")
                          .doc(order.id)
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
              title: const Text("Add Order"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: _customerController,
                      decoration: const InputDecoration(labelText: "Customer")),
                  TextField(
                      controller: _totalController,
                      decoration: const InputDecoration(labelText: "Total")),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      _addOrder();
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
