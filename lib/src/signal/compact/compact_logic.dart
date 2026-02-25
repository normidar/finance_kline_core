import 'package:finance_kline_core/src/enum/price_type.dart';
import 'package:finance_kline_core/src/signal/compact/compact_params.dart';
import 'package:finance_kline_core/src/signal/compact/compact_series.dart';
import 'package:finance_kline_core/src/signal/ema/ema_logic.dart';
import 'package:finance_kline_core/src/signal/kline/kline_series.dart';
import 'package:finance_kline_core/src/signal/macd/macd_logic.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_logic.dart';

/// [CompactParams] に基づいてMACD・RSI・EMA・Klineをまとめて計算するロジック
///
/// ```dart
/// final params = CompactParams(
///   emaParams: EmaParams(periods: {12, 26}),
///   rsiParams: RsiParams(periods: {14}),
///   macdParams: MacdParams(),
/// );
/// final result = CompactLogic().calculate(
///   klineSeries: klineSeries,
///   priceType: PriceType.close,
///   params: params,
/// );
///
/// if (result.macd.isBullishCross &&
///     result.rsi.stateOf(14) == RsiState.oversold) {
///   // MACD ゴールデンクロス かつ RSI 売られすぎ → 買いシグナル
/// }
/// ```
class CompactLogic {
  /// [klineSeries] のローソク足データから MACD・RSI・EMA をまとめて計算します
  ///
  /// [priceType] どの価格種別（open/high/low/close）を指標計算に使うか
  CompactSeries calculate({
    required KlineSeries klineSeries,
    required PriceType priceType,
    required CompactParams params,
  }) {
    final prices =
        klineSeries.units.map((k) => k.price(priceType)).toList();

    return CompactSeries(
      kline: klineSeries,
      macd: MacdLogic().calculate(params: params.macdParams, data: prices),
      rsi: RsiLogic().calculate(params: params.rsiParams, data: prices),
      ema: EmaLogic().calculate(params: params.emaParams, data: prices),
    );
  }
}
