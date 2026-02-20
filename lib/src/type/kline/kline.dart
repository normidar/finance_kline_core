import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/enum/price_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kline.freezed.dart';
part 'kline.g.dart';

@freezed
abstract class Kline with _$Kline {
  factory Kline({
    required double open,
    required double high,
    required double low,
    required double close,
  }) = _Kline;

  factory Kline.fromJson(Map<String, dynamic> json) => _$KlineFromJson(json);

  factory Kline.fromOhlcv(Ohlcv ohlcv) {
    return Kline(
      open: ohlcv.open,
      high: ohlcv.high,
      low: ohlcv.low,
      close: ohlcv.close,
    );
  }

  const Kline._();

  bool check() => open <= high && open >= low && close <= high && close >= low;

  double price(PriceType type) {
    switch (type) {
      case PriceType.open:
        return open;
      case PriceType.high:
        return high;
      case PriceType.low:
        return low;
      case PriceType.close:
        return close;
    }
  }

  Ohlcv toOhlcv({
    required double volume,
    required int openTimestamp,
    required int closeTimestamp,
  }) {
    return Ohlcv(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      openTimestamp: openTimestamp,
      closeTimestamp: closeTimestamp,
    );
  }
}
