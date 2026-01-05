// get from https://app.quicktype.io/
import 'dart:convert';

ListProductJson ListProductJsonFromJson(String str) =>
    ListProductJson.fromJson(json.decode(str));

String ListProductJsonToJson(ListProductJson data) =>
    json.encode(data.toJson());

class ListProductJson {
  final int productID;
  final String productName;
  final String productKeterangan;

  ListProductJson({
    this.productID = 0,
    required this.productName,
    required this.productKeterangan,
  });

  factory ListProductJson.fromJson(Map<String, dynamic> json) =>
      ListProductJson(
        productID: json["productID"],
        productName: json["productName"],
        productKeterangan: json["productKeterangan"],
      );

  Map<String, dynamic> toJson() => {
    // "productID": productID,
    "productName": productName,
    "productKeterangan": productKeterangan,
  };
}
