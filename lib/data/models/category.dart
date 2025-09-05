class Category {
  final int? id;
  final String name;
  final String? description;
  final int? parentId;

  Category({
    this.id,
    required this.name,
    this.description,
    this.parentId,
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      parentId: map['parentId'] as int?,
    );
  }
}
