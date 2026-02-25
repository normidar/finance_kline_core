import 'package:finance_kline_core/src/signal/ema/ema_params.dart';
import 'package:finance_kline_core/src/signal/ema/ema_series.dart';
import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';

/// [EmaParams] で指定した全期間のEMAを計算する [SignalLogic]
///
/// ```dart
/// final logic = EmaLogic();
/// final result = logic.calculate(
///   params: EmaParams(periods: {12, 26}),
///   data: closes,
/// ) as EmaSeries;
///
/// final crossAbove = result[12].last! > result[26].last!;
/// ```
class EmaLogic extends SignalLogic {
  @override
  EmaSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final emaParams = params as EmaParams;
    return EmaSeries(
      values: {
        for (final period in emaParams.periods) period: data.ema(period),
      },
    );
  }
}
