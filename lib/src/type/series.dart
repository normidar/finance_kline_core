import 'package:finance_kline_core/src/enum/price_type.dart';
import 'package:finance_kline_core/src/model/macd.dart';
import 'package:finance_kline_core/src/model/rsi.dart';
import 'package:finance_kline_core/src/signal/ema/ema_logic.dart';
import 'package:finance_kline_core/src/signal/macd/macd_logic.dart';
import 'package:finance_kline_core/src/signal/rsi/rsi_logic.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';

abstract class Series {
  final Map<String, List<double?>> _ema;
  final Map<String, List<Macd?>> _macdCache;
  final Map<String, List<Rsi?>> _rsiCache;

  Series({
    Map<String, List<double?>>? ema,
  })  : _ema = ema ?? <String, List<double?>>{},
        _macdCache = {},
        _rsiCache = {};

  DecList get closes;
  DecList get highs;
  DecList get lows;
  DecList get opens;

  /// 指数移動平均（EMA）を計算します
  ///
  /// [period] 期間
  /// [priceType] 計算対象の価格種別（デフォルト: close）
  List<double?> ema({
    required int period,
    PriceType priceType = PriceType.close,
  }) {
    final key = '$period-${priceType.name}';
    return _ema[key] ??= EmaLogic.compute(prices(priceType), period);
  }

  /// MACD（Moving Average Convergence Divergence）を計算します
  ///
  /// [fastPeriod] 短期EMAの期間（デフォルト: 12）
  /// [slowPeriod] 長期EMAの期間（デフォルト: 26）
  /// [signalPeriod] シグナルラインのEMA期間（デフォルト: 9）
  List<Macd?> macd({
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    PriceType priceType = PriceType.close,
  }) {
    final key = '$fastPeriod-$slowPeriod-$signalPeriod-${priceType.name}';
    return _macdCache[key] ??= MacdLogic.compute(
      prices(priceType),
      fastPeriod: fastPeriod,
      slowPeriod: slowPeriod,
      signalPeriod: signalPeriod,
    );
  }

  DecList prices(PriceType type) => switch (type) {
        PriceType.close => closes,
        PriceType.high => highs,
        PriceType.low => lows,
        PriceType.open => opens,
      };

  /// RSI（Relative Strength Index）を計算します
  ///
  /// [period] 期間（デフォルト: 14）
  /// [priceType] 計算対象の価格種別（デフォルト: close）
  List<Rsi?> rsi({
    int period = 14,
    PriceType priceType = PriceType.close,
  }) {
    final key = '$period-${priceType.name}';
    return _rsiCache[key] ??= RsiLogic.compute(prices(priceType), period);
  }
}
