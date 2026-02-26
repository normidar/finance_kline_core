import 'dart:convert';
import 'dart:io';

import 'package:finance_kline_core/finance_kline_core.dart';

void main(List<String> args) {
  final dir = args.isNotEmpty ? args[0] : 'test/fixtures';

  print('Analyzing: $dir');

  final wrapper = MultiIntervalWrapper(
    compactSeriesMap: {
      Interval.$1h: CompactLogic().calculate(
        klineSeries: loadCsv('$dir/kline_1h.csv'),
        priceType: PriceType.close,
        params: CompactParams(
          emaParams: EmaParams(periods: {12, 26}),
          rsiParams: RsiParams(periods: {14}),
          macdParams: MacdParams(),
        ),
      ),
      Interval.$5m: CompactLogic().calculate(
        klineSeries: loadCsv('$dir/kline_5m.csv'),
        priceType: PriceType.close,
        params: CompactParams(
          emaParams: EmaParams(periods: {12, 26}),
          rsiParams: RsiParams(periods: {14}),
          macdParams: MacdParams(),
        ),
      ),
      Interval.$15m: CompactLogic().calculate(
        klineSeries: loadCsv('$dir/kline_15m.csv'),
        priceType: PriceType.close,
        params: CompactParams(
          emaParams: EmaParams(periods: {12, 26}),
          rsiParams: RsiParams(periods: {14}),
          macdParams: MacdParams(),
        ),
      ),
    },
  );

  final results = wrapper.analyze<Map<String, dynamic>>(
    moveInterval: Interval.$15m,
    moveSize: 200,
    onAnalyze: analyzeFunction,
  );
  // 結果をJSONファイルに保存
  final jsonFile = File('results.json');
  const encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(results));
  print('Results saved to results.json');
  analyzeProfit(results);
}

Map<String, dynamic> analyzeFunction(MultiIntervalWrapper wrapper) {
  const interval15m = Interval.$15m;
  const interval1h = Interval.$1h;

  final s15m = wrapper.compactSeriesMap[interval15m];
  final s1h = wrapper.compactSeriesMap[interval1h];

  // 1h: MACD トレンド方向
  final h1MacdBullish = s1h?.macd.last?.isBullish ?? false;
  final h1MacdBearish = s1h?.macd.last?.isBearish ?? false;

  // 15m: RSI14
  final rsiList = s15m?.rsi[14];
  final rsi14 =
      (rsiList != null && rsiList.isNotEmpty) ? rsiList.last?.value : null;

  // ロング: 1h強気 + 15m MACDクロス + RSI < 65
  final longEntry = s15m?.macd.isBullishCross == true &&
      h1MacdBullish &&
      (rsi14 == null || rsi14 < 65);

  // ロング出口: 15m MACDデッドクロス
  final longExit = s15m?.macd.isBearishCross == true;

  // ショート: 1h弱気 + 15m MACDデッドクロス + RSI > 35
  final shortEntry = s15m?.macd.isBearishCross == true &&
      h1MacdBearish &&
      (rsi14 == null || rsi14 > 35);

  // ショート出口: 15m MACDゴールデンクロス
  final shortExit = s15m?.macd.isBullishCross == true;

  return {
    'long_entry': longEntry,
    'long_exit': longExit,
    'short_entry': shortEntry,
    'short_exit': shortExit,
    'timestamp': s15m?.kline.units.last.closeTimestamp,
    'price': s15m?.kline.units.last.close,
    'rsi14': rsi14,
    'h1_macd_bullish': h1MacdBullish,
  };
}

void analyzeProfit(List<Map<String, dynamic>> results) {
  const double stopLossRate = 0.015; // 1.5% 損切りライン

  double cash = 1000;
  double qty = 0; // 保有量 (ロングなら正, ショートなら負)
  double entryPrice = 0;
  _Side side = _Side.none;

  int wins = 0;
  int losses = 0;
  int stopLossCount = 0;
  double maxProfit = double.negativeInfinity;
  double maxLoss = double.infinity;

  String fmtTime(dynamic ts) {
    if (ts == null) return '??-??-?? ??:??';
    final dt = DateTime.fromMillisecondsSinceEpoch(
      (ts as num).toInt(),
      isUtc: true,
    ).toLocal();
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }

  void closeTrade(double price, String reason, dynamic ts) {
    double pnlPct;
    if (side == _Side.long) {
      cash = qty * price;
      pnlPct = (price - entryPrice) / entryPrice * 100;
    } else {
      // ショート: 損益 = (entryPrice - price) / entryPrice
      final shortPnl = (entryPrice - price) / entryPrice;
      cash = cash * (1 + shortPnl);
      pnlPct = shortPnl * 100;
    }
    qty = 0;
    side = _Side.none;
    if (pnlPct >= 0) {
      wins++;
      if (pnlPct > maxProfit) maxProfit = pnlPct;
    } else {
      losses++;
      if (pnlPct < maxLoss) maxLoss = pnlPct;
    }
    print(
      '${fmtTime(ts)}  $reason @ ${price.toStringAsFixed(2)}  cash=\$${cash.toStringAsFixed(2)}  pnl=${pnlPct.toStringAsFixed(2)}%',
    );
  }

  for (final r in results) {
    final price = (r['price'] as num?)?.toDouble();
    if (price == null || price <= 0) continue;
    final ts = r['timestamp'];

    // 損切り判定
    if (side == _Side.long && price <= entryPrice * (1 - stopLossRate)) {
      stopLossCount++;
      closeTrade(price, 'STOP_L', ts);
    } else if (side == _Side.short &&
        price >= entryPrice * (1 + stopLossRate)) {
      stopLossCount++;
      closeTrade(price, 'STOP_S', ts);
    }

    // ロング決済
    if (side == _Side.long && r['long_exit'] == true) {
      closeTrade(price, 'SELL  ', ts);
    }
    // ショート決済
    if (side == _Side.short && r['short_exit'] == true) {
      closeTrade(price, 'COVER ', ts);
    }

    // ロングエントリー
    if (side == _Side.none && r['long_entry'] == true) {
      side = _Side.long;
      entryPrice = price;
      qty = cash / price;
      cash = 0.0;
      print('${fmtTime(ts)}  BUY   @ ${price.toStringAsFixed(2)}');
    }
    // ショートエントリー
    else if (side == _Side.none && r['short_entry'] == true) {
      side = _Side.short;
      entryPrice = price;
      // ショートはcashをそのまま担保に使う
      print('${fmtTime(ts)}  SHORT @ ${price.toStringAsFixed(2)}');
    }
  }

  // 未決済ポジション
  final lastTs = results.last['timestamp'];
  final lastPrice = (results.last['price'] as num?)?.toDouble() ?? 0.0;
  if (side != _Side.none) {
    double pnlPct;
    double finalVal;
    if (side == _Side.long) {
      pnlPct = (lastPrice - entryPrice) / entryPrice * 100;
      finalVal = qty * lastPrice;
    } else {
      pnlPct = (entryPrice - lastPrice) / entryPrice * 100;
      finalVal = cash * (1 + (entryPrice - lastPrice) / entryPrice);
    }
    if (pnlPct >= 0) {
      wins++;
      if (pnlPct > maxProfit) maxProfit = pnlPct;
    } else {
      losses++;
      if (pnlPct < maxLoss) maxLoss = pnlPct;
    }
    print(
      '${fmtTime(lastTs)}  OPEN(${side.name}) @ $lastPrice (unrealized)  pnl=${pnlPct.toStringAsFixed(2)}%',
    );
    cash = finalVal;
  }

  final finalValue = side == _Side.none ? cash : cash;
  final totalTrades = wins + losses;
  final winRate = totalTrades > 0 ? wins / totalTrades * 100 : 0.0;
  final lossRate = totalTrades > 0 ? losses / totalTrades * 100 : 0.0;

  print('');
  print('=== Statistics ===');
  print('Stop-loss rate     : ${(stopLossRate * 100).toStringAsFixed(1)}%');
  print('Total trades       : $totalTrades');
  print('Wins               : $wins  (${winRate.toStringAsFixed(1)}%)');
  print('Losses             : $losses  (${lossRate.toStringAsFixed(1)}%)');
  print('  Stop-losses      : $stopLossCount');
  print(
    'Max profit         : ${maxProfit == double.negativeInfinity ? "N/A" : "${maxProfit.toStringAsFixed(2)}%"}',
  );
  print(
    'Max loss           : ${maxLoss == double.infinity ? "N/A" : "${maxLoss.toStringAsFixed(2)}%"}',
  );
  print('Final equity       : \$${finalValue.toStringAsFixed(2)}');
  print(
    'Return             : ${((finalValue / 1000.0 - 1) * 100).toStringAsFixed(2)}%',
  );
}

KlineSeries loadCsv(String path) {
  final lines = File(path).readAsLinesSync();
  final units = <Kline>[];
  for (final line in lines.skip(1)) {
    final p = line.split(',');
    units.add(
      Kline(
        openTimestamp: int.parse(p[0]),
        open: double.parse(p[1]),
        high: double.parse(p[2]),
        low: double.parse(p[3]),
        close: double.parse(p[4]),
        volume: double.parse(p[5]),
        closeTimestamp: int.parse(p[6]),
      ),
    );
  }
  return KlineSeries(units: units);
}

// ポジション方向
enum _Side { none, long, short }
