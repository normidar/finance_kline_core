import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ohlcv.freezed.dart';
part 'ohlcv.g.dart';


@freezed
abstract class Ohlcv with _$Ohlcv {
  factory Ohlcv({
    required Decimal open,
    required Decimal high,
    required Decimal low,
    required Decimal close,
    required Decimal volume,
    required int openTimestamp,
    required int closeTimestamp,
  }) = _Ohlcv;

  factory Ohlcv.fromJson(Map<String, dynamic> json) => _$OhlcvFromJson(json);

  const Ohlcv._();

  Decimal price(OhlcvType type) {
    switch (type) {
      case OhlcvType.open:
        return open;
      case OhlcvType.high:
        return high;
      case OhlcvType.low:
        return low;
      case OhlcvType.close:
        return close;
      case OhlcvType.volume:
        return volume;
    }
  }

  Kline toKline() => Kline.fromOhlcv(this);
}

enum OhlcvType {
  open,
  high,
  low,
  close,
  volume,
}
