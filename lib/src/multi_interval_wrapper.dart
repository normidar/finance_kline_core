import 'package:finance_kline_core/finance_kline_core.dart';

class MultiIntervalWrapper {
  final Map<Interval, CompactSeries> compactSeriesMap;

  MultiIntervalWrapper({
    required this.compactSeriesMap,
  });

  List<T> analyze<T>({
    required Interval moveInterval,
    required int moveSize,
    required T Function(MultiIntervalWrapper) onAnalyze,
  }) {
    final baseSeries = compactSeriesMap[moveInterval];
    if (baseSeries == null) {
      throw ArgumentError(
        'moveInterval $moveInterval not found in compactSeriesMap',
      );
    }

    final klines = baseSeries.kline.units;
    if (klines.length < moveSize) return [];

    final results = <T>[];
    for (var i = 0; i <= klines.length - moveSize; i++) {
      final startTimestamp = klines[i].openTimestamp;
      final endTimestamp = klines[i + moveSize - 1].closeTimestamp;

      final slicedMap = compactSeriesMap.map(
        (interval, series) => MapEntry(
          interval,
          series.subByTimestamp(start: startTimestamp, end: endTimestamp),
        ),
      );

      results.add(onAnalyze(MultiIntervalWrapper(compactSeriesMap: slicedMap)));
    }

    return results;
  }
}
