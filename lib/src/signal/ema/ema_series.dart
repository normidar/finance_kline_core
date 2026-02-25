import 'package:finance_kline_core/src/signal/interface.dart';

/// 複数期間のEMAをまとめて保持するシリーズ
///
/// ```dart
/// final series = EmaSeries(values: {12: [...], 26: [...]});
/// final ema12 = series[12]; // 12期間EMAの値リスト
/// ```
class EmaSeries extends SignalSeries {
  /// {period: EMA値リスト} のマップ
  final Map<int, List<double?>> values;

  EmaSeries({required this.values});

  /// 指定した期間のEMA値リストを返します
  List<double?> operator [](int period) => values[period] ?? [];

  @override
  EmaSeries sublist({int? start, int? end}) => EmaSeries(
        values: {
          for (final entry in values.entries)
            entry.key: entry.value.sublist(start ?? 0, end),
        },
      );
}
