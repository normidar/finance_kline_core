import 'package:finance_kline_core/src/model/macd.dart';
import 'package:finance_kline_core/src/signal/ema/ema_logic.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/macd/macd_params.dart';
import 'package:finance_kline_core/src/signal/macd/macd_series.dart';

/// [MacdParams] に基づいてMACDを計算する [SignalLogic]
///
/// ```dart
/// final params = MacdParams(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9);
/// final logic = MacdLogic();
/// final result = logic.calculate(
///   params: params,
///   data: closes,
/// ) as MacdSeries;
///
/// if (result.isBullishCross) {
///   // ゴールデンクロス → 買いシグナル
/// }
/// ```
class MacdLogic extends SignalLogic {
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
  static List<Macd?> compute(
    List<double> data, {
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
    if (data.isEmpty) {
      return [];
    }

    // 短期EMAと長期EMAを計算
    final fastEma = EmaLogic.compute(data, fastPeriod);
    final slowEma = EmaLogic.compute(data, slowPeriod);

    // MACDラインを計算（短期EMA - 長期EMA）
    final macdLine = <double?>[];
    for (var i = 0; i < data.length; i++) {
      if (fastEma[i] == null || slowEma[i] == null) {
        macdLine.add(null);
      } else {
        macdLine.add(fastEma[i]! - slowEma[i]!);
      }
    }

    // シグナルラインを計算（MACDラインのEMA）
    // nullでない値のみをDecimalに変換してEMAを計算
    final macdLineValues = <double>[];
    final macdLineIndices = <int>[];
    for (var i = 0; i < macdLine.length; i++) {
      if (macdLine[i] != null) {
        macdLineValues.add(macdLine[i]!);
        macdLineIndices.add(i);
      }
    }

    final signalEma = EmaLogic.compute(macdLineValues, signalPeriod);

    // シグナルラインを元の長さに戻す
    final signalLine = List<double?>.filled(data.length, null);
    for (var i = 0; i < signalEma.length; i++) {
      if (signalEma[i] != null) {
        signalLine[macdLineIndices[i]] = signalEma[i];
      }
    }

    // MACD結果を構築
    final result = <Macd?>[];
    for (var i = 0; i < data.length; i++) {
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

  @override
  MacdSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final macdParams = params as MacdParams;
    return MacdSeries(
      data: compute(
        data,
        fastPeriod: macdParams.fastPeriod,
        slowPeriod: macdParams.slowPeriod,
        signalPeriod: macdParams.signalPeriod,
      ),
    );
  }
}
