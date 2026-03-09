import 'package:finance_kline_core/finance_kline_core.dart';

class FKCEngine {
  FKCEngine({
    required this.baseInterval,
  });

  final Interval baseInterval;

  final Map<Interval, KlineSeries> _klineSeriesMap = {};

  void addKlineSeries(Interval interval, KlineSeries klineSeries) {
    _klineSeriesMap[interval] = klineSeries;
  }

  KlineSeries? getKlineSeries(Interval interval) {
    return _klineSeriesMap[interval];
  }
}
