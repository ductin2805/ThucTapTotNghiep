import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dao/unit_dao.dart';
import '../data/models/unit.dart';

final unitListProvider = FutureProvider<List<Unit>>((ref) async {
  return UnitDao().getAll();
});
