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

  /// [baseInterval] の時間足でバーごとに [func] を呼び出し、結果リストを返します
  ///
  /// 詳細は [KlineSeriesWrapper.analyze] を参照してください。
  List<T> analyze<T>({
    required T Function(KlineSeriesWrapper wrapper) func,
    required int start,
  }) {
    return select(baseInterval)?.analyze(start: start, func: func) ?? [];
  }

  KlineSeries? getKlineSeries(Interval interval) {
    return _klineSeriesMap[interval];
  }

  KlineSeriesWrapper? select(Interval interval) {
    final klineSeries = getKlineSeries(interval);
    if (klineSeries == null) return null;
    return KlineSeriesWrapper(
      interval: interval,
      klineSeries: klineSeries,
      engine: this,
    );
  }
}

/// 各時間足のデータをラップするクラス
class KlineSeriesWrapper {
  KlineSeriesWrapper({
    required this.interval,
    required this.klineSeries,
    required FKCEngine engine,
    int? currentCloseTimestamp,
  }) : engine = engine,
       _currentCloseTimestamp = currentCloseTimestamp;

  final FKCEngine engine;

  final Interval interval;

  final KlineSeries klineSeries;

  /// analyze() ループ中に設定される現在バーの closeTimestamp
  ///
  /// null のとき jumpTo() はタイムフィルタを行わない（通常の select と同じ）
  final int? _currentCloseTimestamp;

  /// バーごとに [func] を呼び出し、結果リストを返します
  ///
  /// [func] には「そのバーまでの全データ」を持つ [KlineSeriesWrapper] が渡されます。
  /// [func] 内で [jumpTo] を使うと、そのバーの closeTimestamp 以前のデータだけが返ります。
  ///
  /// [start] 分析を開始するインデックス（指標のウォームアップ期間分を指定する）
  ///
  /// ```dart
  /// final signals = engine.select(Interval.$1h)!.analyze(
  ///   start: 33, // MACDのウォームアップ: slowPeriod(26) + signalPeriod(9) - 2
  ///   func: (wrapper) {
  ///     final result = MacdLogic().calculateWithKline(
  ///       klineSeries: wrapper.klineSeries,
  ///       priceType: PriceType.close,
  ///       params: MacdParams(),
  ///     ) as MacdSeries;
  ///     return result.isBullishCross;
  ///   },
  /// );
  /// ```
  List<T> analyze<T>({
    required int start,
    required T Function(KlineSeriesWrapper wrapper) func,
  }) {
    final result = <T>[];
    for (var i = start; i < klineSeries.units.length; i++) {
      final currentTs = klineSeries.units[i].closeTimestamp;
      final sliced = klineSeries.subByTimestamp(end: currentTs);
      final wrapper = KlineSeriesWrapper(
        interval: interval,
        klineSeries: sliced as KlineSeries,
        engine: engine,
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
  KlineSeriesWrapper? jumpTo(Interval interval) {
    final series = engine.getKlineSeries(interval);
    if (series == null) return null;

    final ts = _currentCloseTimestamp;
    if (ts != null) {
      return KlineSeriesWrapper(
        interval: interval,
        klineSeries: series.subByTimestamp(end: ts) as KlineSeries,
        engine: engine,
        currentCloseTimestamp: ts,
      );
    }
    return engine.select(interval);
  }
}
