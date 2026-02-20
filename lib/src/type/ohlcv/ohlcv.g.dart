// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ohlcv.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ohlcv _$OhlcvFromJson(Map<String, dynamic> json) => _Ohlcv(
  open: (json['open'] as num).toDouble(),
  high: (json['high'] as num).toDouble(),
  low: (json['low'] as num).toDouble(),
  close: (json['close'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
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
