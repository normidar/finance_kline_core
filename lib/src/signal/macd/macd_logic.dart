import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/macd/macd_params.dart';
import 'package:finance_kline_core/src/signal/macd/macd_series.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';

/// [MacdParams] に基づいてMACDを計算する [SignalLogic]
///
/// ```dart
/// final params = MacdParams(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9);
/// final logic = MacdLogic();
/// final result = logic.calculate(
///   params: params,
///   data: closes,
/// ) as MacdSeries;
///
/// if (result.isBullishCross) {
///   // ゴールデンクロス → 買いシグナル
/// }
/// ```
class MacdLogic extends SignalLogic {
  @override
  MacdSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final macdParams = params as MacdParams;
    return MacdSeries(
      data: data.macd(
        fastPeriod: macdParams.fastPeriod,
        slowPeriod: macdParams.slowPeriod,
        signalPeriod: macdParams.signalPeriod,
      ),
    );
  }
}
