import 'package:finance_kline_core/src/signal/interface.dart';

/// RSI計算のパラメータ
class RsiParams extends SignalParams {
  /// 計算する期間のセット
  final Set<int> periods;

  RsiParams({
    required this.periods,
  });
}
