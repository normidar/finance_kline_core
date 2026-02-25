import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/signal/macd/macd_params.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';
import 'package:finance_kline_core/src/type/macd/macd.dart';

/// MACDの計算結果を保持するシリーズ
class MacdSignalSeries extends SignalSeries {
  final MacdSeries data;

  MacdSignalSeries({required this.data});

  /// 最後のMACD値を返します（データ不足時は null）
  Macd? get last => data.isEmpty ? null : data.last;

  /// MACDラインがシグナルラインを上抜けした（ゴールデンクロス）かを判定します
  ///
  /// 直前のバーでは macdLine <= signalLine、現在のバーでは macdLine > signalLine
  bool get isBullishCross {
    if (data.length < 2) return false;
    final prev = data[data.length - 2];
    final curr = data[data.length - 1];
    if (prev == null || curr == null) return false;
    return prev.macdLine <= prev.signalLine && curr.macdLine > curr.signalLine;
  }

  /// MACDラインがシグナルラインを下抜けした（デッドクロス）かを判定します
  ///
  /// 直前のバーでは macdLine >= signalLine、現在のバーでは macdLine < signalLine
  bool get isBearishCross {
    if (data.length < 2) return false;
    final prev = data[data.length - 2];
    final curr = data[data.length - 1];
    if (prev == null || curr == null) return false;
    return prev.macdLine >= prev.signalLine && curr.macdLine < curr.signalLine;
  }

  @override
  MacdSignalSeries sublist({int? start, int? end}) =>
      MacdSignalSeries(data: data.sublist(start ?? 0, end));
}

/// [MacdParams] に基づいてMACDを計算する [SignalLogic]
///
/// ```dart
/// final params = MacdParams(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9);
/// final logic = MacdLogic();
/// final result = logic.calculate(
///   params: params,
///   data: closes,
/// ) as MacdSignalSeries;
///
/// if (result.isBullishCross) {
///   // ゴールデンクロス → 買いシグナル
/// }
/// ```
class MacdLogic extends SignalLogic {
  @override
  MacdSignalSeries calculate({
    required SignalParams params,
    required List<double> data,
  }) {
    final macdParams = params as MacdParams;
    return MacdSignalSeries(
      data: data.macd(
        fastPeriod: macdParams.fastPeriod,
        slowPeriod: macdParams.slowPeriod,
        signalPeriod: macdParams.signalPeriod,
      ),
    );
  }
}
