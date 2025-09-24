import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;
  final Map<String, dynamic>? oldData;

  const CustomerFormScreen({super.key, this.customerId, this.oldData});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.oldData != null) {
      _nameCtrl.text = widget.oldData!["name"];
      _emailCtrl.text = widget.oldData!["email"];
      _phoneCtrl.text = widget.oldData!["phone"];
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customers = FirebaseFirestore.instance.collection("customers");

    final newData = {
      "name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "updatedAt": DateTime.now(),
    };

    if (widget.customerId == null) {
      await customers.add(newData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã thêm khách hàng")),
      );
    } else {
      await customers.doc(widget.customerId).update(newData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✏️ Đã cập nhật khách hàng")),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customerId != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? "✏️ Sửa khách hàng" : "➕ Thêm khách hàng")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên khách hàng"),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Không được để trống" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _saveCustomer,
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
