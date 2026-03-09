import 'package:finance_kline_core/finance_kline_core.dart';

class CompactParams extends SignalParams {
  CompactParams({
    required this.emaParams,
    required this.rsiParams,
    required this.macdParams,
  });
  final EmaParams emaParams;
  final RsiParams rsiParams;
  final MacdParams macdParams;
}
