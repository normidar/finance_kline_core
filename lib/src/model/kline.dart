import 'package:finance_kline_core/src/enum/price_type.dart';
import 'package:finance_kline_core/src/signal/interface.dart';

class Kline extends SignalUnit {
  final double open;

  final double high;
  final double low;
  final double close;
  Kline({
    required super.openTimestamp,
    required super.closeTimestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

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
}
