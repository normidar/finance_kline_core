import 'package:finance_kline_core/finance_kline_core.dart';

/// 線形数列
class LinearSignalSeries<T extends SignalUnit> extends SignalSeries {
  LinearSignalSeries({
    required this.units,
  });

  final List<T> units;

  LinearSignalSeries<T> subByTimestamp({int? start, int? end}) {
    if (units.length < 2) throw UnsupportedError('data lenght must over 2');
    var endIndex = units.length - 1;
    var startIndex = 0;
    if (end != null) {
      final lastClose = units.last.closeTimestamp;
      final diff = lastClose - end;
      if (diff < 0) throw UnsupportedError('end over lastCode');
      final interval = units[1].closeTimestamp - units[0].closeTimestamp;
      endIndex = units.length - diff ~/ interval;
    }
    if (start != null) {
      final firstOpen = units[0].openTimestamp;
      final diff = start - firstOpen;
      if (diff < 0) throw UnsupportedError('start before firstCode');
      final interval = units[1].openTimestamp - units[0].openTimestamp;
      startIndex = diff ~/ interval;
    }
    return LinearSignalSeries<T>(units: units.sublist(startIndex, endIndex));
  }

  @override
  LinearSignalSeries<T> sublist({int? start, int? end}) {
    return LinearSignalSeries<T>(units: units.sublist(start ?? 0, end));
  }
}

abstract class SignalLogic {
  /// 指定したパラメータでシリーズを計算する
  /// 例えばEMAを計算する場合はclosesをdataとして渡す
  /// paramsはEMAのparamsを渡す
  SignalSeries calculate({
    required SignalParams params,
    required List<double> data,
  });

  SignalSeries calculateWithKline({
    required Series klineSeries,
    required PriceType priceType,
    required SignalParams params,
  }) => calculate(params: params, data: klineSeries.prices(priceType));
}

abstract class SignalParams {}

/// 疑似的な数列
abstract class SignalSeries {
  /// 指定した範囲のシリーズを取得する
  SignalSeries sublist({int? start, int? end});
}

/// 線形数列の中の1つのデータ
abstract class SignalUnit {
  SignalUnit({
    required this.openTimestamp,
    required this.closeTimestamp,
  });
  final int openTimestamp;

  final int closeTimestamp;
}
