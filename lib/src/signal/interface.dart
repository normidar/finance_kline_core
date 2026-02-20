import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:finance_kline_core/src/enum/price_type.dart';

abstract class SignalLogic {
  SignalSeries calculate({
    required SignalParams params,
    required List<double> data,
  });

  SignalSeries calculateWithKline({
    required Series klineSeries,
    required PriceType priceType,
    required SignalParams params,
  }) =>
      calculate(params: params, data: klineSeries.prices(priceType));
}

abstract class SignalParams {}

abstract class SignalSeries {
  SignalSeries cut({int? start, int? end});
}
