class TransaksiModel {
  final int? noTiket;
  final String? jamMasuk;
  final String? jamKeluar;
  final int? totalHarga;
  final int? bruto;
  final int? tara;
  final int? netto;
  final int? nettoSetelahPotongan;
  final String? platMobil;
  final String? namaSupir;
  final int? supplierId;
  final int? customerId;
  final int? barangId;
  final String? noDo;
  final String? noContainer;
  final int? suhu;
  final int? hargaPerKg;
  final String? keterangan;
  final bool parafSupir;
  final bool parafOperator;
  final bool parafManager;
  final bool parafKepalaGudang;
  final String? createdAt;
  final String? updatedAt;

  TransaksiModel({
    this.noTiket,
    this.jamMasuk,
    this.jamKeluar,
    this.totalHarga,
    this.bruto,
    this.tara,
    this.netto,
    this.nettoSetelahPotongan,
    this.platMobil,
    this.namaSupir,
    this.supplierId,
    this.customerId,
    this.barangId,
    this.noDo,
    this.noContainer,
    this.suhu,
    this.hargaPerKg,
    this.keterangan,
    this.parafSupir = false,
    this.parafOperator = false,
    this.parafManager = false,
    this.parafKepalaGudang = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) => TransaksiModel(
    noTiket: json['no_tiket'],
    jamMasuk: json['jam_masuk'],
    jamKeluar: json['jam_keluar'],
    totalHarga: json['total_harga'],
    bruto: json['bruto'],
    tara: json['tara'],
    netto: json['netto'],
    nettoSetelahPotongan: json['netto_setelah_potongan'],
    platMobil: json['plat_mobil'],
    namaSupir: json['nama_supir'],
    supplierId: json['supplier_id'],
    customerId: json['customer_id'],
    barangId: json['barang_id'],
    noDo: json['no_do'],
    noContainer: json['no_container'],
    suhu: json['suhu'],
    hargaPerKg: json['harga_per_kg'],
    keterangan: json['keterangan'],
    parafSupir: (json['paraf_supir'] ?? 0) == 1,
    parafOperator: (json['paraf_operator'] ?? 0) == 1,
    parafManager: (json['paraf_manager'] ?? 0) == 1,
    parafKepalaGudang: (json['paraf_kepala_gudang'] ?? 0) == 1,
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'no_tiket': noTiket,
    'jam_masuk': jamMasuk,
    'jam_keluar': jamKeluar,
    'total_harga': totalHarga,
    'bruto': bruto,
    'tara': tara,
    'netto': netto,
    'netto_setelah_potongan': nettoSetelahPotongan,
    'plat_mobil': platMobil,
    'nama_supir': namaSupir,
    'supplier_id': supplierId,
    'customer_id': customerId,
    'barang_id': barangId,
    'no_do': noDo,
    'no_container': noContainer,
    'suhu': suhu,
    'harga_per_kg': hargaPerKg,
    'keterangan': keterangan,
    'paraf_supir': parafSupir ? 1 : 0,
    'paraf_operator': parafOperator ? 1 : 0,
    'paraf_manager': parafManager ? 1 : 0,
    'paraf_kepala_gudang': parafKepalaGudang ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
