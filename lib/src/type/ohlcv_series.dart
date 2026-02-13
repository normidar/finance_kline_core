import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/type/series.dart';

class OhlcvSeries extends Series {
  final List<Ohlcv> _data;

  OhlcvSeries({required List<Ohlcv> data}) : _data = data;

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
}
