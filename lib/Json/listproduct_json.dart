// get from https://app.quicktype.io/
import 'dart:convert';

ListProductJson ListProductJsonFromJson(String str) =>
    ListProductJson.fromJson(json.decode(str));

String ListProductJsonToJson(ListProductJson data) =>
    json.encode(data.toJson());

class ListProductJson {
  final int idProduk;
  final String namaProduk;
  final String kodeProduk;

  ListProductJson({
    this.idProduk = 0,
    required this.namaProduk,
    required this.kodeProduk,
  });

  factory ListProductJson.fromJson(Map<String, dynamic> json) =>
      ListProductJson(
        idProduk: json['idProduk'],
        namaProduk: json['namaProduk'],
        kodeProduk: json['kodeProduk'],
      );

  Map<String, dynamic> toJson() => {
    "namaProduk": namaProduk,
    "kodeProduk": kodeProduk,
  };
}
