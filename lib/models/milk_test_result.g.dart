// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_test_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilkTestResult _$MilkTestResultFromJson(Map<String, dynamic> json) =>
    MilkTestResult(
      id: (json['id'] as num).toInt(),
      timestampUtc: DateTime.parse(json['timestampUtc'] as String),
      rawLine: json['rawLine'] as String?,
      values: (json['values'] as List<dynamic>?)
          ?.map((e) => MilkTestResultValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MilkTestResultToJson(MilkTestResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestampUtc': instance.timestampUtc.toIso8601String(),
      'rawLine': instance.rawLine,
      'values': instance.values,
    };

MilkTestResultValue _$MilkTestResultValueFromJson(Map<String, dynamic> json) =>
    MilkTestResultValue(
      id: (json['id'] as num).toInt(),
      parameterId: (json['parameterId'] as num).toInt(),
      parameterName: json['parameterName'] as String?,
      value: (json['value'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MilkTestResultValueToJson(
  MilkTestResultValue instance,
) => <String, dynamic>{
  'id': instance.id,
  'parameterId': instance.parameterId,
  'parameterName': instance.parameterName,
  'value': instance.value,
};

MilkTestResultsResponse _$MilkTestResultsResponseFromJson(
  Map<String, dynamic> json,
) => MilkTestResultsResponse(
  totalResults: (json['totalResults'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => MilkTestResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MilkTestResultsResponseToJson(
  MilkTestResultsResponse instance,
) => <String, dynamic>{
  'totalResults': instance.totalResults,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'results': instance.results,
};
