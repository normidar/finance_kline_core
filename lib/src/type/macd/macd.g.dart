// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Macd _$MacdFromJson(Map<String, dynamic> json) => _Macd(
  macdLine: (json['macdLine'] as num).toDouble(),
  signalLine: (json['signalLine'] as num).toDouble(),
  histogram: (json['histogram'] as num).toDouble(),
);

Map<String, dynamic> _$MacdToJson(_Macd instance) => <String, dynamic>{
  'macdLine': instance.macdLine,
  'signalLine': instance.signalLine,
  'histogram': instance.histogram,
};
