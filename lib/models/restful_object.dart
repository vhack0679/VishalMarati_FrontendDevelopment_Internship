class RestfulObject {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  RestfulObject({
    required this.id,
    required this.name,
    this.data,
  });

  factory RestfulObject.fromJson(Map<String, dynamic> json) {
    return RestfulObject(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
    };
    if (data != null) {
      map['data'] = data;
    }
    return map;
  }

  // Helper to create a copy with updated fields
  RestfulObject copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? data,
  }) {
    return RestfulObject(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
    );
  }
}
