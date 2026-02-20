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

  /// baseIntervalの時間足のwrapperで分析する関数を渡して分析を行う
  List<T> analyze<T>({
    required T Function(OhlcvSeriesWrapper wrapper) func,
    required int start,
  }) {
    final result = <T>[];
    final baseIntervalWrapper = select(baseInterval);
    if (baseIntervalWrapper == null) {
      return [];
    }
    for (var i = 0; i < baseIntervalWrapper.ohlcvSeries.length; i++) {}
    return result;
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

/// 各時間足のデータをラップするクラス
/// jumpToを使って別の時間足のデータを取得できる
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
