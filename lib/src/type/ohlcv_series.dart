import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/type/series.dart';

class OhlcvSeries with Series {
  final List<Ohlcv> data;

  OhlcvSeries(this.data);

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

  DecList get volumes => data.map((e) => e.volume).toList();

  Ohlcv operator [](int index) => data[index];

  List<Ohlcv> sublist(int start, [int? end]) => data.sublist(start, end);
}
