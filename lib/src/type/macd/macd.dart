import 'package:freezed_annotation/freezed_annotation.dart';

part 'macd.freezed.dart';
part 'macd.g.dart';

/// MACD結果のシリーズ型
typedef MacdSeries = List<Macd?>;

/// MACD（Moving Average Convergence Divergence）の指標データ
@freezed
abstract class Macd with _$Macd {
  factory Macd({
    /// MACD Line: 短期EMA - 長期EMA
    required double macdLine,

    /// Signal Line: MACDラインのEMA
    required double signalLine,

    /// MACD Histogram: MACDライン - シグナルライン
    required double histogram,
  }) = _Macd;

  factory Macd.fromJson(Map<String, dynamic> json) => _$MacdFromJson(json);

  const Macd._();

  /// MACDラインがシグナルラインより下にあるかどうか（売りシグナル）
  bool get isBearish => macdLine < signalLine;

  /// MACDラインがシグナルラインより上にあるかどうか（買いシグナル）
  bool get isBullish => macdLine > signalLine;
}
