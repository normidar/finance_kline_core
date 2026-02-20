import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/type/series.dart';

class OhlcvSeries extends Series {
  final List<Ohlcv> _data;

  OhlcvSeries({
    required List<Ohlcv> data,
    super.ema,
    super.macd,
    super.rsi,
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

  Ohlcv operator [](int index) => _data[index];

  List<Ohlcv> sublist(int start, [int? end]) => _data.sublist(start, end);

  List<Ohlcv> subByTimestamp({int? start, int? end}) {
    if (_data.length < 2) throw UnsupportedError('data lenght must over 2');
    var endIndex = _data.length - 1;
    var startIndex = 0;
    if (end != null) {
      final lastClose = _data.last.closeTimestamp;
      final diff = lastClose - end;
      if (diff < 0) throw UnsupportedError('end over lastCode');
      final interval = _data[1].closeTimestamp - _data[0].closeTimestamp;
      endIndex = _data.length - diff ~/ interval - 1;
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
}
