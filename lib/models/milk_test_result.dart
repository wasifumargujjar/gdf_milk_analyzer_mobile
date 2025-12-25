import 'package:json_annotation/json_annotation.dart';

part 'milk_test_result.g.dart';

@JsonSerializable()
class MilkTestResult {
  final int id;
  final DateTime timestampUtc;
  final String? rawLine;
  final List<MilkTestResultValue>? values;

  MilkTestResult({
    required this.id,
    required this.timestampUtc,
    this.rawLine,
    this.values,
  });

  factory MilkTestResult.fromJson(Map<String, dynamic> json) =>
      _$MilkTestResultFromJson(json);

  Map<String, dynamic> toJson() => _$MilkTestResultToJson(this);
}

@JsonSerializable()
class MilkTestResultValue {
  final int id;
  final int parameterId;
  final String? parameterName;
  final double? value;

  MilkTestResultValue({
    required this.id,
    required this.parameterId,
    this.parameterName,
    this.value,
  });

  factory MilkTestResultValue.fromJson(Map<String, dynamic> json) =>
      _$MilkTestResultValueFromJson(json);

  Map<String, dynamic> toJson() => _$MilkTestResultValueToJson(this);
}

@JsonSerializable()
class MilkTestResultsResponse {
  final int totalResults;
  final int page;
  final int pageSize;
  final List<MilkTestResult> results;

  MilkTestResultsResponse({
    required this.totalResults,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory MilkTestResultsResponse.fromJson(Map<String, dynamic> json) =>
      _$MilkTestResultsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MilkTestResultsResponseToJson(this);
}
