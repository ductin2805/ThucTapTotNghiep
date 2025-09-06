import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dao/category_dao.dart';
import '../data/models/category.dart';

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  return CategoryDao().getAll();
});
