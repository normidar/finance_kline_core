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
  final encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(results));
  print('Results saved to results.json');
}

Map<String, dynamic> analyzeFunction(MultiIntervalWrapper wrapper) {
  return {
    'macd_bullish_cross':
        wrapper.compactSeriesMap[Interval.$5m]?.macd.isBullishCross,
    'macd_bearish_cross':
        wrapper.compactSeriesMap[Interval.$5m]?.macd.isBearishCross,
    'timestamp':
        wrapper.compactSeriesMap[Interval.$5m]?.kline.units.last.closeTimestamp,
  };
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
