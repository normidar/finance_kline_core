import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/type/merge_alignment.dart';

typedef KlineSeries = List<Kline>;

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

  KlineSeries merge({
    required int count,
    MergeAlignment alignment = MergeAlignment.left,
    MergeMode mode = MergeMode.strict,
  }) {
    if (count <= 0) {
      throw ArgumentError('Count must be greater than 0');
    }
    if (isEmpty) {
      return [];
    }
    if (count == 1) {
      return this;
    }

    final result = <Kline>[];

    if (alignment == MergeAlignment.left) {
      // 左寄せ（古いデータから）
      for (var i = 0; i < length; i += count) {
        final end = i + count;
        if (end <= length) {
          // 完全なチャンク
          final chunk = sublist(i, end);
          result.add(chunk.mergeToKline());
        } else if (mode == MergeMode.partial && i < length) {
          // 余りのチャンク（partialモードの場合のみ）
          final chunk = sublist(i);
          result.add(chunk.mergeToKline());
        }
      }
    } else {
      // 右寄せ（新しいデータから）
      final remainder = length % count;
      var startIndex = 0;

      if (remainder > 0) {
        if (mode == MergeMode.partial) {
          // 余りのチャンクを最初に追加
          final chunk = sublist(0, remainder);
          result.add(chunk.mergeToKline());
        }
        startIndex = remainder;
      }

      // 完全なチャンクを処理
      for (var i = startIndex; i < length; i += count) {
        final chunk = sublist(i, i + count);
        result.add(chunk.mergeToKline());
      }
    }

    return result;
  }

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
