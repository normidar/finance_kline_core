import 'package:finance_kline_core/finance_kline_core.dart';

class OhlcvSeries extends Series {
  final List<Ohlcv> _data;

  OhlcvSeries({
    required List<Ohlcv> data,
    super.ema,
  }) : _data = data;

  @override
  DecList get closes => _data.map((e) => e.close).toList();
  @override
  DecList get highs => _data.map((e) => e.high).toList();
  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;
  int get length => _data.length;

  @override
  DecList get lows => _data.map((e) => e.low).toList();

  @override
  DecList get opens => _data.map((e) => e.open).toList();

  DecList get volumes => _data.map((e) => e.volume).toList();

  Ohlcv get first => _data.first;
  Ohlcv get last => _data.last;

  Ohlcv operator [](int index) => _data[index];

  /// [closeTimestamp] 以前のローソク足だけを含む新しい [OhlcvSeries] を返します
  ///
  /// [OhlcvSeriesWrapper.jumpTo] のMTF時刻フィルタで使われます。
  OhlcvSeries subUpToTimestamp(int closeTimestamp) {
    final filtered =
        _data.where((e) => e.closeTimestamp <= closeTimestamp).toList();
    return OhlcvSeries(data: filtered);
  }

  List<Ohlcv> subByTimestamp({int? start, int? end}) {
    if (_data.length < 2) throw UnsupportedError('data lenght must over 2');
    var endIndex = _data.length - 1;
    var startIndex = 0;
    if (end != null) {
      final lastClose = _data.last.closeTimestamp;
      final diff = lastClose - end;
      if (diff < 0) throw UnsupportedError('end over lastCode');
      final interval = _data[1].closeTimestamp - _data[0].closeTimestamp;
      endIndex = _data.length - diff ~/ interval;
    }
    if (start != null) {
      final firstOpen = _data[0].openTimestamp;
      final diff = start - firstOpen;
      if (diff < 0) throw UnsupportedError('start before firstCode');
      final interval = _data[1].openTimestamp - _data[0].openTimestamp;
      startIndex = diff ~/ interval;
    }
    return _data.sublist(startIndex, endIndex);
  }

  List<Ohlcv> sublist(int start, [int? end]) => _data.sublist(start, end);

  /// n本のローソク足を1本にマージして新しい [OhlcvSeries] を返します
  ///
  /// [n] マージするローソク足の本数
  /// [alignment] グループの起点方向
  ///   - [MergeAlignment.left]: 古いデータから順にグループ化（デフォルト）
  ///   - [MergeAlignment.right]: 新しいデータから順にグループ化
  /// [mode] 端数（n本に満たないチャンク）の扱い
  ///   - [MergeMode.strict]: 端数を捨てる（デフォルト）
  ///   - [MergeMode.partial]: 端数も含める
  ///
  /// マージルール:
  ///   open   = チャンク最初の open
  ///   high   = チャンク内の high の最大値
  ///   low    = チャンク内の low の最小値
  ///   close  = チャンク最後の close
  ///   volume = チャンク内の volume の合計
  OhlcvSeries merge(
    int n, {
    MergeAlignment alignment = MergeAlignment.left,
    MergeMode mode = MergeMode.strict,
  }) {
    if (n <= 0) throw ArgumentError('n must be greater than 0');
    if (_data.isEmpty) return OhlcvSeries(data: []);
    if (n == 1) return OhlcvSeries(data: List.of(_data));

    final rawChunks = <List<Ohlcv>>[];

    if (alignment == MergeAlignment.left) {
      for (var i = 0; i < _data.length; i += n) {
        rawChunks.add(_data.sublist(i, (i + n).clamp(0, _data.length)));
      }
    } else {
      for (var i = _data.length; i > 0; i -= n) {
        rawChunks.add(_data.sublist((i - n).clamp(0, _data.length), i));
      }
      rawChunks.sort(
        (a, b) => a.first.openTimestamp.compareTo(b.first.openTimestamp),
      );
    }

    final chunks = mode == MergeMode.strict
        ? rawChunks.where((c) => c.length == n).toList()
        : rawChunks;

    final merged = chunks.map((chunk) {
      return Ohlcv(
        open: chunk.first.open,
        high: chunk.map((e) => e.high).reduce((a, b) => a > b ? a : b),
        low: chunk.map((e) => e.low).reduce((a, b) => a < b ? a : b),
        close: chunk.last.close,
        volume: chunk.fold(0, (sum, e) => sum + e.volume),
        openTimestamp: chunk.first.openTimestamp,
        closeTimestamp: chunk.last.closeTimestamp,
      );
    }).toList();

    return OhlcvSeries(data: merged);
  }
}
