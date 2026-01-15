import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kline.freezed.dart';
part 'kline.g.dart';

typedef KlineSeries = List<Kline>;

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
  }) {
    return Kline(
      open: Decimal.parse(open.toString()),
      high: Decimal.parse(high.toString()),
      low: Decimal.parse(low.toString()),
      close: Decimal.parse(close.toString()),
    );
  }

  factory Kline.fromJson(Map<String, dynamic> json) => _$KlineFromJson(json);

  const Kline._();

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
}

enum PriceType {
  open,
  high,
  low,
  close,
}

extension KlineSeriesX on KlineSeries {
  DecList get closes => map((e) => e.close).toList();
  DecList get highs => map((e) => e.high).toList();
  DecList get lows => map((e) => e.low).toList();
  DecList get opens => map((e) => e.open).toList();
  DecList prices(PriceType type) => map((e) => e.price(type)).toList();
}
