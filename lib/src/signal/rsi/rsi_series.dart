import 'package:finance_kline_core/src/model/rsi.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_params.dart';

/// RSIのシグナル状態
enum RsiState {
  /// 買われすぎ（RSI >= overbought）
  overbought,

  /// 売られすぎ（RSI <= oversold）
  oversold,

  /// 中立
  neutral,
}

/// RSIの計算結果を保持するシリーズ
class RsiSeries extends SignalSeries {
  final List<Rsi?> data;

  RsiSeries({required this.data});

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
  RsiSeries sublist({int? start, int? end}) =>
      RsiSeries(data: data.sublist(start ?? 0, end));
}
