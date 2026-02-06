import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/type/series.dart';

class KlineSeries with Series {
  final List<Kline> data;

  KlineSeries(this.data);

  @override
  DecList get closes => data.map((e) => e.close).toList();
  @override
  DecList get highs => data.map((e) => e.high).toList();
  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;

  @override
  DecList get lows => data.map((e) => e.low).toList();

  @override
  DecList get opens => data.map((e) => e.open).toList();

  Kline operator [](int index) => data[index];

  KlineSeries merge({
    required int count,
    MergeAlignment alignment = MergeAlignment.left,
    MergeMode mode = MergeMode.strict,
  }) {
    if (count <= 0) {
      throw ArgumentError('Count must be greater than 0');
    }
    if (isEmpty) {
      return KlineSeries([]);
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
          result.add(_mergeChunkToKline(chunk));
        } else if (mode == MergeMode.partial && i < length) {
          // 余りのチャンク（partialモードの場合のみ）
          final chunk = sublist(i);
          result.add(_mergeChunkToKline(chunk));
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
          result.add(_mergeChunkToKline(chunk));
        }
        startIndex = remainder;
      }

      // 完全なチャンクを処理
      for (var i = startIndex; i < length; i += count) {
        final chunk = sublist(i, i + count);
        result.add(_mergeChunkToKline(chunk));
      }
    }

    return KlineSeries(result);
  }

  /// Use linear fit to predict the next kline.
  /// [scale] は小数点以下の桁数を指定します。
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

  List<Kline> sublist(int start, [int? end]) => data.sublist(start, end);

  Kline _mergeChunkToKline(List<Kline> chunk) {
    final chunkOpens = chunk.map((e) => e.open).toList();
    final chunkHighs = chunk.map((e) => e.high).toList();
    final chunkLows = chunk.map((e) => e.low).toList();
    final chunkCloses = chunk.map((e) => e.close).toList();

    return Kline(
      open: chunkOpens.first,
      high: chunkHighs.reduce((a, b) => a > b ? a : b),
      low: chunkLows.reduce((a, b) => a < b ? a : b),
      close: chunkCloses.last,
    );
  }
}
