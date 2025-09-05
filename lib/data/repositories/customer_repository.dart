import '../dao/customer_dao.dart';
import '../models/customer.dart';

class CustomerRepository {
  final _dao = CustomerDao();

  Future<int> addCustomer(Customer customer) => _dao.insert(customer);

  Future<List<Customer>> fetchCustomers() => _dao.getAll();

  Future<int> updateCustomer(Customer customer) => _dao.update(customer);

  Future<int> deleteCustomer(int id) => _dao.delete(id);
}