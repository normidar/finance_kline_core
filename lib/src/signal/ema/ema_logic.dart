import 'package:finance_kline_core/src/signal/ema/ema_params.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';

/// 複数期間のEMAをまとめて保持するシリーズ
///
/// ```dart
/// final series = EmaSignalSeries(values: {12: [...], 26: [...]});
/// final ema12 = series[12]; // 12期間EMAの値リスト
/// ```
class EmaSignalSeries extends SignalSeries {
  /// {period: EMA値リスト} のマップ
  final Map<int, List<double?>> values;

  EmaSignalSeries({required this.values});

  /// 指定した期間のEMA値リストを返します
  List<double?> operator [](int period) => values[period] ?? [];

  @override
  EmaSignalSeries sublist({int? start, int? end}) => EmaSignalSeries(
        values: {
          for (final entry in values.entries)
            entry.key: entry.value.sublist(start ?? 0, end),
        },
      );
}

/// [EmaParams] で指定した全期間のEMAを計算する [SignalLogic]
///
/// ```dart
/// final logic = EmaLogic();
/// final result = logic.calculate(
///   params: EmaParams(periods: {12, 26}),
///   data: closes,
/// ) as EmaSignalSeries;
///
/// final crossAbove = result[12].last! > result[26].last!;
/// ```
class EmaLogic extends SignalLogic {
  @override
  EmaSignalSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final emaParams = params as EmaParams;
    return EmaSignalSeries(
      values: {
        for (final period in emaParams.periods) period: data.ema(period),
      },
    );
  }
}
