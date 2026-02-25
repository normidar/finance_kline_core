import 'package:finance_kline_core/src/model/rsi.dart';
import 'package:finance_kline_core/src/signal/interface.dart';

/// RSIのシグナル状態
enum RsiState {
  /// 買われすぎ（RSI >= 70）
  overbought,

  /// 売られすぎ（RSI <= 30）
  oversold,

  /// 中立
  neutral,
}

/// 複数期間のRSIをまとめて保持するシリーズ
///
/// ```dart
/// final series = RsiSeries(values: {14: [...], 21: [...]});
/// final rsi14 = series[14]; // 14期間RSIの値リスト
/// ```
class RsiSeries extends SignalSeries {
  /// {period: RSI値リスト} のマップ
  final Map<int, List<Rsi?>> values;

  RsiSeries({required this.values});

  /// 指定した期間のRSI値リストを返します
  List<Rsi?> operator [](int period) => values[period] ?? [];

  /// 指定した期間の現在の状態を返します（閾値: 70/30）
  RsiState stateOf(int period) {
    final list = values[period];
    final rsi = list == null || list.isEmpty ? null : list.last;
    if (rsi == null) return RsiState.neutral;
    if (rsi.isOverbought) return RsiState.overbought;
    if (rsi.isOversold) return RsiState.oversold;
    return RsiState.neutral;
  }

  @override
  RsiSeries sublist({int? start, int? end}) => RsiSeries(
        values: {
          for (final entry in values.entries)
            entry.key: entry.value.sublist(start ?? 0, end),
        },
      );
}
