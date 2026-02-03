// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ohlcv.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ohlcv _$OhlcvFromJson(Map<String, dynamic> json) => _Ohlcv(
  open: Decimal.fromJson(json['open'] as String),
  high: Decimal.fromJson(json['high'] as String),
  low: Decimal.fromJson(json['low'] as String),
  close: Decimal.fromJson(json['close'] as String),
  volume: Decimal.fromJson(json['volume'] as String),
  openTimestamp: (json['openTimestamp'] as num).toInt(),
  closeTimestamp: (json['closeTimestamp'] as num).toInt(),
);

Map<String, dynamic> _$OhlcvToJson(_Ohlcv instance) => <String, dynamic>{
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
  'volume': instance.volume,
  'openTimestamp': instance.openTimestamp,
  'closeTimestamp': instance.closeTimestamp,
};
