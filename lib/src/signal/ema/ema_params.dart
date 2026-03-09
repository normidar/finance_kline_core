import 'package:finance_kline_core/src/signal/interface.dart';

class EmaParams extends SignalParams {
  final Set<int> periods;

  EmaParams({
    required this.periods,
  });
}
