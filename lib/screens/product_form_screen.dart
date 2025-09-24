import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? oldData;

  const ProductFormScreen({super.key, this.productId, this.oldData});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.oldData != null) {
      _nameCtrl.text = widget.oldData!["name"];
      _priceCtrl.text = widget.oldData!["price"].toString();
      _qtyCtrl.text = widget.oldData!["quantity"].toString();
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final products = FirebaseFirestore.instance.collection("products");

    final newData = {
      "name": _nameCtrl.text.trim(),
      "price": int.tryParse(_priceCtrl.text.trim()) ?? 0,
      "quantity": int.tryParse(_qtyCtrl.text.trim()) ?? 0,
      "updatedAt": DateTime.now(),
    };

    if (widget.productId == null) {
      // thêm mới
      await products.add(newData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã thêm sản phẩm")),
      );
    } else {
      // cập nhật
      await products.doc(widget.productId).update(newData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✏️ Đã cập nhật sản phẩm")),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? "✏️ Sửa sản phẩm" : "➕ Thêm sản phẩm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên sản phẩm"),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Không được để trống" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Giá bán"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Số lượng"),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? "Cập nhật" : "Lưu"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
