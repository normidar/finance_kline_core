import 'package:finance_kline_core/src/signal/interface.dart';

/// 複数期間のEMAをまとめて保持するシリーズ
///
/// ```dart
/// final series = EmaSeries(values: {12: [...], 26: [...]});
/// final ema12 = series[12]; // 12期間EMAの値リスト
/// ```
class EmaSeries extends SignalSeries {
  /// {period: EMA値リスト} のマップ
  final Map<int, List<double?>> values;

  EmaSeries({required this.values});

  /// 指定した期間のEMA値リストを返します
  List<double?> operator [](int period) => values[period] ?? [];

  /// fast EMA が slow EMA を下から上に突き抜けた（ゴールデンクロス）かを判定します
  ///
  /// 直前のバーで fast <= slow かつ現在のバーで fast > slow のとき true。
  /// 指定した期間が計算されていない場合は false を返します。
  bool isBullishCross({required int fast, required int slow}) {
    final fastValues = values[fast];
    final slowValues = values[slow];
    if (fastValues == null || slowValues == null) return false;
    if (fastValues.length < 2 || slowValues.length < 2) return false;
    final prevFast = fastValues[fastValues.length - 2];
    final currFast = fastValues[fastValues.length - 1];
    final prevSlow = slowValues[slowValues.length - 2];
    final currSlow = slowValues[slowValues.length - 1];
    if (prevFast == null || currFast == null ||
        prevSlow == null || currSlow == null) return false;
    return prevFast <= prevSlow && currFast > currSlow;
  }

  /// fast EMA が slow EMA を上から下に突き抜けた（デッドクロス）かを判定します
  ///
  /// 直前のバーで fast >= slow かつ現在のバーで fast < slow のとき true。
  /// 指定した期間が計算されていない場合は false を返します。
  bool isBearishCross({required int fast, required int slow}) {
    final fastValues = values[fast];
    final slowValues = values[slow];
    if (fastValues == null || slowValues == null) return false;
    if (fastValues.length < 2 || slowValues.length < 2) return false;
    final prevFast = fastValues[fastValues.length - 2];
    final currFast = fastValues[fastValues.length - 1];
    final prevSlow = slowValues[slowValues.length - 2];
    final currSlow = slowValues[slowValues.length - 1];
    if (prevFast == null || currFast == null ||
        prevSlow == null || currSlow == null) return false;
    return prevFast >= prevSlow && currFast < currSlow;
  }

  @override
  EmaSeries sublist({int? start, int? end}) => EmaSeries(
        values: {
          for (final entry in values.entries)
            entry.key: entry.value.sublist(start ?? 0, end),
        },
      );
}
