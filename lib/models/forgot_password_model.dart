import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_model.g.dart';

@JsonSerializable()
class ForgotPasswordModel {
  final String email;

  ForgotPasswordModel({required this.email});

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordModelToJson(this);
}
