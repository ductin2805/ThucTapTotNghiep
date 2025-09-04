import '../dao/customer_dao.dart';
import '../models/customer.dart';

class CustomerRepository {
  final _dao = CustomerDao();

  Future<int> addCustomer(Customer customer) => _dao.insert(customer);

  Future<List<Customer>> fetchCustomers() => _dao.getAll();

  Future<int> updateCustomer(Customer customer) => _dao.update(customer);

  Future<int> deleteCustomer(int id) => _dao.delete(id);

  /// Hàm này để đảm bảo luôn có 1 khách lẻ trong DB
  Future<Customer> ensureDefaultCustomer() async {
    final customers = await _dao.getAll();

    // Tìm khách lẻ đã tồn tại
    final existing = customers.firstWhere(
          (c) => c.isDefault == true || c.name == "Khách lẻ",
      orElse: () => Customer(
        id: -1,
        name: "",
        phone: "",
        isDefault: false,
      ),
    );

    if (existing.id != -1) {
      return existing; // Nếu đã có thì trả về luôn
    }

    // Nếu chưa có thì thêm mới khách lẻ
    final defaultCustomer = Customer(
      name: "Khách lẻ",
      phone: "",
      address: "",
      email: "",
      isDefault: true,
    );
    final newId = await _dao.insert(defaultCustomer);
    return defaultCustomer.copyWith(id: newId);
  }
}