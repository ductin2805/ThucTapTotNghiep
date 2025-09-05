import 'package:flutter/material.dart';
import '../../../data/dao/unit_dao.dart';
import '../../../data/models/unit.dart';
import 'unit_form_page.dart';

class UnitListPage extends StatefulWidget {
  const UnitListPage({super.key});

  @override
  State<UnitListPage> createState() => _UnitListPageState();
}

class _UnitListPageState extends State<UnitListPage> {
  final UnitDao dao = UnitDao();
  List<Unit> units = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final data = await dao.getAll();
    setState(() => units = data);
  }

  void _deleteUnit(Unit unit) async {
    await dao.delete(unit.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = units.where((u) {
      final q = query.toLowerCase();
      return u.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn vị"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitFormPage()),
              );
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Nhập tên đơn vị",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => query = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final u = filtered[i];
                return ListTile(
                  title: Text(u.name),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UnitFormPage(unit: u),
                      ),
                    );
                    _load();
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UnitFormPage(unit: u),
                            ),
                          );
                          _load();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUnit(u),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
