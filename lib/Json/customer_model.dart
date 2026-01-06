class CustomerModel {
  final int? id;
  final String name;
  final String? alamat;
  final String? noTelp;
  final int? range;
  final String? createdAt;
  final String? updatedAt;

  CustomerModel({
    this.id,
    required this.name,
    this.alamat,
    this.noTelp,
    this.range,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'],
    name: json['name'],
    alamat: json['alamat'],
    noTelp: json['no_telp'],
    range: json['range'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'alamat': alamat,
    'no_telp': noTelp,
    'range': range,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
