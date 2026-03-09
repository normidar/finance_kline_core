/// MACD（Moving Average Convergence Divergence）の指標データ
class Macd {
  /// MACD Line: 短期EMA - 長期EMA
  final double macdLine;

  /// Signal Line: MACDラインのEMA
  final double signalLine;

  /// MACD Histogram: MACDライン - シグナルライン
  final double histogram;

  const Macd({
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
  });

  /// MACDラインがシグナルラインより下にあるかどうか（売りシグナル）
  bool get isBearish => macdLine < signalLine;

  /// MACDラインがシグナルラインより上にあるかどうか（買いシグナル）
  bool get isBullish => macdLine > signalLine;
}
