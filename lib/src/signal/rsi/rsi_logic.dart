import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_params.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_series.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';

/// [RsiParams] に基づいてRSIを計算する [SignalLogic]
///
/// ```dart
/// final params = RsiParams(period: 14);
/// final logic = RsiLogic();
/// final result = logic.calculate(
///   params: params,
///   data: closes,
/// ) as RsiSeries;
///
/// if (result.stateOf(params) == RsiState.oversold) {
///   // 売られすぎ → 買いシグナル
/// }
/// ```
class RsiLogic extends SignalLogic {
  @override
  RsiSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final rsiParams = params as RsiParams;
    return RsiSeries(data: data.rsi(rsiParams.period));
  }
}
