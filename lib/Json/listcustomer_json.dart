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
  final String customerCity;
  final String customerPhone;
  final String customerFax;
  final String customerPIC;

  ListCustomerJson({
    this.customerID = 0,
    required this.customerName,
    required this.customerAddress,
    required this.customerCity,
    required this.customerPhone,
    required this.customerFax,
    required this.customerPIC,
  });

  factory ListCustomerJson.fromJson(Map<String, dynamic> json) =>
      ListCustomerJson(
        customerID: json["customerID"],
        customerName: json["customerName"],
        customerAddress: json["customerAddress"],
        customerCity: json["customerCity"],
        customerPhone: json["customerPhone"],
        customerFax: json["customerFax"],
        customerPIC: json["customerPIC"],
      );

  Map<String, dynamic> toJson() => {
    // "customerID": customerID,
    "customerName": customerName,
    "customerAddress": customerAddress,
    "customerCity": customerCity,
    "customerPhone": customerPhone,
    "customerFax": customerFax,
    "customerPIC": customerPIC,
  };
}
