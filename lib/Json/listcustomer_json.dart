// get from https://app.quicktype.io/
import 'dart:convert';

ListCustomerJson ListCustomerJsonFromJson(String str) =>
    ListCustomerJson.fromJson(json.decode(str));

String ListCustomerJsonToJson(ListCustomerJson data) =>
    json.encode(data.toJson());

class ListCustomerJson {
  final int customerID;
  final String customerName;
  final String customerAddress;
  final String customerPhone;

  ListCustomerJson({
    this.customerID = 0,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
  });

  factory ListCustomerJson.fromJson(Map<String, dynamic> json) =>
      ListCustomerJson(
        customerID: json["customerID"],
        customerName: json["customerName"],
        customerAddress: json["customerAddress"],
        customerPhone: json["customerPhone"],
      );

  Map<String, dynamic> toJson() => {
    // "customerID": customerID,
    "customerName": customerName,
    "customerAddress": customerAddress,
    "customerPhone": customerPhone,
  };
}
