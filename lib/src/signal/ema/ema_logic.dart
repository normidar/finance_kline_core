import 'package:finance_kline_core/src/signal/ema/ema_params.dart';
import 'package:finance_kline_core/src/signal/ema/ema_series.dart';
import 'package:finance_kline_core/src/signal/interface.dart';

/// [EmaParams] で指定した全期間のEMAを計算する [SignalLogic]
///
/// ```dart
/// final logic = EmaLogic();
/// final result = logic.calculate(
///   params: EmaParams(periods: {12, 26}),
///   data: closes,
/// ) as EmaSeries;
///
/// final crossAbove = result[12].last! > result[26].last!;
/// ```
class EmaLogic extends SignalLogic {
  /// 指数移動平均（Exponential Moving Average）を計算します
  ///
  /// [period] 期間を指定します
  /// 最初のEMA値はSMAで初期化され、その後は指数加重平均で計算されます
  /// 計算式: EMA = (価格 - 前回のEMA) * 乗数 + 前回のEMA
  /// 乗数 = 2 / (period + 1)
  /// データが不足している最初の部分はnullで埋められます
  static List<double?> compute(List<double> data, int period) {
    if (period <= 0) {
      throw ArgumentError('Period must be greater than 0');
    }
    if (data.isEmpty) {
      return [];
    }

    final result = <double?>[];
    final multiplier = 2.0 / (period + 1);

    for (var i = 0; i < data.length; i++) {
      if (i < period - 1) {
        // データが不足している場合はnullを追加
        result.add(null);
      } else if (i == period - 1) {
        // 最初のEMAはSMAで初期化
        double sum = 0;
        for (var j = 0; j < period; j++) {
          sum += data[i - j];
        }
        result.add(sum / period);
      } else {
        // EMA = (価格 - 前回のEMA) * 乗数 + 前回のEMA
        final previousEma = result[i - 1]!;
        final currentPrice = data[i];
        final currentEma =
            (currentPrice - previousEma) * multiplier + previousEma;
        result.add(currentEma);
      }
    }

    return result;
  }

  @override
  EmaSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final emaParams = params as EmaParams;
    return EmaSeries(
      values: {
        for (final period in emaParams.periods) period: compute(data, period),
      },
    );
  }
}
