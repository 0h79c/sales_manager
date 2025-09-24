import '../../domain/entities/product.dart';

class ProductMemoryDataSource {
  final _items = <Product>[
    const Product(id: '1', name: 'Sản phẩm A', quantity: 10, price: 100000),
  ];

  List<Product> getAll() => List.unmodifiable(_items);
  void add(Product p) => _items.add(p);
  void remove(String id) => _items.removeWhere((e) => e.id == id);
}
