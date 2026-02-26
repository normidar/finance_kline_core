import 'package:finance_kline_core/finance_kline_core.dart';

class MultiIntervalWrapper {
  final Map<Interval, CompactSeries> compactSeriesMap;

  MultiIntervalWrapper({
    required this.compactSeriesMap,
  });

  List<T> analyze<T>({
    required Interval moveInterval,
    required int moveSize,
    required T Function(CompactSeries) onAnalyze,
  }) {
    throw UnimplementedError();
  }
}
