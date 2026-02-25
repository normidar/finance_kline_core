import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  final closes = List.generate(50, (i) => 100.0 + i * 0.5);

  // ─── EmaLogic ─────────────────────────────────────────────────────────────

  group('EmaLogic', () {
    test('EmaSeries を返す', () {
      expect(
        EmaLogic().calculate(
          params: EmaParams(periods: {12, 26}),
          data: closes,
        ),
        isA<EmaSeries>(),
      );
    });

    test('指定した全期間が計算される', () {
      final result = EmaLogic().calculate(
        params: EmaParams(periods: {12, 26}),
        data: closes,
      ) as EmaSeries;
      expect(result[12], hasLength(closes.length));
      expect(result[26], hasLength(closes.length));
    });

    test('未指定の期間は空リストを返す', () {
      final result = EmaLogic().calculate(
        params: EmaParams(periods: {5}),
        data: closes,
      ) as EmaSeries;
      expect(result[99], isEmpty);
    });
  });

  // ─── EmaSeries クロス検出 ──────────────────────────────────────────────────

  group('EmaSeries クロス検出', () {
    test('ゴールデンクロスを検出する', () {
      // prev: fast(9) <= slow(10) → curr: fast(11) > slow(10)
      final series = EmaSeries(
        values: {
          3: [null, null, 9.0, 11.0],
          10: [null, null, 10.0, 10.0],
        },
      );
      expect(series.isBullishCross(fast: 3, slow: 10), isTrue);
    });

    test('デッドクロスを検出する', () {
      // prev: fast(11) >= slow(10) → curr: fast(9) < slow(10)
      final series = EmaSeries(
        values: {
          3: [null, null, 11.0, 9.0],
          10: [null, null, 10.0, 10.0],
        },
      );
      expect(series.isBearishCross(fast: 3, slow: 10), isTrue);
    });

    test('既に上にある場合はゴールデンクロスでない', () {
      final series = EmaSeries(
        values: {
          3: [12.0, 11.0],
          10: [10.0, 10.0],
        },
      );
      expect(series.isBullishCross(fast: 3, slow: 10), isFalse);
    });

    test('既に下にある場合はデッドクロスでない', () {
      final series = EmaSeries(
        values: {
          3: [8.0, 9.0],
          10: [10.0, 10.0],
        },
      );
      expect(series.isBearishCross(fast: 3, slow: 10), isFalse);
    });

    test('期間が未計算の場合は false', () {
      final series = EmaSeries(values: {});
      expect(series.isBullishCross(fast: 12, slow: 26), isFalse);
      expect(series.isBearishCross(fast: 12, slow: 26), isFalse);
    });

    test('null が含まれる場合は false', () {
      final series = EmaSeries(
        values: {
          3: [null, null],
          10: [null, null],
        },
      );
      expect(series.isBullishCross(fast: 3, slow: 10), isFalse);
    });
  });

  // ─── RsiLogic ─────────────────────────────────────────────────────────────

  group('RsiLogic', () {
    test('RsiSeries を返す', () {
      expect(
        RsiLogic().calculate(params: RsiParams(period: 14), data: closes),
        isA<RsiSeries>(),
      );
    });

    test('上昇トレンドで overbought になる', () {
      final alwaysUp = List.generate(30, (i) => 100.0 + i.toDouble());
      final params = RsiParams(period: 5, overbought: 70);
      final result =
          RsiLogic().calculate(params: params, data: alwaysUp) as RsiSeries;
      expect(result.stateOf(params), RsiState.overbought);
    });

    test('下降トレンドで oversold になる', () {
      final alwaysDown = List.generate(30, (i) => 100.0 - i.toDouble());
      final params = RsiParams(period: 5, oversold: 30);
      final result =
          RsiLogic().calculate(params: params, data: alwaysDown) as RsiSeries;
      expect(result.stateOf(params), RsiState.oversold);
    });

    test('データ不足時は neutral', () {
      final result = RsiSeries(data: [null, null]);
      expect(result.stateOf(RsiParams()), RsiState.neutral);
    });

    test('calculateWithKline でも動作する', () {
      final ohlcvData = List.generate(
        30,
        (i) => Ohlcv(
          open: 100.0,
          high: 105.0,
          low: 99.0,
          close: 100.0 + i * 0.5,
          volume: 1000.0,
          openTimestamp: i * 60000,
          closeTimestamp: (i + 1) * 60000 - 1,
        ),
      );
      final series = OhlcvSeries(data: ohlcvData);
      final result = RsiLogic().calculateWithKline(
        klineSeries: series,
        priceType: PriceType.close,
        params: RsiParams(period: 14),
      );
      expect(result, isA<RsiSeries>());
    });
  });

  // ─── MacdLogic ────────────────────────────────────────────────────────────

  group('MacdLogic', () {
    test('MacdSeries を返す', () {
      expect(
        MacdLogic().calculate(params: MacdParams(), data: closes),
        isA<MacdSeries>(),
      );
    });

    test('histogram = macdLine - signalLine', () {
      final result = MacdLogic().calculate(
        params: MacdParams(fastPeriod: 3, slowPeriod: 6, signalPeriod: 3),
        data: closes,
      ) as MacdSeries;
      for (final m in result.data) {
        if (m != null) {
          expect(m.histogram, closeTo(m.macdLine - m.signalLine, 1e-10));
        }
      }
    });

    test('isBullishCross と isBearishCross は bool を返す', () {
      final result = MacdLogic().calculate(
        params: MacdParams(fastPeriod: 3, slowPeriod: 6, signalPeriod: 3),
        data: closes,
      ) as MacdSeries;
      expect(result.isBullishCross, isA<bool>());
      expect(result.isBearishCross, isA<bool>());
    });

    test('データ不足時（長さ < 2）はクロスしない', () {
      final result = MacdSeries(data: [null]);
      expect(result.isBullishCross, isFalse);
      expect(result.isBearishCross, isFalse);
    });

    test('ゴールデンクロスを検出する', () {
      // prev: macdLine=-1, signalLine=0 → curr: macdLine=1, signalLine=0
      final result = MacdSeries(
        data: [
          Macd(macdLine: -1.0, signalLine: 0.0, histogram: -1.0),
          Macd(macdLine: 1.0, signalLine: 0.0, histogram: 1.0),
        ],
      );
      expect(result.isBullishCross, isTrue);
      expect(result.isBearishCross, isFalse);
    });

    test('デッドクロスを検出する', () {
      final result = MacdSeries(
        data: [
          Macd(macdLine: 1.0, signalLine: 0.0, histogram: 1.0),
          Macd(macdLine: -1.0, signalLine: 0.0, histogram: -1.0),
        ],
      );
      expect(result.isBearishCross, isTrue);
      expect(result.isBullishCross, isFalse);
    });
  });

  // ─── FKCEngine.analyze() ──────────────────────────────────────────────────

  group('FKCEngine.analyze', () {
    OhlcvSeries makeSeries(int count) {
      return OhlcvSeries(
        data: List.generate(
          count,
          (i) => Ohlcv(
            open: 100.0,
            high: 105.0,
            low: 99.0,
            close: 100.0 + i * 0.5,
            volume: 1000.0,
            openTimestamp: i * 60000,
            closeTimestamp: (i + 1) * 60000 - 1,
          ),
        ),
      );
    }

    test('start から末尾まで結果を返す', () {
      final engine = FKCEngine(baseInterval: Interval.$1m);
      engine.addOhlcvSeries(Interval.$1m, makeSeries(10));
      final result = engine.analyze<int>(
        start: 3,
        func: (w) => w.ohlcvSeries.length,
      );
      expect(result.length, 7); // index 3〜9 の 7バー
      expect(result.first, 4); // start=3 → データは 0..3 の 4本
      expect(result.last, 10);
    });

    test('baseInterval が未登録なら空を返す', () {
      final engine = FKCEngine(baseInterval: Interval.$1m);
      final result = engine.analyze<int>(start: 0, func: (w) => 0);
      expect(result, isEmpty);
    });
  });

  // ─── OhlcvSeriesWrapper.analyze() + jumpTo MTF ────────────────────────────

  group('OhlcvSeriesWrapper.analyze + jumpTo MTF', () {
    test('analyze から select してもフルデータ', () {
      final minuteData = OhlcvSeries(
        data: List.generate(
          5,
          (i) => Ohlcv(
            open: 100.0,
            high: 105.0,
            low: 99.0,
            close: 100.0 + i.toDouble(),
            volume: 1000.0,
            openTimestamp: i * 60000,
            closeTimestamp: (i + 1) * 60000 - 1,
          ),
        ),
      );
      // 5分足 = 1分足5本をマージ
      final fiveMinData = minuteData.merge(
        5,
        alignment: MergeAlignment.left,
        mode: MergeMode.partial,
      );

      final engine = FKCEngine(baseInterval: Interval.$1m);
      engine.addOhlcvSeries(Interval.$1m, minuteData);
      engine.addOhlcvSeries(Interval.$5m, fiveMinData);

      final lengths = engine.analyze<int>(
        start: 0,
        func: (w) {
          final fiveMin = w.jumpTo(Interval.$5m);
          return fiveMin?.ohlcvSeries.length ?? 0;
        },
      );

      // 各バーの closeTimestamp 以前の5分足バー数
      // バー0 closeTs=59999  → 5分足なし(全5分足はTs=299999) → 0
      // バー4 closeTs=299999 → 5分足 1本
      expect(lengths.first, 0);
      expect(lengths.last, 1);
    });
  });
}
