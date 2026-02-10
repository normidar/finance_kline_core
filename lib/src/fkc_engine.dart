import 'package:finance_kline_core/finance_kline_core.dart';

class FKCEngine {
  final Interval baseInterval;

  final Map<Interval, OhlcvSeries> _ohlcvSeriesMap = {};

  FKCEngine({
    required this.baseInterval,
  });

  void addOhlcvSeries(Interval interval, OhlcvSeries ohlcvSeries) {
    _ohlcvSeriesMap[interval] = ohlcvSeries;
  }

  OhlcvSeries? getOhlcvSeries(Interval interval) {
    return _ohlcvSeriesMap[interval];
  }

  OhlcvSeriesWrapper? select(Interval interval) {
    final ohlcvSeries = getOhlcvSeries(interval);
    if (ohlcvSeries == null) {
      return null;
    }
    return OhlcvSeriesWrapper(
      interval: interval,
      ohlcvSeries: ohlcvSeries,
      engine: this,
    );
  }
}

class OhlcvSeriesWrapper {
  final FKCEngine _engine;

  final Interval interval;

  final OhlcvSeries ohlcvSeries;

  OhlcvSeriesWrapper({
    required this.interval,
    required this.ohlcvSeries,
    required FKCEngine engine,
  }) : _engine = engine;

  OhlcvSeriesWrapper? jumpTo(Interval interval) {
    return _engine.select(interval);
  }
}
