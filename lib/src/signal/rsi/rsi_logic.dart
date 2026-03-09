import 'package:finance_kline_core/src/model/rsi.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_params.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_series.dart';

/// [RsiParams] に基づいてRSIを計算する [SignalLogic]
///
/// ```dart
/// final params = RsiParams(periods: {14, 21});
/// final logic = RsiLogic();
/// final result = logic.calculate(
///   params: params,
///   data: closes,
/// ) as RsiSeries;
///
/// if (result.stateOf(14) == RsiState.oversold) {
///   // 売られすぎ → 買いシグナル
/// }
/// ```
class RsiLogic extends SignalLogic {
  /// RSI（Relative Strength Index）を計算します
  ///
  /// [period] 期間を指定します（デフォルト: 14）
  ///
  /// RSIは0〜100の範囲で、価格の変動の強さを測定する指標です
  /// 計算式:
  /// 1. 各期間の価格変動を計算（gain = 上昇分, loss = 下降分）
  /// 2. 平均上昇 = gain の指数移動平均
  /// 3. 平均下降 = loss の指数移動平均
  /// 4. RS = 平均上昇 / 平均下降
  /// 5. RSI = 100 - (100 / (1 + RS))
  ///
  /// データが不足している最初の部分はnullで埋められます
  static List<Rsi?> compute(List<double> data, int period) {
    if (period <= 0) {
      throw ArgumentError('Period must be greater than 0');
    }
    if (data.isEmpty || data.length < 2) {
      return [];
    }

    final result = <Rsi?>[];
    final gains = <double>[];
    final losses = <double>[];

    // 各期間の価格変動を計算
    result.add(null); // 最初のデータポイントはnull
    for (var i = 1; i < data.length; i++) {
      final change = data[i] - data[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    // 最初のperiod個はnullで埋める（最初の1つは既に追加済み）
    for (var i = 1; i < period; i++) {
      result.add(null);
    }

    // 最初の平均を計算（SMA）
    double avgGain = 0;
    double avgLoss = 0;
    for (var i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
    }
    avgGain /= period;
    avgLoss /= period;

    // 最初のRSIを計算
    var rs = avgLoss == 0 ? 100.0 : avgGain / avgLoss;
    var rsiValue = 100 - (100 / (1 + rs));
    result.add(Rsi(value: rsiValue));

    // 残りのRSIを計算（EMAを使用）
    for (var i = period; i < gains.length; i++) {
      avgGain = ((avgGain * (period - 1)) + gains[i]) / period;
      avgLoss = ((avgLoss * (period - 1)) + losses[i]) / period;

      rs = avgLoss == 0 ? 100.0 : avgGain / avgLoss;
      rsiValue = 100 - (100 / (1 + rs));
      result.add(Rsi(value: rsiValue));
    }

    return result;
  }

  @override
  RsiSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final rsiParams = params as RsiParams;
    return RsiSeries(
      values: {
        for (final period in rsiParams.periods) period: compute(data, period),
      },
    );
  }
}
