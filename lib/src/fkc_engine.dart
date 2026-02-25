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

  /// [baseInterval] の時間足でバーごとに [func] を呼び出し、結果リストを返します
  ///
  /// 詳細は [OhlcvSeriesWrapper.analyze] を参照してください。
  List<T> analyze<T>({
    required T Function(OhlcvSeriesWrapper wrapper) func,
    required int start,
  }) {
    return select(baseInterval)?.analyze(start: start, func: func) ?? [];
  }

  OhlcvSeries? getOhlcvSeries(Interval interval) {
    return _ohlcvSeriesMap[interval];
  }

  OhlcvSeriesWrapper? select(Interval interval) {
    final ohlcvSeries = getOhlcvSeries(interval);
    if (ohlcvSeries == null) return null;
    return OhlcvSeriesWrapper(
      interval: interval,
      ohlcvSeries: ohlcvSeries,
      engine: this,
    );
  }
}

/// 各時間足のデータをラップするクラス
class OhlcvSeriesWrapper {
  final FKCEngine _engine;

  final Interval interval;

  final OhlcvSeries ohlcvSeries;

  /// analyze() ループ中に設定される現在バーの closeTimestamp
  ///
  /// null のとき jumpTo() はタイムフィルタを行わない（通常の select と同じ）
  final int? _currentCloseTimestamp;

  OhlcvSeriesWrapper({
    required this.interval,
    required this.ohlcvSeries,
    required FKCEngine engine,
    int? currentCloseTimestamp,
  })  : _engine = engine,
        _currentCloseTimestamp = currentCloseTimestamp;

  /// バーごとに [func] を呼び出し、結果リストを返します
  ///
  /// [func] には「そのバーまでの全データ」を持つ [OhlcvSeriesWrapper] が渡されます。
  /// [func] 内で [jumpTo] を使うと、そのバーの closeTimestamp 以前のデータだけが返ります。
  ///
  /// [start] 分析を開始するインデックス（指標のウォームアップ期間分を指定する）
  ///
  /// ```dart
  /// final signals = engine.select(Interval.$1h)!.analyze(
  ///   start: 33, // MACDのウォームアップ: slowPeriod(26) + signalPeriod(9) - 2
  ///   func: (wrapper) {
  ///     final result = MacdLogic().calculateWithKline(
  ///       klineSeries: wrapper.ohlcvSeries,
  ///       priceType: PriceType.close,
  ///       params: MacdParams(),
  ///     ) as MacdSeries;
  ///     return result.isBullishCross;
  ///   },
  /// );
  /// ```
  List<T> analyze<T>({
    required int start,
    required T Function(OhlcvSeriesWrapper wrapper) func,
  }) {
    final result = <T>[];
    for (var i = start; i < ohlcvSeries.length; i++) {
      final currentTs = ohlcvSeries[i].closeTimestamp;
      final sliced = OhlcvSeries(
        data: ohlcvSeries.sublist(0, i + 1),
      );
      final wrapper = OhlcvSeriesWrapper(
        interval: interval,
        ohlcvSeries: sliced,
        engine: _engine,
        currentCloseTimestamp: currentTs,
      );
      result.add(func(wrapper));
    }
    return result;
  }

  /// 別の時間足のデータに切り替えます
  ///
  /// [analyze] ループ内では、現在バーの closeTimestamp 以前のデータのみが返ります。
  /// これにより、MTF（マルチタイムフレーム）分析で「未来のデータを参照しない」
  /// ことが保証されます。
  OhlcvSeriesWrapper? jumpTo(Interval interval) {
    final series = _engine.getOhlcvSeries(interval);
    if (series == null) return null;

    final ts = _currentCloseTimestamp;
    if (ts != null) {
      return OhlcvSeriesWrapper(
        interval: interval,
        ohlcvSeries: series.subUpToTimestamp(ts),
        engine: _engine,
        currentCloseTimestamp: ts,
      );
    }
    return _engine.select(interval);
  }
}
