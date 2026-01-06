class SettingsModel {
  final int? id;
  final String key;
  final String? value;

  SettingsModel({this.id, required this.key, this.value});

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      SettingsModel(id: json['id'], key: json['key'], value: json['value']);

  Map<String, dynamic> toJson() => {'id': id, 'key': key, 'value': value};
}
