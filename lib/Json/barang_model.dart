class BarangModel {
  final int? id;
  final String name;
  final String? kodeBarang;
  final String? createdAt;
  final String? updatedAt;

  BarangModel({
    this.id,
    required this.name,
    this.kodeBarang,
    this.createdAt,
    this.updatedAt,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) => BarangModel(
    id: json['id'],
    name: json['name'],
    kodeBarang: json['kode_barang'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kode_barang': kodeBarang,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
