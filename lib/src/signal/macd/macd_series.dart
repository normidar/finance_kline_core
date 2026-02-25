import 'package:finance_kline_core/src/signal/interface.dart';
import 'package:finance_kline_core/src/type/macd/macd.dart';

/// MACDの計算結果を保持するシリーズ
class MacdSeries extends SignalSeries {
  final List<Macd?> data;

  MacdSeries({required this.data});

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
  MacdSeries sublist({int? start, int? end}) =>
      MacdSeries(data: data.sublist(start ?? 0, end));
}
