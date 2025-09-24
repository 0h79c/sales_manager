import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFormScreen extends StatefulWidget {
  final String? orderId;
  final Map<String, dynamic>? oldData;

  const OrderFormScreen({super.key, this.orderId, this.oldData});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomer;
  String? _selectedProduct;
  int _quantity = 1;

  Map<String, dynamic>? _customerData;
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    if (widget.oldData != null) {
      _selectedCustomer = widget.oldData!["customerId"];
      _selectedProduct = widget.oldData!["productId"];
      _quantity = widget.oldData!["quantity"];
    }
  }

  Future<void> _saveOrder() async {
    if (_selectedCustomer == null || _selectedProduct == null) return;

    final customers = await FirebaseFirestore.instance
        .collection("customers")
        .doc(_selectedCustomer)
        .get();
    final products = await FirebaseFirestore.instance
        .collection("products")
        .doc(_selectedProduct)
        .get();

    _customerData = customers.data();
    _productData = products.data();

    final orderData = {
      "customerId": _selectedCustomer,
      "customerName": _customerData?["name"] ?? "",
      "productId": _selectedProduct,
      "productName": _productData?["name"] ?? "",
      "price": _productData?["price"] ?? 0,
      "quantity": _quantity,
      "total": (_productData?["price"] ?? 0) * _quantity,
      "createdAt": DateTime.now(),
    };

    final orders = FirebaseFirestore.instance.collection("orders");

    if (widget.orderId == null) {
      await orders.add(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã tạo đơn hàng")),
      );
    } else {
      await orders.doc(widget.orderId).update(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✏️ Đã cập nhật đơn hàng")),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.orderId != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? "✏️ Sửa đơn hàng" : "➕ Tạo đơn hàng")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // chọn khách hàng
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("customers")
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedCustomer,
                    items: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data["name"] ?? ""),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: "Khách hàng"),
                    onChanged: (val) => setState(() => _selectedCustomer = val),
                  );
                },
              ),
              const SizedBox(height: 12),

              // chọn sản phẩm
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    items: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text("${data["name"]} - ${data["price"]}đ"),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: "Sản phẩm"),
                    onChanged: (val) => setState(() => _selectedProduct = val),
                  );
                },
              ),
              const SizedBox(height: 12),

              // số lượng
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: "Số lượng"),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    _quantity = int.tryParse(val) ?? 1;
                  });
                },
              ),

              const Spacer(),
              FilledButton.icon(
                onPressed: _saveOrder,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? "Cập nhật" : "Tạo"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
