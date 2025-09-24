import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _addCustomer() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection("customers").add({
      "name": _nameController.text,
      "phone": _phoneController.text,
      "createdAt": Timestamp.now(),
    });
    _nameController.clear();
    _phoneController.clear();
  }

  Future<void> _editCustomer(String id, String oldName, String oldPhone) async {
    _nameController.text = oldName;
    _phoneController.text = oldPhone;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Customer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("customers")
                  .doc(id)
                  .update({
                "name": _nameController.text,
                "phone": _phoneController.text,
              });
              _nameController.clear();
              _phoneController.clear();
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
            .collection("customers")
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
              final customer = docs[i];
              return ListTile(
                title: Text(customer["name"]),
                subtitle: Text("📞 ${customer["phone"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _editCustomer(
                        customer.id,
                        customer["name"],
                        customer["phone"],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance
                          .collection("customers")
                          .doc(customer.id)
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
              title: const Text("Add Customer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name")),
                  TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: "Phone")),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      _addCustomer();
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
