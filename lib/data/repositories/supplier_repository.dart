import '../models/supplier.dart';
import '../dao/supplier_dao.dart';

class SupplierRepository {
  final dao = SupplierDao.instance;

  Future<List<Supplier>> getSuppliers() async {
    return await dao.getAll();
  }

  Future<Supplier?> getSupplier(int id) async {
    return await dao.getById(id);
  }

  Future<int> insertSupplier(Supplier supplier) async {
    return await dao.insert(supplier);
  }

  Future<int> updateSupplier(Supplier supplier) async {
    return await dao.update(supplier);
  }

  Future<int> deleteSupplier(int id) async {
    return await dao.delete(id);
  }
}
