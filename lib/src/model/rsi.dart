/// RSI（Relative Strength Index）の指標データ
class Rsi {
  /// RSI値（0〜100の範囲）
  final double value;

  const Rsi({required this.value});

  /// RSIが中立水準にあるかどうか（デフォルト: 30〜70の範囲）
  bool isNeutral({double lowerThreshold = 30, double upperThreshold = 70}) =>
      value > lowerThreshold && value < upperThreshold;

  /// RSIが買われすぎ水準にあるかどうか（デフォルト: 70以上）
  bool isOverbought([double threshold = 70]) => value >= threshold;

  /// RSIが売られすぎ水準にあるかどうか（デフォルト: 30以下）
  bool isOversold([double threshold = 30]) => value <= threshold;
}
