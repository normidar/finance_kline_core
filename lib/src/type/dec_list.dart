import 'package:decimal/decimal.dart';

typedef DecList = List<Decimal>;

class LinearFitResult {
  const LinearFitResult({
    required this.slope,
    required this.intercept,
  });
  final double slope; // 傾き

  final double intercept; // 切片

  // 予測値を計算
  double predict(double x) => slope * x + intercept;
}

extension DecListX on DecList {
  /// 線形回帰（最小二乗法）を実行し、傾きと切片を計算します
  ///
  /// リストのインデックスをx座標、値をy座標として線形フィッティングを行います
  /// 空のリストまたは要素が1つの場合は例外をスローします
  LinearFitResult linearFit() {
    if (isEmpty) {
      throw ArgumentError('Cannot perform linear fit on empty list');
    }
    if (length == 1) {
      throw ArgumentError('Cannot perform linear fit with only one data point');
    }

    final n = length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (var i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = this[i].toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    // 最小二乗法の公式
    // slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
    // intercept = (sumY - slope * sumX) / n
    final denominator = n * sumX2 - sumX * sumX;

    if (denominator == 0) {
      throw StateError('Cannot calculate linear fit: denominator is zero');
    }

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    return LinearFitResult(
      slope: slope,
      intercept: intercept,
    );
  }
}
