import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_memory_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductMemoryDataSource ds;
  ProductRepositoryImpl(this.ds);

  @override
  Future<void> create(Product p) async => ds.add(p);

  @override
  Future<void> delete(String id) async => ds.remove(id);

  @override
  Future<List<Product>> fetchAll() async => ds.getAll();

  @override
  Future<void> update(Product p) async {
    await delete(p.id);
    await create(p);
  }
}
