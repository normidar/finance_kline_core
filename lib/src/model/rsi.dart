/// RSI（Relative Strength Index）の指標データ
class Rsi {
  /// 買われすぎの閾値（固定値: 70）
  static const double overboughtLevel = 70;

  /// 売られすぎの閾値（固定値: 30）
  static const double oversoldLevel = 30;

  /// RSI値（0〜100の範囲）
  final double value;

  const Rsi({required this.value});

  /// RSIが中立水準にあるかどうか（30〜70の範囲）
  bool get isNeutral => value > oversoldLevel && value < overboughtLevel;

  /// RSIが買われすぎ水準にあるかどうか（70以上）
  bool get isOverbought => value >= overboughtLevel;

  /// RSIが売られすぎ水準にあるかどうか（30以下）
  bool get isOversold => value <= oversoldLevel;
}
