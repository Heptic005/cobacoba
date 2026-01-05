// get from https://app.quicktype.io/
import 'dart:convert';

ListTransactionJson ListTransactionJsonFromJson(String str) =>
    ListTransactionJson.fromJson(json.decode(str));

String ListTransactionJsonToJson(ListTransactionJson data) =>
    json.encode(data.toJson());

class ListTransactionJson {
  final int idTransaksi;
  final String platMobil;
  final String namaSupir;
  final String namaSupplier;
  final String namaCustomer;
  final String namaBarang;
  final int potongan;
  final int? kubikasi;
  final String? noDO;
  final int? noContainer;
  final double? suhu;
  final double? harga;
  final String? keterangan;
  final String noTiket;
  final DateTime jamMasuk;
  final DateTime jamKeluar;
  final double totalHarga;
  final double bruto;
  final double tare;
  final double netto;
  final double nettoSetelahPotongan;
  final String label;

  ListTransactionJson({
    required this.platMobil,
    required this.namaSupir,
    required this.namaSupplier,
    required this.namaCustomer,
    required this.namaBarang,
    required this.potongan,
    this.kubikasi,
    this.noDO,
    this.noContainer,
    this.suhu,
    this.harga,
    this.keterangan,
    required this.noTiket,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.totalHarga,
    required this.bruto,
    required this.tare,
    required this.netto,
    required this.nettoSetelahPotongan,
    required this.label,
    this.idTransaksi = 0,
  });

  factory ListTransactionJson.fromJson(Map<String, dynamic> json) =>
      ListTransactionJson(
        platMobil: json['platMobil'],
        namaSupir: json['namaSupir'],
        namaSupplier: json['namaSupplier'],
        namaCustomer: json['namaCustomer'],
        namaBarang: json['namaBarang'],
        potongan: json['potongan'],
        noTiket: json['noTiket'],
        jamMasuk: json['jamMasuk'],
        jamKeluar: json['jamKeluar'],
        totalHarga: json['totalHarga'],
        bruto: json['bruto'],
        tare: json['tare'],
        netto: json['netto'],
        nettoSetelahPotongan: json['nettoSetelahPotongan'],
        label: json['label'],
        idTransaksi: json['idTransaksi'],
      );

  Map<String, dynamic> toJson() => {
    "platMobil": platMobil,
    "namaSupir": namaSupir,
    "namaSupplier": namaSupplier,
    "namaCustomer": namaCustomer,
    "namaBarang": namaBarang,
    "potongan": potongan,
    "noTiket": noTiket,
    "jamMasuk": jamMasuk,
    "jamKeluar": jamKeluar,
    "totalHarga": totalHarga,
    "bruto": bruto,
    "tare": tare,
    "netto": netto,
    "nettoSetelahPotongan": nettoSetelahPotongan,
    "label": label,
    // "idTransaksi": idTransaksi,
  };
}
