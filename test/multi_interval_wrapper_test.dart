import 'dart:io';

import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

// ─── CSV ローダー ────────────────────────────────────────────────────────────

KlineSeries _loadCsv(String path) {
  final lines = File(path).readAsLinesSync();
  final units = <Kline>[];
  for (final line in lines.skip(1)) {
    // skip header
    final p = line.split(',');
    units.add(Kline(
      openTimestamp: int.parse(p[0]),
      open: double.parse(p[1]),
      high: double.parse(p[2]),
      low: double.parse(p[3]),
      close: double.parse(p[4]),
      volume: double.parse(p[5]),
      closeTimestamp: int.parse(p[6]),
    ));
  }
  return KlineSeries(units: units);
}

CompactSeries _toCompact(KlineSeries kline) => CompactLogic().calculate(
      klineSeries: kline,
      priceType: PriceType.close,
      params: CompactParams(
        emaParams: EmaParams(periods: {12, 26}),
        rsiParams: RsiParams(periods: {14}),
        macdParams: MacdParams(),
      ),
    );

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MultiIntervalWrapper wrapper;
  late KlineSeries kline5m;
  late KlineSeries kline15m;
  late KlineSeries kline1h;

  setUpAll(() {
    kline5m = _loadCsv('test/fixtures/kline_5m.csv');
    kline15m = _loadCsv('test/fixtures/kline_15m.csv');
    kline1h = _loadCsv('test/fixtures/kline_1h.csv');

    wrapper = MultiIntervalWrapper(
      compactSeriesMap: {
        Interval.$5m: _toCompact(kline5m),
        Interval.$15m: _toCompact(kline15m),
        Interval.$1h: _toCompact(kline1h),
      },
    );
  });

  // ─── CSVロード検証 ───────────────────────────────────────────────────────

  group('CSVデータ整合性', () {
    test('5m は 15m の 3 倍の本数', () {
      expect(kline5m.units.length, kline15m.units.length * 3);
    });

    test('15m は 1h の 4 倍の本数', () {
      expect(kline15m.units.length, kline1h.units.length * 4);
    });

    test('全 Interval の openTimestamp が一致', () {
      expect(kline5m.units.first.openTimestamp,
          kline15m.units.first.openTimestamp);
      expect(kline15m.units.first.openTimestamp,
          kline1h.units.first.openTimestamp);
    });

    test('全 Interval の closeTimestamp が一致', () {
      expect(
          kline5m.units.last.closeTimestamp, kline15m.units.last.closeTimestamp);
      expect(
          kline15m.units.last.closeTimestamp, kline1h.units.last.closeTimestamp);
    });
  });

  // ─── analyze: 基本動作 ───────────────────────────────────────────────────

  group('analyze / moveInterval=\$1h / moveSize=24', () {
    late List<MultiIntervalWrapper> results;
    const moveSize = 24;

    setUpAll(() {
      results = wrapper.analyze(
        moveInterval: Interval.$1h,
        moveSize: moveSize,
        onAnalyze: (w) => w,
      );
    });

    test('結果件数 = 1h本数 - moveSize + 1', () {
      expect(results.length, kline1h.units.length - moveSize + 1);
    });

    test('先頭バッチ: openTimestamp が元データの先頭と一致', () {
      final first = results.first.compactSeriesMap[Interval.$1h]!;
      expect(
        first.kline.units.first.openTimestamp,
        kline1h.units.first.openTimestamp,
      );
    });

    test('先頭バッチ: closeTimestamp が moveSize 本目の closeTimestamp と一致', () {
      final first = results.first.compactSeriesMap[Interval.$1h]!;
      expect(
        first.kline.units.last.closeTimestamp,
        kline1h.units[moveSize - 1].closeTimestamp,
      );
    });

    test('先頭バッチ: 1h シリーズが moveSize 本', () {
      final first = results.first.compactSeriesMap[Interval.$1h]!;
      expect(first.kline.units.length, moveSize);
    });

    test('先頭バッチ: 5m シリーズが moveSize * 12 本', () {
      final first = results.first.compactSeriesMap[Interval.$5m]!;
      expect(first.kline.units.length, moveSize * 12);
    });

    test('先頭バッチ: 15m シリーズが moveSize * 4 本', () {
      final first = results.first.compactSeriesMap[Interval.$15m]!;
      expect(first.kline.units.length, moveSize * 4);
    });

    test('スライディング: 2番目バッチの openTimestamp が 1h[1] と一致', () {
      final second = results[1].compactSeriesMap[Interval.$1h]!;
      expect(
        second.kline.units.first.openTimestamp,
        kline1h.units[1].openTimestamp,
      );
    });

    test('スライディング: 2番目バッチの closeTimestamp が 1h[moveSize] と一致', () {
      final second = results[1].compactSeriesMap[Interval.$1h]!;
      expect(
        second.kline.units.last.closeTimestamp,
        kline1h.units[moveSize].closeTimestamp,
      );
    });

    test('末尾バッチ: closeTimestamp が元データの末尾と一致', () {
      final last = results.last.compactSeriesMap[Interval.$1h]!;
      expect(
        last.kline.units.last.closeTimestamp,
        kline1h.units.last.closeTimestamp,
      );
    });

    test('全バッチで各 Interval のシリーズが null でない', () {
      for (final w in results) {
        expect(w.compactSeriesMap[Interval.$5m], isNotNull);
        expect(w.compactSeriesMap[Interval.$15m], isNotNull);
        expect(w.compactSeriesMap[Interval.$1h], isNotNull);
      }
    });
  });

  // ─── analyze: 別 moveInterval ────────────────────────────────────────────

  group('analyze / moveInterval=\$15m / moveSize=4', () {
    const moveSize = 4;
    late List<MultiIntervalWrapper> results;

    setUpAll(() {
      results = wrapper.analyze(
        moveInterval: Interval.$15m,
        moveSize: moveSize,
        onAnalyze: (w) => w,
      );
    });

    test('結果件数 = 15m本数 - moveSize + 1', () {
      expect(results.length, kline15m.units.length - moveSize + 1);
    });

    test('先頭バッチ: 15m シリーズが moveSize 本', () {
      final first = results.first.compactSeriesMap[Interval.$15m]!;
      expect(first.kline.units.length, moveSize);
    });

    test('先頭バッチ: 5m シリーズが moveSize * 3 本', () {
      final first = results.first.compactSeriesMap[Interval.$5m]!;
      expect(first.kline.units.length, moveSize * 3);
    });
  });

  // ─── analyze: エラーケース ───────────────────────────────────────────────

  group('analyze / エラーケース', () {
    test('moveInterval が map に存在しない → ArgumentError', () {
      expect(
        () => wrapper.analyze(
          moveInterval: Interval.$4h,
          moveSize: 6,
          onAnalyze: (w) => w,
        ),
        throwsArgumentError,
      );
    });

    test('moveSize がデータ本数より大きい → 空リスト', () {
      final result = wrapper.analyze(
        moveInterval: Interval.$1h,
        moveSize: kline1h.units.length + 1,
        onAnalyze: (w) => w,
      );
      expect(result, isEmpty);
    });
  });
}
