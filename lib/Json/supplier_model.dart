class SupplierModel {
  final int? id;
  final String name;
  final String? alamat;
  final String? kabupatenKota;
  final String? kecamatan;
  final String? kodePos;
  final String? createdAt;
  final String? updatedAt;

  SupplierModel({
    this.id,
    required this.name,
    this.alamat,
    this.kabupatenKota,
    this.kecamatan,
    this.kodePos,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) => SupplierModel(
    id: json['id'],
    name: json['name'],
    alamat: json['alamat'],
    kabupatenKota: json['kabupaten_kota'],
    kecamatan: json['kecamatan'],
    kodePos: json['kode_pos'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'alamat': alamat,
    'kabupaten_kota': kabupatenKota,
    'kecamatan': kecamatan,
    'kode_pos': kodePos,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
