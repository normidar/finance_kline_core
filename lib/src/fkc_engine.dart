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

  /// バーごとに [func] を呼び出し、結果のリストを返します
  ///
  /// [func] には「そのバーまでの全データ」を持つ [OhlcvSeriesWrapper] が渡されます。
  /// これにより、各時点での指標値やシグナルを逐次計算できます。
  ///
  /// [start] 分析を開始するインデックス（指標のウォームアップ期間分を指定する）
  ///
  /// 注意: [func] 内で [OhlcvSeriesWrapper.jumpTo] を使うと、
  /// そのタイムフレームのフルデータが返されます（スライスされません）。
  List<T> analyze<T>({
    required T Function(OhlcvSeriesWrapper wrapper) func,
    required int start,
  }) {
    final result = <T>[];
    final baseIntervalWrapper = select(baseInterval);
    if (baseIntervalWrapper == null) return [];

    final totalLength = baseIntervalWrapper.ohlcvSeries.length;
    for (var i = start; i < totalLength; i++) {
      final slicedSeries = OhlcvSeries(
        data: baseIntervalWrapper.ohlcvSeries.sublist(0, i + 1),
      );
      final wrapper = OhlcvSeriesWrapper(
        interval: baseInterval,
        ohlcvSeries: slicedSeries,
        engine: this,
      );
      result.add(func(wrapper));
    }
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
