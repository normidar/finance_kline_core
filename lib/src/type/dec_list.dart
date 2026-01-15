import 'package:decimal/decimal.dart';

typedef DecList = List<Decimal>;

class LinearFitResult {
  const LinearFitResult({
    required this.slope,
    required this.intercept,
    required this.rSquared,
  });
  final double slope; // 傾き

  final double intercept; // 切片

  final double rSquared; // 決定係数（R²）: 0〜1の範囲で、1に近いほどフィッティングが良い

  // 予測値を計算
  double predict(double x) => slope * x + intercept;
}

extension DecListX on DecList {
  /// 指数移動平均（Exponential Moving Average）を計算します
  ///
  /// [period] 期間を指定します
  /// 最初のEMA値はSMAで初期化され、その後は指数加重平均で計算されます
  /// 計算式: EMA = (価格 - 前回のEMA) * 乗数 + 前回のEMA
  /// 乗数 = 2 / (period + 1)
  /// データが不足している最初の部分はnullで埋められます
  List<double?> ema(int period) {
    if (period <= 0) {
      throw ArgumentError('Period must be greater than 0');
    }
    if (isEmpty) {
      return [];
    }

    final result = <double?>[];
    final multiplier = 2.0 / (period + 1);

    for (var i = 0; i < length; i++) {
      if (i < period - 1) {
        // データが不足している場合はnullを追加
        result.add(null);
      } else if (i == period - 1) {
        // 最初のEMAはSMAで初期化
        double sum = 0;
        for (var j = 0; j < period; j++) {
          sum += this[i - j].toDouble();
        }
        result.add(sum / period);
      } else {
        // EMA = (価格 - 前回のEMA) * 乗数 + 前回のEMA
        final previousEma = result[i - 1]!;
        final currentPrice = this[i].toDouble();
        final currentEma =
            (currentPrice - previousEma) * multiplier + previousEma;
        result.add(currentEma);
      }
    }

    return result;
  }

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

    // R²（決定係数）の計算
    // R² = 1 - (SS_res / SS_tot)
    // SS_res = Σ(y_i - ŷ_i)² (残差平方和)
    // SS_tot = Σ(y_i - ȳ)² (全平方和)
    final meanY = sumY / n;
    double ssRes = 0; // 残差平方和
    double ssTot = 0; // 全平方和

    for (var i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = this[i].toDouble();
      final yPred = slope * x + intercept;
      ssRes += (y - yPred) * (y - yPred);
      ssTot += (y - meanY) * (y - meanY);
    }

    // ssTotが0の場合（すべてのyが同じ値）、R²は1とする
    final rSquared = ssTot == 0 ? 1.0 : 1.0 - (ssRes / ssTot);

    return LinearFitResult(
      slope: slope,
      intercept: intercept,
      rSquared: rSquared,
    );
  }

  /// 単純移動平均（Simple Moving Average）を計算します
  ///
  /// [period] 期間を指定します
  /// 各位置において、その位置を含む過去period個の値の平均を計算します
  /// データが不足している最初の部分はnullで埋められます
  List<double?> sma(int period) {
    if (period <= 0) {
      throw ArgumentError('Period must be greater than 0');
    }
    if (isEmpty) {
      return [];
    }

    final result = <double?>[];

    for (var i = 0; i < length; i++) {
      if (i < period - 1) {
        // データが不足している場合はnullを追加
        result.add(null);
      } else {
        // period個の値の平均を計算
        double sum = 0;
        for (var j = 0; j < period; j++) {
          sum += this[i - j].toDouble();
        }
        result.add(sum / period);
      }
    }

    return result;
  }
}
