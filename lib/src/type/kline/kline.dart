import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kline.freezed.dart';
part 'kline.g.dart';

typedef KlineSeries = List<Kline>;

@freezed
abstract class Kline with _$Kline {
  factory Kline({
    required Decimal open,
    required Decimal high,
    required Decimal low,
    required Decimal close,
  }) = _Kline;

  factory Kline.fromDouble({
    required double open,
    required double high,
    required double low,
    required double close,
    int scale = 4,
  }) {
    return Kline(
      open: Decimal.parse(open.toStringAsFixed(scale)),
      high: Decimal.parse(high.toStringAsFixed(scale)),
      low: Decimal.parse(low.toStringAsFixed(scale)),
      close: Decimal.parse(close.toStringAsFixed(scale)),
    );
  }

  factory Kline.fromJson(Map<String, dynamic> json) => _$KlineFromJson(json);

  factory Kline.fromOhlcv(Ohlcv ohlcv) {
    return Kline(
      open: ohlcv.open,
      high: ohlcv.high,
      low: ohlcv.low,
      close: ohlcv.close,
    );
  }

  const Kline._();

  bool check() => open <= high && open >= low && close <= high && close >= low;

  Decimal price(PriceType type) {
    switch (type) {
      case PriceType.open:
        return open;
      case PriceType.high:
        return high;
      case PriceType.low:
        return low;
      case PriceType.close:
        return close;
    }
  }

  Ohlcv toOhlcv({required Decimal volume}) {
    return Ohlcv(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

enum PriceType {
  open,
  high,
  low,
  close,
}

extension KlineSeriesX on KlineSeries {
  DecList get closes => map((e) => e.close).toList();
  DecList get highs => map((e) => e.high).toList();
  DecList get lows => map((e) => e.low).toList();
  DecList get opens => map((e) => e.open).toList();

  /// 終値の指数移動平均（EMA）を計算します
  ///
  /// [period] 期間を指定します
  List<double?> ema({
    required int period,
    PriceType priceType = PriceType.close,
  }) => prices(priceType).ema(period);

  Kline mergeToKline() {
    return Kline(
      open: opens.first,
      high: highs.reduce((a, b) => a > b ? a : b),
      low: lows.reduce((a, b) => a < b ? a : b),
      close: closes.last,
    );
  }

  /// Use linear fit to predict the next kline.
  Kline predictNext({int scale = 4}) {
    if (length < 2) {
      throw ArgumentError(
        'KlineSeries must have at least 2 klines to predict next',
      );
    }
    final closesFit = closes.linearFit().predict(closes.length.toDouble() + 1);
    final highsFit = highs.linearFit().predict(highs.length.toDouble() + 1);
    final lowsFit = lows.linearFit().predict(lows.length.toDouble() + 1);
    final opensFit = opens.linearFit().predict(opens.length.toDouble() + 1);
    return Kline.fromDouble(
      open: opensFit,
      high: highsFit,
      low: lowsFit,
      close: closesFit,
      scale: scale,
    );
  }

  DecList prices(PriceType type) => map((e) => e.price(type)).toList();

  OhlcvSeries toOhlcvSeries({required DecList volume}) {
    if (length != volume.length) {
      throw ArgumentError(
        'KlineSeries and volume list must have the same length',
      );
    }
    final ohlcvSeries = <Ohlcv>[];
    for (var i = 0; i < length; i++) {
      ohlcvSeries.add(this[i].toOhlcv(volume: volume[i]));
    }
    return ohlcvSeries;
  }
}
