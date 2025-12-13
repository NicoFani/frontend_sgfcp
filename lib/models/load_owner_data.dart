class LoadOwnerData {
  final int id;
  final String name;

  LoadOwnerData({required this.id, required this.name});

  factory LoadOwnerData.fromJson(Map<String, dynamic> json) {
    return LoadOwnerData(id: json['id'] as int, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadOwnerData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
