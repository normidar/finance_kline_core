import 'package:finance_kline_core/finance_kline_core.dart';

abstract class Series {
  final Map<int, List<double?>> _ema;

  MacdSeries? _macd;
  RsiSeries? _rsi;

  Series({
    Map<int, List<double?>>? ema,
    MacdSeries? macd,
    RsiSeries? rsi,
  })  : _ema = ema ?? <int, List<double?>>{},
        _macd = macd,
        _rsi = rsi;

  DecList get closes;
  DecList get highs;
  DecList get lows;

  DecList get opens;

  /// 終値の指数移動平均（EMA）を計算します
  ///
  /// [period] 期間を指定します
  List<double?> ema({
    required int period,
    PriceType priceType = PriceType.close,
  }) {
    _ema[period] ??= prices(priceType).ema(period);
    return _ema[period]!;
  }

  /// MACD（Moving Average Convergence Divergence）を計算します
  ///
  /// [fastPeriod] 短期EMAの期間（デフォルト: 12）
  /// [slowPeriod] 長期EMAの期間（デフォルト: 26）
  /// [signalPeriod] シグナルラインのEMA期間（デフォルト: 9）
  MacdSeries macd({
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    PriceType priceType = PriceType.close,
  }) {
    _macd ??= prices(priceType).macd(
      fastPeriod: fastPeriod,
      slowPeriod: slowPeriod,
      signalPeriod: signalPeriod,
    );
    return _macd!;
  }

  DecList prices(PriceType type) => switch (type) {
        PriceType.close => closes,
        PriceType.high => highs,
        PriceType.low => lows,
        PriceType.open => opens,
      };

  /// RSI（Relative Strength Index）を計算します
  ///
  /// [period] 期間を指定します（デフォルト: 14）
  RsiSeries rsi({
    int period = 14,
    PriceType priceType = PriceType.close,
  }) {
    _rsi ??= prices(priceType).rsi(period);
    return _rsi!;
  }
}
