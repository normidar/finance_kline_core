import 'package:finance_kline_core/finance_kline_core.dart';

typedef OhlcvSeries = List<Ohlcv>;

extension OhlcvSeriesX on OhlcvSeries {
  DecList get closes => map((e) => e.close).toList();
  DecList get highs => map((e) => e.high).toList();
  DecList get lows => map((e) => e.low).toList();
  DecList get opens => map((e) => e.open).toList();
  DecList get volumes => map((e) => e.volume).toList();

  DecList prices(OhlcvType type) => map((e) => e.price(type)).toList();

  KlineSeries toKlineSeries() => map((e) => e.toKline()).toList();
}
