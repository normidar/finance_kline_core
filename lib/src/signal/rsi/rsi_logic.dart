import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_params.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';
import 'package:finance_kline_core/src/type/rsi/rsi.dart';

/// RSIの計算結果を保持するシリーズ
class RsiSignalSeries extends SignalSeries {
  final RsiSeries data;

  RsiSignalSeries({required this.data});

  /// 最後のRSI値を返します（データ不足時は null）
  Rsi? get last => data.isEmpty ? null : data.last;

  /// [params] の閾値を使って、現在の状態を返します
  RsiState stateOf(RsiParams params) {
    final rsi = last;
    if (rsi == null) return RsiState.neutral;
    if (rsi.isOverbought(params.overbought)) return RsiState.overbought;
    if (rsi.isOversold(params.oversold)) return RsiState.oversold;
    return RsiState.neutral;
  }

  @override
  RsiSignalSeries sublist({int? start, int? end}) =>
      RsiSignalSeries(data: data.sublist(start ?? 0, end));
}

/// RSIのシグナル状態
enum RsiState {
  /// 買われすぎ（RSI >= overbought）
  overbought,

  /// 売られすぎ（RSI <= oversold）
  oversold,

  /// 中立
  neutral,
}

/// [RsiParams] に基づいてRSIを計算する [SignalLogic]
///
/// ```dart
/// final logic = RsiLogic();
/// final result = logic.calculate(
///   params: RsiParams(period: 14),
///   data: closes,
/// ) as RsiSignalSeries;
///
/// if (result.stateOf(params) == RsiState.oversold) {
///   // 売られすぎ → 買いシグナル
/// }
/// ```
class RsiLogic extends SignalLogic {
  @override
  RsiSignalSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final rsiParams = params as RsiParams;
    return RsiSignalSeries(data: data.rsi(rsiParams.period));
  }
}
