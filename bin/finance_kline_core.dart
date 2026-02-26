import 'dart:convert';
import 'dart:io';

import 'package:finance_kline_core/finance_kline_core.dart';

void main() {
  final wrapper = MultiIntervalWrapper(
    compactSeriesMap: {
      Interval.$1h: CompactLogic().calculate(
        klineSeries: loadCsv('test/fixtures/kline_1h.csv'),
        priceType: PriceType.close,
        params: CompactParams(
          emaParams: EmaParams(periods: {12, 26}),
          rsiParams: RsiParams(periods: {14}),
          macdParams: MacdParams(),
        ),
      ),
      Interval.$5m: CompactLogic().calculate(
        klineSeries: loadCsv('test/fixtures/kline_5m.csv'),
        priceType: PriceType.close,
        params: CompactParams(
          emaParams: EmaParams(periods: {12, 26}),
          rsiParams: RsiParams(periods: {14}),
          macdParams: MacdParams(),
        ),
      ),
      Interval.$15m: CompactLogic().calculate(
        klineSeries: loadCsv('test/fixtures/kline_15m.csv'),
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
    moveInterval: Interval.$5m,
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
  return {
    'macd_bullish_cross':
        wrapper.compactSeriesMap[Interval.$5m]?.macd.isBullishCross,
    'macd_bearish_cross':
        wrapper.compactSeriesMap[Interval.$5m]?.macd.isBearishCross,
    'timestamp':
        wrapper.compactSeriesMap[Interval.$5m]?.kline.units.last.closeTimestamp,
    'price': wrapper.compactSeriesMap[Interval.$5m]?.kline.units.last.close,
  };
}

void analyzeProfit(List<Map<String, dynamic>> results) {
  double cash = 1000.0;
  double holdings = 0.0;
  double buyPrice = 0.0;

  int wins = 0;
  int losses = 0;
  double maxProfit = double.negativeInfinity;
  double maxLoss = double.infinity;

  for (final r in results) {
    final price = (r['price'] as num?)?.toDouble();
    if (price == null || price <= 0) continue;

    if (r['macd_bullish_cross'] == true && cash > 0) {
      buyPrice = price;
      holdings = cash / price;
      cash = 0.0;
      print('BUY  @ $price  holdings=${holdings.toStringAsFixed(6)}');
    } else if (r['macd_bearish_cross'] == true && holdings > 0) {
      cash = holdings * price;
      holdings = 0.0;

      final pnlAlt = price - buyPrice; // 1単位あたりの損益
      if (pnlAlt >= 0) {
        wins++;
        if (pnlAlt > maxProfit) maxProfit = pnlAlt;
      } else {
        losses++;
        if (pnlAlt < maxLoss) maxLoss = pnlAlt;
      }

      print('SELL @ $price  cash=\$${cash.toStringAsFixed(2)}  pnl/unit=${pnlAlt.toStringAsFixed(4)}');
    }
  }

  // 未決済ポジションがあれば最終価格で評価
  final lastPrice = (results.last['price'] as num?)?.toDouble() ?? 0.0;
  if (holdings > 0) {
    final pnlAlt = lastPrice - buyPrice;
    if (pnlAlt >= 0) {
      wins++;
      if (pnlAlt > maxProfit) maxProfit = pnlAlt;
    } else {
      losses++;
      if (pnlAlt < maxLoss) maxLoss = pnlAlt;
    }
    print('OPEN @ $lastPrice (未決済評価)  pnl/unit=${pnlAlt.toStringAsFixed(4)}');
  }

  final finalValue = cash + holdings * lastPrice;
  final totalTrades = wins + losses;
  final winRate = totalTrades > 0 ? wins / totalTrades * 100 : 0.0;
  final lossRate = totalTrades > 0 ? losses / totalTrades * 100 : 0.0;

  print('');
  print('=== 統計 ===');
  print('総トレード数       : $totalTrades');
  print('勝ち               : $wins  (${winRate.toStringAsFixed(1)}%)');
  print('負け               : $losses  (${lossRate.toStringAsFixed(1)}%)');
  print('最大利益 (1単位)   : ${maxProfit == double.negativeInfinity ? "N/A" : "\$${maxProfit.toStringAsFixed(4)}"}');
  print('最大損失 (1単位)   : ${maxLoss == double.infinity ? "N/A" : "\$${maxLoss.toStringAsFixed(4)}"}');
  print('最終資産           : \$${finalValue.toStringAsFixed(2)}');
  print('リターン           : ${((finalValue / 1000.0 - 1) * 100).toStringAsFixed(2)}%');
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
