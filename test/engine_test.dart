import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  group('FKCEngine', () {
    test('baseInterval設定と基本的なシリーズの追加・取得', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);
      expect(engine.baseInterval, Interval.$1h);

      final series = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
          Kline(
            openTimestamp: 1100,
            closeTimestamp: 1200,
            open: 105,
            high: 115,
            low: 95,
            close: 110,
            volume: 1200,
          ),
        ],
      );

      engine.addOhlcvSeries(Interval.$1h, series);

      final retrieved = engine.getOhlcvSeries(Interval.$1h);
      expect(retrieved, isNotNull);
      expect(retrieved?.length, 2);
      expect(retrieved?[0].close, 105);
    });

    test('select()でOhlcvSeriesWrapperを取得', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);
      final series = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
        ],
      );
      engine.addOhlcvSeries(Interval.$1h, series);

      final wrapper = engine.select(Interval.$1h);
      expect(wrapper, isNotNull);
      expect(wrapper?.ohlcvSeries.length, 1);
      expect(wrapper?.interval, Interval.$1h);
    });

    test('存在しない時間足を取得した場合はnull', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);
      expect(engine.getOhlcvSeries(Interval.$4h), isNull);
      expect(engine.select(Interval.$4h), isNull);
    });

    test('analyze()で各バーごとに関数を実行', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);
      final series = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
          Kline(
            openTimestamp: 1100,
            closeTimestamp: 1200,
            open: 105,
            high: 115,
            low: 95,
            close: 110,
            volume: 1200,
          ),
          Kline(
            openTimestamp: 1200,
            closeTimestamp: 1300,
            open: 110,
            high: 120,
            low: 100,
            close: 115,
            volume: 1300,
          ),
        ],
      );
      engine.addOhlcvSeries(Interval.$1h, series);

      final results = engine.analyze<double>(
        start: 0,
        func: (wrapper) => wrapper.ohlcvSeries.last.close,
      );

      expect(results.length, 3);
      expect(results[0], 105);
      expect(results[1], 110);
      expect(results[2], 115);
    });

    test('analyze()でstartを指定してスキップ', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);
      final series = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
          Kline(
            openTimestamp: 1100,
            closeTimestamp: 1200,
            open: 105,
            high: 115,
            low: 95,
            close: 110,
            volume: 1200,
          ),
          Kline(
            openTimestamp: 1200,
            closeTimestamp: 1300,
            open: 110,
            high: 120,
            low: 100,
            close: 115,
            volume: 1300,
          ),
        ],
      );
      engine.addOhlcvSeries(Interval.$1h, series);

      final results = engine.analyze<double>(
        start: 1,
        func: (wrapper) => wrapper.ohlcvSeries.last.close,
      );

      expect(results.length, 2);
      expect(results[0], 110);
      expect(results[1], 115);
    });
  });

  group('OhlcvSeriesWrapper', () {
    test('jumpTo()で別の時間足に切り替え', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);

      final series1h = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
        ],
      );
      final series4h = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1400,
            open: 100,
            high: 120,
            low: 85,
            close: 115,
            volume: 5000,
          ),
        ],
      );

      engine
        ..addOhlcvSeries(Interval.$1h, series1h)
        ..addOhlcvSeries(Interval.$4h, series4h);

      final wrapper = engine.select(Interval.$1h);
      final jumped = wrapper?.jumpTo(Interval.$4h);

      expect(jumped, isNotNull);
      expect(jumped?.interval, Interval.$4h);
      expect(jumped?.ohlcvSeries.length, 1);
      expect(jumped?.ohlcvSeries[0].close, 115);
    });

    test('analyze()内でjumpTo()すると未来データを除外', () {
      final engine = FKCEngine(baseInterval: Interval.$1h);

      final series1h = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1100,
            open: 100,
            high: 110,
            low: 90,
            close: 105,
            volume: 1000,
          ),
          Kline(
            openTimestamp: 1100,
            closeTimestamp: 1200,
            open: 105,
            high: 115,
            low: 95,
            close: 110,
            volume: 1200,
          ),
          Kline(
            openTimestamp: 1200,
            closeTimestamp: 1300,
            open: 110,
            high: 120,
            low: 100,
            close: 115,
            volume: 1300,
          ),
        ],
      );

      final series4h = OhlcvSeries(
        data: [
          Kline(
            openTimestamp: 1000,
            closeTimestamp: 1050,
            open: 100,
            high: 105,
            low: 95,
            close: 102,
            volume: 500,
          ),
          Kline(
            openTimestamp: 1050,
            closeTimestamp: 1150,
            open: 102,
            high: 108,
            low: 98,
            close: 106,
            volume: 600,
          ),
          Kline(
            openTimestamp: 1150,
            closeTimestamp: 1250,
            open: 106,
            high: 112,
            low: 104,
            close: 111,
            volume: 700,
          ),
          Kline(
            openTimestamp: 1250,
            closeTimestamp: 1350,
            open: 111,
            high: 118,
            low: 109,
            close: 116,
            volume: 800,
          ),
        ],
      );

      engine
        ..addOhlcvSeries(Interval.$1h, series1h)
        ..addOhlcvSeries(Interval.$4h, series4h);

      final results = engine.analyze<int>(
        start: 0,
        func: (wrapper) {
          final jumped = wrapper.jumpTo(Interval.$4h);
          return jumped?.ohlcvSeries.length ?? 0;
        },
      );

      expect(results[0], 1);
      expect(results[1], 2);
      expect(results[2], 3);
    });
  });
}
