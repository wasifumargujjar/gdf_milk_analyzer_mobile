import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String token;
  final String username;
  final String email;
  final String role;
  final DateTime expiresAt;

  LoginResponse({
    required this.token,
    required this.username,
    required this.email,
    required this.role,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
