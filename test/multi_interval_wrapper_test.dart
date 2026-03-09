import 'dart:io';
import 'dart:math' as math;

import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

// ─── サンプル分析ヘルパー ────────────────────────────────────────────────────

/// 1本あたりの平均値幅率 = mean((high - low) / open * 100) をローソク足全本で計算
double _avgCandleVolatility(KlineSeries kline) {
  if (kline.units.isEmpty) return 0;
  final sum = kline.units.fold<double>(
    0,
    (acc, k) => acc + (k.high - k.low) / k.open * 100,
  );
  return sum / kline.units.length;
}

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

  // ─── サンプル 1: 5m と 15m の変動率の差 ─────────────────────────────────
  //
  // 「1本あたり平均値幅率」= mean((high - low) / open * 100)
  // 5m のほうが 1 本あたりの範囲は小さいため、差は基本的に負になる。
  // moveInterval=$1h / moveSize=24 で 1 日窓ずつスライドしながら差を計算。

  group('サンプル 1: 5m 変動率 − 15m 変動率の差', () {
    late List<double> diffs;

    setUpAll(() {
      diffs = wrapper.analyze<double>(
        moveInterval: Interval.$1h,
        moveSize: 24,
        onAnalyze: (w) {
          final v5m = _avgCandleVolatility(
            w.compactSeriesMap[Interval.$5m]!.kline,
          );
          final v15m = _avgCandleVolatility(
            w.compactSeriesMap[Interval.$15m]!.kline,
          );
          return v5m - v15m;
        },
      );
    });

    test('結果件数が正しい', () {
      expect(diffs.length, kline1h.units.length - 24 + 1);
    });

    test('全値が有限値（NaN / Inf なし）', () {
      expect(diffs.every((d) => d.isFinite), isTrue);
    });

    test('5m の 1 本あたり変動率は 15m より小さい（差は負）ケースが大多数', () {
      // 1本あたりの値幅は時間足が長いほど大きいのが自然
      final negativeCount = diffs.where((d) => d < 0).length;
      expect(negativeCount, greaterThan(diffs.length ~/ 2));
    });

    test('差の絶対値は小さい（%単位で 1 未満が大多数）', () {
      // 同じ相場を見ているので極端な乖離はない
      final smallCount = diffs.where((d) => d.abs() < 1.0).length;
      expect(smallCount, greaterThan(diffs.length ~/ 2));
    });

    test('差の最大値・最小値を出力（目視確認用）', () {
      final maxDiff = diffs.reduce(math.max);
      final minDiff = diffs.reduce(math.min);
      // ignore: avoid_print
      print('5m-15m volatility diff  max=$maxDiff  min=$minDiff');
      expect(maxDiff, isNotNull); // 出力のみ、常に pass
    });
  });

  // ─── サンプル 2: 1h MACD クロス検出 ────────────────────────────────────
  //
  // moveInterval=$1h / moveSize=48 (2 日窓) で各バッチ末尾 2 本の
  // ゴールデンクロス / デッドクロスを検出する。

  group('サンプル 2: 1h MACD ゴールデンクロス / デッドクロス検出', () {
    late List<({bool bullish, bool bearish})> crosses;

    setUpAll(() {
      crosses = wrapper.analyze(
        moveInterval: Interval.$1h,
        moveSize: 48, // 2日分のウォームアップを含む
        onAnalyze: (w) {
          final macd = w.compactSeriesMap[Interval.$1h]!.macd;
          return (bullish: macd.isBullishCross, bearish: macd.isBearishCross);
        },
      );
    });

    test('結果件数が正しい', () {
      expect(crosses.length, kline1h.units.length - 48 + 1);
    });

    test('1 ヶ月間に少なくとも 1 回のゴールデンクロスが存在する', () {
      expect(crosses.any((c) => c.bullish), isTrue);
    });

    test('1 ヶ月間に少なくとも 1 回のデッドクロスが存在する', () {
      expect(crosses.any((c) => c.bearish), isTrue);
    });

    test('同一バッチでゴールデンとデッドが同時に true にならない', () {
      expect(crosses.every((c) => !(c.bullish && c.bearish)), isTrue);
    });

    test('クロス回数を出力（目視確認用）', () {
      final bullCount = crosses.where((c) => c.bullish).length;
      final bearCount = crosses.where((c) => c.bearish).length;
      // ignore: avoid_print
      print('MACD crosses  bullish=$bullCount  bearish=$bearCount');
      expect(bullCount + bearCount, greaterThan(0));
    });
  });

  // ─── サンプル 3: 1h RSI 過熱 / 売られすぎ検出 ─────────────────────────
  //
  // RSI(14) > 70 = 買われすぎ、< 30 = 売られすぎ。
  // moveInterval=$1h / moveSize=24 の各バッチ末尾 RSI 状態を返す。

  group('サンプル 3: 1h RSI 状態ラベル付け', () {
    late List<RsiState> states;

    setUpAll(() {
      states = wrapper.analyze<RsiState>(
        moveInterval: Interval.$1h,
        moveSize: 24,
        onAnalyze: (w) =>
            w.compactSeriesMap[Interval.$1h]!.rsi.stateOf(14),
      );
    });

    test('結果件数が正しい', () {
      expect(states.length, kline1h.units.length - 24 + 1);
    });

    test('全要素が RsiState のいずれか', () {
      expect(states.every(RsiState.values.contains), isTrue);
    });

    test('状態分布を出力（目視確認用）', () {
      final counts = <RsiState, int>{};
      for (final s in states) counts[s] = (counts[s] ?? 0) + 1;
      // ignore: avoid_print
      print('RSI states: $counts');
      expect(counts, isNotEmpty);
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
