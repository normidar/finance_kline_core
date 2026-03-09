import 'package:finance_kline_core/finance_kline_core.dart';

class KlineSeries extends LinearSignalSeries<Kline> {
  KlineSeries({required super.units});

  DecList getDecList(PriceType priceType) {
    return switch (priceType) {
      PriceType.close => units.map((e) => e.close).toList(),
      PriceType.high => units.map((e) => e.high).toList(),
      PriceType.low => units.map((e) => e.low).toList(),
      PriceType.open => units.map((e) => e.open).toList(),
    };
  }
}
