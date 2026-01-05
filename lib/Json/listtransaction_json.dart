// get from https://app.quicktype.io/
import 'dart:convert';

ListTransactionJson ListTransactionJsonFromJson(String str) =>
    ListTransactionJson.fromJson(json.decode(str));

String ListTransactionJsonToJson(ListTransactionJson data) =>
    json.encode(data.toJson());

class ListTransactionJson {
  final int transactionID;
  final String noPO;
  final String namaBarang;
  final String namaCustomer;
  final String noKendaraan;
  final String namaSupir;

  ListTransactionJson({
    this.transactionID = 0,
    required this.noPO,
    required this.namaBarang,
    required this.namaCustomer,
    required this.noKendaraan,
    required this.namaSupir,
  });

  factory ListTransactionJson.fromJson(Map<String, dynamic> json) =>
      ListTransactionJson(
        transactionID: json["customerID"],
        noPO: json["customerName"],
        namaBarang: json["customerAddress"],
        namaCustomer: json["customerCity"],
        noKendaraan: json["customerPhone"],
        namaSupir: json["customerFax"],
      );

  Map<String, dynamic> toJson() => {
    // "customerID": customerID,
    "customerName": noPO,
    "customerAddress": namaBarang,
    "customerCity": namaCustomer,
    "customerPhone": noKendaraan,
    "customerFax": namaSupir,
  };
}
