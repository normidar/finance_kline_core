// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Kline _$KlineFromJson(Map<String, dynamic> json) => _Kline(
  open: Decimal.fromJson(json['open'] as String),
  high: Decimal.fromJson(json['high'] as String),
  low: Decimal.fromJson(json['low'] as String),
  close: Decimal.fromJson(json['close'] as String),
);

Map<String, dynamic> _$KlineToJson(_Kline instance) => <String, dynamic>{
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
};
