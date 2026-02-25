import 'package:finance_kline_core/src/signal/interface.dart';

/// MACD計算のパラメータ
class MacdParams extends SignalParams {
  /// 短期EMAの期間（デフォルト: 12）
  final int fastPeriod;

  /// 長期EMAの期間（デフォルト: 26）
  final int slowPeriod;

  /// シグナルラインのEMA期間（デフォルト: 9）
  final int signalPeriod;

  MacdParams({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });
}
