import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kline.freezed.dart';
part 'kline.g.dart';

@freezed
abstract class Kline with _$Kline {
  factory Kline({
    required Decimal open,
    required Decimal high,
    required Decimal low,
    required Decimal close,
  }) = _Kline;

  factory Kline.fromDouble({
    required double open,
    required double high,
    required double low,
    required double close,
    int scale = 4,
  }) {
    return Kline(
      open: Decimal.parse(open.toStringAsFixed(scale)),
      high: Decimal.parse(high.toStringAsFixed(scale)),
      low: Decimal.parse(low.toStringAsFixed(scale)),
      close: Decimal.parse(close.toStringAsFixed(scale)),
    );
  }

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

  Decimal price(PriceType type) {
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

  Ohlcv toOhlcv({required Decimal volume}) {
    return Ohlcv(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

enum PriceType {
  open,
  high,
  low,
  close,
}
