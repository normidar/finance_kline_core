import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/src/type/macd/macd.dart';
import 'package:finance_kline_core/src/type/rsi/rsi.dart';

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
  /// ピアソンの積率相関係数を計算します
  ///
  /// [other] 相関を計算する対象のDecList
  ///
  /// 相関係数は-1〜+1の範囲で、以下のような意味を持ちます：
  /// - +1: 完全な正の相関（一方が増えるともう一方も増える）
  /// - 0: 相関なし
  /// - -1: 完全な負の相関（一方が増えるともう一方は減る）
  ///
  /// 2つのリストの長さは同じである必要があります
  /// 空のリストまたは要素が1つ以下の場合は例外をスローします
  /// すべての値が同じ場合（標準偏差が0）も例外をスローします
  double correlation(DecList other) {
    if (isEmpty) {
      throw ArgumentError('Cannot calculate correlation on empty list');
    }
    if (length != other.length) {
      throw ArgumentError(
        'Lists must have the same length: $length != ${other.length}',
      );
    }
    if (length == 1) {
      throw ArgumentError(
        'Cannot calculate correlation with only one data point',
      );
    }

    final n = length;

    // 平均値を計算
    double sumX = 0;
    double sumY = 0;
    for (var i = 0; i < n; i++) {
      sumX += this[i].toDouble();
      sumY += other[i].toDouble();
    }
    final meanX = sumX / n;
    final meanY = sumY / n;

    // 共分散と標準偏差を計算
    double covariance = 0;
    double varianceX = 0;
    double varianceY = 0;

    for (var i = 0; i < n; i++) {
      final deviationX = this[i].toDouble() - meanX;
      final deviationY = other[i].toDouble() - meanY;

      covariance += deviationX * deviationY;
      varianceX += deviationX * deviationX;
      varianceY += deviationY * deviationY;
    }

    // 標準偏差が0の場合（すべての値が同じ）は計算不可
    if (varianceX == 0 || varianceY == 0) {
      throw StateError(
        'Cannot calculate correlation: one or both lists have zero variance',
      );
    }

    // ピアソン相関係数 = 共分散 / (標準偏差X * 標準偏差Y)
    final stdDevX = math.sqrt(varianceX.abs());
    final stdDevY = math.sqrt(varianceY.abs());
    final correlation = covariance / (stdDevX * stdDevY);

    return correlation;
  }

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

  /// MACD（Moving Average Convergence Divergence）を計算します
  ///
  /// [fastPeriod] 短期EMAの期間（デフォルト: 12）
  /// [slowPeriod] 長期EMAの期間（デフォルト: 26）
  /// [signalPeriod] シグナルラインのEMA期間（デフォルト: 9）
  ///
  /// MACDライン = 短期EMA - 長期EMA
  /// シグナルライン = MACDラインのEMA
  /// ヒストグラム = MACDライン - シグナルライン
  ///
  /// データが不足している最初の部分はnullで埋められます
  MacdSeries macd({
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (fastPeriod <= 0 || slowPeriod <= 0 || signalPeriod <= 0) {
      throw ArgumentError('All periods must be greater than 0');
    }
    if (fastPeriod >= slowPeriod) {
      throw ArgumentError('Fast period must be less than slow period');
    }
    if (isEmpty) {
      return [];
    }

    // 短期EMAと長期EMAを計算
    final fastEma = ema(fastPeriod);
    final slowEma = ema(slowPeriod);

    // MACDラインを計算（短期EMA - 長期EMA）
    final macdLine = <double?>[];
    for (var i = 0; i < length; i++) {
      if (fastEma[i] == null || slowEma[i] == null) {
        macdLine.add(null);
      } else {
        macdLine.add(fastEma[i]! - slowEma[i]!);
      }
    }

    // シグナルラインを計算（MACDラインのEMA）
    // nullでない値のみをDecimalに変換してEMAを計算
    final macdLineValues = <Decimal>[];
    final macdLineIndices = <int>[];
    for (var i = 0; i < macdLine.length; i++) {
      if (macdLine[i] != null) {
        macdLineValues.add(Decimal.parse(macdLine[i]!.toString()));
        macdLineIndices.add(i);
      }
    }

    final signalEma = macdLineValues.ema(signalPeriod);

    // シグナルラインを元の長さに戻す
    final signalLine = List<double?>.filled(length, null);
    for (var i = 0; i < signalEma.length; i++) {
      if (signalEma[i] != null) {
        signalLine[macdLineIndices[i]] = signalEma[i];
      }
    }

    // MACD結果を構築
    final result = <Macd?>[];
    for (var i = 0; i < length; i++) {
      if (macdLine[i] != null && signalLine[i] != null) {
        result.add(
          Macd(
            macdLine: macdLine[i]!,
            signalLine: signalLine[i]!,
            histogram: macdLine[i]! - signalLine[i]!,
          ),
        );
      } else {
        result.add(null);
      }
    }

    return result;
  }

  /// RSI（Relative Strength Index）を計算します
  ///
  /// [period] 期間を指定します（デフォルト: 14）
  ///
  /// RSIは0〜100の範囲で、価格の変動の強さを測定する指標です
  /// 計算式:
  /// 1. 各期間の価格変動を計算（gain = 上昇分, loss = 下降分）
  /// 2. 平均上昇 = gain の指数移動平均
  /// 3. 平均下降 = loss の指数移動平均
  /// 4. RS = 平均上昇 / 平均下降
  /// 5. RSI = 100 - (100 / (1 + RS))
  ///
  /// データが不足している最初の部分はnullで埋められます
  RsiSeries rsi(int period) {
    if (period <= 0) {
      throw ArgumentError('Period must be greater than 0');
    }
    if (isEmpty || length < 2) {
      return [];
    }

    final result = <Rsi?>[];
    final gains = <double>[];
    final losses = <double>[];

    // 各期間の価格変動を計算
    result.add(null); // 最初のデータポイントはnull
    for (var i = 1; i < length; i++) {
      final change = this[i].toDouble() - this[i - 1].toDouble();
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    // 最初のperiod個はnullで埋める（最初の1つは既に追加済み）
    for (var i = 1; i < period; i++) {
      result.add(null);
    }

    // 最初の平均を計算（SMA）
    double avgGain = 0;
    double avgLoss = 0;
    for (var i = 0; i < period; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
    }
    avgGain /= period;
    avgLoss /= period;

    // 最初のRSIを計算
    var rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
    var rsi = 100 - (100 / (1 + rs));
    result.add(Rsi(value: rsi));

    // 残りのRSIを計算（EMAを使用）
    for (var i = period; i < gains.length; i++) {
      avgGain = ((avgGain * (period - 1)) + gains[i]) / period;
      avgLoss = ((avgLoss * (period - 1)) + losses[i]) / period;

      rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
      rsi = 100 - (100 / (1 + rs));
      result.add(Rsi(value: rsi));
    }

    return result;
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
