import 'package:finance_kline_core/src/signal/ema/ema_series.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/kline/kline_series.dart';
import 'package:finance_kline_core/src/signal/macd/macd_series.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_series.dart';

/// MACD・RSI・EMA・Klineをまとめて保持するシリーズ
///
/// ```dart
/// final result = CompactLogic().calculate(
///   klineSeries: klineSeries,
///   priceType: PriceType.close,
///   params: CompactParams(
///     emaParams: EmaParams(periods: {12, 26}),
///     rsiParams: RsiParams(periods: {14}),
///     macdParams: MacdParams(),
///   ),
/// );
///
/// final lastKline = result.kline.units.last;
/// final lastMacd  = result.macd.last;
/// final rsi14     = result.rsi[14].last;
/// final ema12     = result.ema[12].last;
/// ```
class CompactSeries extends SignalSeries {
  final KlineSeries kline;
  final MacdSeries macd;
  final RsiSeries rsi;
  final EmaSeries ema;

  CompactSeries({
    required this.kline,
    required this.macd,
    required this.rsi,
    required this.ema,
  });

  @override
  CompactSeries sublist({int? start, int? end}) => CompactSeries(
        kline: KlineSeries(units: kline.units.sublist(start ?? 0, end)),
        macd: macd.sublist(start: start, end: end),
        rsi: rsi.sublist(start: start, end: end),
        ema: ema.sublist(start: start, end: end),
      );
}
