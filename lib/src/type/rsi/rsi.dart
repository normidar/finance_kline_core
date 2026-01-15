import 'package:freezed_annotation/freezed_annotation.dart';

part 'rsi.freezed.dart';
part 'rsi.g.dart';

/// RSI結果のシリーズ型
typedef RsiSeries = List<Rsi?>;

/// RSI（Relative Strength Index）の指標データ
@freezed
abstract class Rsi with _$Rsi {
  factory Rsi({
    /// RSI値（0〜100の範囲）
    required double value,
  }) = _Rsi;

  factory Rsi.fromJson(Map<String, dynamic> json) => _$RsiFromJson(json);

  const Rsi._();

  /// RSIが中立水準にあるかどうか（デフォルト: 30〜70の範囲）
  bool isNeutral({double lowerThreshold = 30, double upperThreshold = 70}) =>
      value > lowerThreshold && value < upperThreshold;

  /// RSIが買われすぎ水準にあるかどうか（デフォルト: 70以上）
  bool isOverbought([double threshold = 70]) => value >= threshold;

  /// RSIが売られすぎ水準にあるかどうか（デフォルト: 30以下）
  bool isOversold([double threshold = 30]) => value <= threshold;
}
