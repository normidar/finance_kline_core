import 'package:finance_kline_core/src/signal/interface.dart';

/// RSI計算のパラメータ
class RsiParams extends SignalParams {
  /// 計算期間（デフォルト: 14）
  final int period;

  /// 買われすぎの閾値（デフォルト: 70）
  final double overbought;

  /// 売られすぎの閾値（デフォルト: 30）
  final double oversold;

  RsiParams({
    this.period = 14,
    this.overbought = 70,
    this.oversold = 30,
  });
}
