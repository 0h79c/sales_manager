import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchAll();
  Future<void> create(Product p);
  Future<void> update(Product p);
  Future<void> delete(String id);
}
