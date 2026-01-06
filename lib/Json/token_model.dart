class TokenModel {
  final int? id;
  final String token;
  final int? userId;
  final String? expiresAt;

  TokenModel({this.id, required this.token, this.userId, this.expiresAt});

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    id: json['id'],
    token: json['token'],
    userId: json['user_id'],
    expiresAt: json['expires_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token,
    'user_id': userId,
    'expires_at': expiresAt,
  };
}
