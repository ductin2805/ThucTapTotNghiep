import 'package:flutter/material.dart';
import '../../../data/models/category.dart';

class ProductFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedFilter; // expects 'all' or categoryId.toString()
  final List<Category> categories;
  final ValueChanged<String> onFilterChanged;
  final bool isGrid;
  final ValueChanged<bool> onToggle;

  const ProductFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.categories,
    required this.onFilterChanged,
    required this.isGrid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // build items and ensure uniqueness by id
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];

    // always add the "all" option first
    items.add(const DropdownMenuItem(
      value: 'all',
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Tất cả mặt hàng'),
        ),
      ),
    ));

    for (final c in categories) {
      final id = c.id?.toString();
      if (id == null || id.isEmpty) continue;
      if (seen.contains(id)) continue; // skip duplicates
      seen.add(id);
      items.add(DropdownMenuItem(
        value: id,
        child: SizedBox(
          height: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(c.name),
          ),
        ),
      ));
    }

    // make sure selectedFilter exists in items; if not fallback to 'all'
    final allowedValues = items.map((e) => e.value).toSet();
    final safeSelected = allowedValues.contains(selectedFilter) ? selectedFilter : 'all';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Tìm kiếm mặt hàng",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: safeSelected,
                  isExpanded: true,
                  items: items,
                  onChanged: (v) => onFilterChanged(v ?? 'all'),
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.view_list_outlined),
                color: !isGrid ? Colors.blue : Colors.grey,
                onPressed: () => onToggle(false),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view),
                color: isGrid ? Colors.blue : Colors.grey,
                onPressed: () => onToggle(true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
