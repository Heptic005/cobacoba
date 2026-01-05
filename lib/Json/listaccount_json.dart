// get from https://app.quicktype.io/
import 'dart:convert';

ListAccountJson ListAccountJsonFromJson(String str) =>
    ListAccountJson.fromJson(json.decode(str));

String ListAccountJsonToJson(ListAccountJson data) =>
    json.encode(data.toJson());

class ListAccountJson {
  final int accountID;
  final String accountPosition;

  ListAccountJson({this.accountID = 0, required this.accountPosition});

  factory ListAccountJson.fromJson(Map<String, dynamic> json) =>
      ListAccountJson(
        accountID: json["accountID"],
        accountPosition: json["accountPosition"],
      );

  Map<String, dynamic> toJson() => {
    // "accountID": accountID,
    "accountPosition": accountPosition,
  };
}
