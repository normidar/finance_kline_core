// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Kline _$KlineFromJson(Map<String, dynamic> json) => _Kline(
  open: (json['open'] as num).toDouble(),
  high: (json['high'] as num).toDouble(),
  low: (json['low'] as num).toDouble(),
  close: (json['close'] as num).toDouble(),
);

Map<String, dynamic> _$KlineToJson(_Kline instance) => <String, dynamic>{
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
};
