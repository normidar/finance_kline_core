import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  group('linearFit tests', () {
    test('perfect linear relationship (y = 2x + 1)', () {
      // データ: (0,1), (1,3), (2,5), (3,7), (4,9)
      final data = [
        Decimal.fromInt(1),
        Decimal.fromInt(3),
        Decimal.fromInt(5),
        Decimal.fromInt(7),
        Decimal.fromInt(9),
      ];

      final result = data.linearFit();

      expect(result.slope, closeTo(2.0, 0.0001));
      expect(result.intercept, closeTo(1.0, 0.0001));
      expect(result.rSquared, closeTo(1.0, 0.0001)); // 完全な線形関係なのでR²=1

      // 予測値のテスト
      expect(result.predict(0), closeTo(1.0, 0.0001));
      expect(result.predict(1), closeTo(3.0, 0.0001));
      expect(result.predict(5), closeTo(11.0, 0.0001));
    });

    test('horizontal line (y = 5)', () {
      final data = [
        Decimal.fromInt(5),
        Decimal.fromInt(5),
        Decimal.fromInt(5),
        Decimal.fromInt(5),
      ];

      final result = data.linearFit();

      expect(result.slope, closeTo(0.0, 0.0001));
      expect(result.intercept, closeTo(5.0, 0.0001));
      expect(result.rSquared, closeTo(1.0, 0.0001)); // すべて同じ値なのでR²=1
    });

    test('negative slope (y = -1.5x + 10)', () {
      // データ: (0,10), (1,8.5), (2,7), (3,5.5), (4,4)
      final data = [
        Decimal.parse('10'),
        Decimal.parse('8.5'),
        Decimal.parse('7'),
        Decimal.parse('5.5'),
        Decimal.parse('4'),
      ];

      final result = data.linearFit();

      expect(result.slope, closeTo(-1.5, 0.0001));
      expect(result.intercept, closeTo(10.0, 0.0001));
      expect(result.rSquared, closeTo(1.0, 0.0001)); // 完全な線形関係なのでR²=1
    });

    test('data with noise', () {
      // おおよそ y = 3x + 2 に近いデータ（ノイズあり）
      final data = [
        Decimal.parse('2.1'), // x=0, expected ~2
        Decimal.parse('4.9'), // x=1, expected ~5
        Decimal.parse('8.2'), // x=2, expected ~8
        Decimal.parse('10.8'), // x=3, expected ~11
        Decimal.parse('14.1'), // x=4, expected ~14
      ];

      final result = data.linearFit();

      // ノイズがあるため、完全には一致しないが近い値になる
      expect(result.slope, closeTo(3.0, 0.2));
      expect(result.intercept, closeTo(2.0, 0.5));
      // ノイズがあるためR²は1より小さいが、高い相関がある
      expect(result.rSquared, greaterThan(0.99));
      expect(result.rSquared, lessThanOrEqualTo(1.0));
    });

    test('two data points', () {
      final data = [
        Decimal.fromInt(1),
        Decimal.fromInt(4),
      ];

      final result = data.linearFit();

      // (0,1) と (1,4) を通る直線: y = 3x + 1
      expect(result.slope, closeTo(3.0, 0.0001));
      expect(result.intercept, closeTo(1.0, 0.0001));
      expect(result.rSquared, closeTo(1.0, 0.0001)); // 2点なので完全にフィット
    });

    test('decimal values', () {
      final data = [
        Decimal.parse('1.5'),
        Decimal.parse('2.7'),
        Decimal.parse('3.9'),
        Decimal.parse('5.1'),
      ];

      final result = data.linearFit();

      // おおよそ y = 1.2x + 1.5
      expect(result.slope, closeTo(1.2, 0.0001));
      expect(result.intercept, closeTo(1.5, 0.0001));
      expect(result.rSquared, closeTo(1.0, 0.0001)); // 完全な線形関係
    });

    test('R² with poor correlation', () {
      // ランダムに近いデータで相関が低い
      final data = [
        Decimal.parse('5'),
        Decimal.parse('2'),
        Decimal.parse('8'),
        Decimal.parse('3'),
        Decimal.parse('7'),
        Decimal.parse('1'),
      ];

      final result = data.linearFit();

      // 相関が低いためR²は低い値になる
      expect(result.rSquared, lessThan(0.5));
      expect(result.rSquared, greaterThanOrEqualTo(0.0));
    });

    test('R² calculation details', () {
      // 具体的なR²の計算を検証
      final data = [
        Decimal.parse('1'),
        Decimal.parse('2'),
        Decimal.parse('1.3'),
        Decimal.parse('3.75'),
        Decimal.parse('2.25'),
      ];

      final result = data.linearFit();

      // R²は0〜1の範囲内
      expect(result.rSquared, greaterThanOrEqualTo(0.0));
      expect(result.rSquared, lessThanOrEqualTo(1.0));

      // このデータはある程度の相関がある
      expect(result.rSquared, greaterThan(0.3));
    });

    test('throws error on empty list', () {
      final data = <Decimal>[];

      expect(
        data.linearFit,
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws error on single data point', () {
      final data = [Decimal.fromInt(5)];

      expect(
        data.linearFit,
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('EMA tests', () {
    test('EMA calculation with simple data', () {
      final data = [
        Decimal.fromInt(10),
        Decimal.fromInt(11),
        Decimal.fromInt(12),
        Decimal.fromInt(13),
        Decimal.fromInt(14),
        Decimal.fromInt(15),
      ];

      final result = data.ema(3);

      // 最初の2つはnull
      expect(result[0], isNull);
      expect(result[1], isNull);

      // 3番目はSMA: (10 + 11 + 12) / 3 = 11
      expect(result[2], closeTo(11.0, 0.0001));

      // 4番目以降はEMA計算
      // multiplier = 2 / (3 + 1) = 0.5
      // EMA[3] = (13 - 11) * 0.5 + 11 = 12
      expect(result[3], closeTo(12.0, 0.0001));

      // EMA[4] = (14 - 12) * 0.5 + 12 = 13
      expect(result[4], closeTo(13.0, 0.0001));

      // EMA[5] = (15 - 13) * 0.5 + 13 = 14
      expect(result[5], closeTo(14.0, 0.0001));
    });

    test('EMA with period 5', () {
      final data = [
        Decimal.parse('22.27'),
        Decimal.parse('22.19'),
        Decimal.parse('22.08'),
        Decimal.parse('22.17'),
        Decimal.parse('22.18'),
        Decimal.parse('22.13'),
        Decimal.parse('22.23'),
        Decimal.parse('22.43'),
        Decimal.parse('22.24'),
        Decimal.parse('22.29'),
      ];

      final result = data.ema(5);

      // 最初の4つはnull
      for (var i = 0; i < 4; i++) {
        expect(result[i], isNull);
      }

      // 5番目はSMA
      const firstSma = (22.27 + 22.19 + 22.08 + 22.17 + 22.18) / 5;
      expect(result[4], closeTo(firstSma, 0.01));

      // 残りはEMAで計算される
      expect(result[5], isNotNull);
      expect(result[9], isNotNull);
    });

    test('EMA throws error on invalid period', () {
      final data = [Decimal.fromInt(1), Decimal.fromInt(2)];

      expect(
        () => data.ema(0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => data.ema(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('EMA on empty list', () {
      final data = <Decimal>[];
      final result = data.ema(5);

      expect(result, isEmpty);
    });
  });

  group('KlineSeriesX EMA tests', () {
    test('EMA calculation on kline series', () {
      final klines = [
        Kline.fromDouble(open: 10, high: 11, low: 9, close: 10.5),
        Kline.fromDouble(open: 10.5, high: 12, low: 10, close: 11.5),
        Kline.fromDouble(open: 11.5, high: 13, low: 11, close: 12.5),
        Kline.fromDouble(open: 12.5, high: 14, low: 12, close: 13.5),
        Kline.fromDouble(open: 13.5, high: 15, low: 13, close: 14.5),
      ];

      final ema3 = klines.ema(period: 3);

      // 最初の2つはnull
      expect(ema3[0], isNull);
      expect(ema3[1], isNull);

      // 3番目はSMA: (10.5 + 11.5 + 12.5) / 3 = 11.5
      expect(ema3[2], closeTo(11.5, 0.0001));

      // 4番目以降はEMA
      expect(ema3[3], isNotNull);
      expect(ema3[4], isNotNull);

      // EMAは増加傾向にある
      expect(ema3[3]! > ema3[2]!, isTrue);
      expect(ema3[4]! > ema3[3]!, isTrue);
    });

    test('EMA with different periods', () {
      final klines = List.generate(
        20,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 102 + i.toDouble(),
          low: 99 + i.toDouble(),
          close: 100 + i.toDouble(),
        ),
      );

      final ema5 = klines.ema(period: 5);
      final ema10 = klines.ema(period: 10);

      // EMA5は5番目から値が入る
      expect(ema5[4], isNotNull);
      expect(ema5[0], isNull);

      // EMA10は10番目から値が入る
      expect(ema10[9], isNotNull);
      expect(ema10[0], isNull);

      // 短期EMAの方が価格変動に敏感
      // 上昇トレンドでは短期EMAの方が大きくなる
      expect(ema5.last! > ema10.last!, isTrue);
    });
  });

  group('KlineSeriesX merge tests', () {
    test('merge with count=2, left alignment, strict mode', () {
      // 6つの30分足を2つずつマージして3つの1時間足にする
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
        Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
        Kline.fromDouble(open: 113, high: 118, low: 112, close: 116),
      ];

      final merged = klines.merge(
        count: 2,
      );

      expect(merged.length, equals(3));

      // 最初のマージ結果: [0, 1]
      expect(merged[0].open, equals(Decimal.parse('100.0')));
      expect(merged[0].high, equals(Decimal.parse('108.0')));
      expect(merged[0].low, equals(Decimal.parse('99.0')));
      expect(merged[0].close, equals(Decimal.parse('107.0')));

      // 2番目のマージ結果: [2, 3]
      expect(merged[1].open, equals(Decimal.parse('107.0')));
      expect(merged[1].high, equals(Decimal.parse('112.0')));
      expect(merged[1].low, equals(Decimal.parse('106.0')));
      expect(merged[1].close, equals(Decimal.parse('111.0')));

      // 3番目のマージ結果: [4, 5]
      expect(merged[2].open, equals(Decimal.parse('111.0')));
      expect(merged[2].high, equals(Decimal.parse('118.0')));
      expect(merged[2].low, equals(Decimal.parse('110.0')));
      expect(merged[2].close, equals(Decimal.parse('116.0')));
    });

    test('merge with count=2, left alignment, partial mode with remainder', () {
      // 5つのKlineを2つずつマージ、最後の1つは余り
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
        Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
      ];

      final merged = klines.merge(
        count: 2,
        mode: MergeMode.partial,
      );

      expect(merged.length, equals(3)); // 2つの完全なチャンク + 1つの余り

      // 最後のマージ結果は余りの1つだけ
      expect(merged[2].open, equals(Decimal.parse('111.0')));
      expect(merged[2].close, equals(Decimal.parse('113.0')));
    });

    test('merge with count=2, left alignment, strict mode with remainder', () {
      // 5つのKlineを2つずつマージ、最後の1つは捨てる
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
        Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
      ];

      final merged = klines.merge(
        count: 2,
      );

      expect(merged.length, equals(2)); // 余りは捨てられる
    });

    test('merge with count=2, right alignment, strict mode', () {
      // 右寄せで6つのKlineをマージ
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
        Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
        Kline.fromDouble(open: 113, high: 118, low: 112, close: 116),
      ];

      final merged = klines.merge(
        count: 2,
        alignment: MergeAlignment.right,
      );

      expect(merged.length, equals(3));

      // 最後のマージ結果が最も重要（最新データ）
      expect(merged[2].open, equals(Decimal.parse('111.0')));
      expect(merged[2].close, equals(Decimal.parse('116.0')));
    });

    test(
      'merge with count=2, right alignment, partial mode with remainder',
      () {
        // 5つのKlineを右寄せでマージ、最初の1つが余り
        final klines = [
          Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
          Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
          Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
          Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
          Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
        ];

        final merged = klines.merge(
          count: 2,
          alignment: MergeAlignment.right,
          mode: MergeMode.partial,
        );

        expect(merged.length, equals(3)); // 1つの余り + 2つの完全なチャンク

        // 最初のマージ結果は余りの1つだけ
        expect(merged[0].open, equals(Decimal.parse('100.0')));
        expect(merged[0].close, equals(Decimal.parse('102.0')));

        // 2番目のマージ結果: [1, 2]
        expect(merged[1].open, equals(Decimal.parse('102.0')));
        expect(merged[1].close, equals(Decimal.parse('109.0')));
      },
    );

    test('merge with count=2, right alignment, strict mode with remainder', () {
      // 5つのKlineを右寄せでマージ、最初の1つは捨てる
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
        Kline.fromDouble(open: 107, high: 110, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 112, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 115, low: 110, close: 113),
      ];

      final merged = klines.merge(
        count: 2,
        alignment: MergeAlignment.right,
      );

      expect(merged.length, equals(2)); // 余りは捨てられる

      // 最初のマージ結果: [1, 2]（0は捨てられた）
      expect(merged[0].open, equals(Decimal.parse('102.0')));
      expect(merged[0].close, equals(Decimal.parse('109.0')));
    });

    test('merge with count=3', () {
      // 9つのKlineを3つずつマージ
      final klines = List.generate(
        9,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 105 + i.toDouble(),
          low: 95 + i.toDouble(),
          close: 102 + i.toDouble(),
        ),
      );

      final merged = klines.merge(
        count: 3,
      );

      expect(merged.length, equals(3));

      // 最初のマージ結果: [0, 1, 2]
      expect(merged[0].open, equals(Decimal.parse('100.0')));
      expect(
        merged[0].high,
        equals(Decimal.parse('107.0')),
      ); // max(105, 106, 107)
      expect(merged[0].low, equals(Decimal.parse('95.0'))); // min(95, 96, 97)
      expect(merged[0].close, equals(Decimal.parse('104.0')));
    });

    test('merge with count=1 returns same series', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 107),
      ];

      final merged = klines.merge(
        count: 1,
      );

      expect(merged.length, equals(2));
      expect(merged[0], equals(klines[0]));
      expect(merged[1], equals(klines[1]));
    });

    test('merge with empty list returns empty', () {
      final klines = <Kline>[];

      final merged = klines.merge(
        count: 2,
      );

      expect(merged, isEmpty);
    });

    test('merge throws error on invalid count', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
      ];

      expect(
        () => klines.merge(
          count: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => klines.merge(
          count: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('merge real scenario: 30m to 1h', () {
      // 実際のシナリオ: 2つの30分足を1つの1時間足にマージ
      final thirtyMinKlines = [
        Kline.fromDouble(open: 50000, high: 50500, low: 49800, close: 50200),
        Kline.fromDouble(open: 50200, high: 50800, low: 50000, close: 50600),
        Kline.fromDouble(open: 50600, high: 51000, low: 50400, close: 50800),
        Kline.fromDouble(open: 50800, high: 51200, low: 50600, close: 51000),
      ];

      final oneHourKlines = thirtyMinKlines.merge(
        count: 2,
      );

      expect(oneHourKlines.length, equals(2));

      // 最初の1時間足
      expect(oneHourKlines[0].open, equals(Decimal.parse('50000.0')));
      expect(oneHourKlines[0].high, equals(Decimal.parse('50800.0')));
      expect(oneHourKlines[0].low, equals(Decimal.parse('49800.0')));
      expect(oneHourKlines[0].close, equals(Decimal.parse('50600.0')));

      // 2番目の1時間足
      expect(oneHourKlines[1].open, equals(Decimal.parse('50600.0')));
      expect(oneHourKlines[1].high, equals(Decimal.parse('51200.0')));
      expect(oneHourKlines[1].low, equals(Decimal.parse('50400.0')));
      expect(oneHourKlines[1].close, equals(Decimal.parse('51000.0')));
    });
  });

  group('MACD tests', () {
    test('MACD calculation with default periods', () {
      // 十分なデータを用意（最低でもslowPeriod + signalPeriod - 1必要）
      final data = List.generate(
        50,
        (i) => Decimal.parse((100 + i * 0.5).toString()),
      );

      final result = data.macd();

      // 最初の部分はnull（slowPeriod + signalPeriod - 2まで）
      expect(result[0], isNull);
      expect(result[10], isNull);
      expect(result[20], isNull);
      expect(result[30], isNull);

      // 十分なデータがある位置では値が入る
      expect(result[34], isNotNull);
      expect(result[40], isNotNull);
      expect(result[49], isNotNull);

      // MACD値が正しく計算されていることを確認
      final macd40 = result[40]!;
      expect(macd40.macdLine, isA<double>());
      expect(macd40.signalLine, isA<double>());
      expect(macd40.histogram, isA<double>());

      // ヒストグラム = MACDライン - シグナルライン
      expect(
        macd40.histogram,
        closeTo(macd40.macdLine - macd40.signalLine, 0.0001),
      );
    });

    test('MACD calculation with custom periods', () {
      final data = List.generate(
        40,
        (i) => Decimal.parse((100 + i).toString()),
      );

      final result = data.macd(
        fastPeriod: 5,
        slowPeriod: 10,
        signalPeriod: 3,
      );

      // slowPeriod(10) + signalPeriod(3) - 2 = 11番目まではnull
      expect(result[0], isNull);
      expect(result[10], isNull);

      // 12番目以降は値が入る
      expect(result[11], isNotNull);
      expect(result[20], isNotNull);

      final macd20 = result[20]!;
      expect(macd20.macdLine, isA<double>());
      expect(macd20.signalLine, isA<double>());
      expect(macd20.histogram, isA<double>());
    });

    test('MACD bullish and bearish indicators', () {
      // 上昇トレンドのデータ
      final uptrend = List.generate(
        50,
        (i) => Decimal.parse((100 + i * 2).toString()),
      );

      final uptrendMacd = uptrend.macd();
      final lastUptrend = uptrendMacd.last!;

      // 上昇トレンドではMACDラインが正の値になる傾向
      expect(lastUptrend.macdLine, greaterThan(0));

      // 下降トレンドのデータ
      final downtrend = List.generate(
        50,
        (i) => Decimal.parse((200 - i * 2).toString()),
      );

      final downtrendMacd = downtrend.macd();
      final lastDowntrend = downtrendMacd.last!;

      // 下降トレンドではMACDラインが負の値になる傾向
      expect(lastDowntrend.macdLine, lessThan(0));
    });

    test('MACD isBullish and isBearish properties', () {
      final data = List.generate(
        50,
        (i) => Decimal.parse((100 + i).toString()),
      );

      final result = data.macd();
      final lastMacd = result.last!;

      // MACDラインとシグナルラインの比較
      if (lastMacd.macdLine > lastMacd.signalLine) {
        expect(lastMacd.isBullish, isTrue);
        expect(lastMacd.isBearish, isFalse);
      } else if (lastMacd.macdLine < lastMacd.signalLine) {
        expect(lastMacd.isBullish, isFalse);
        expect(lastMacd.isBearish, isTrue);
      }
    });

    test('MACD throws error on invalid periods', () {
      final data = [Decimal.fromInt(100), Decimal.fromInt(101)];

      expect(
        () => data.macd(fastPeriod: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => data.macd(slowPeriod: -1),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => data.macd(signalPeriod: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => data.macd(fastPeriod: 20, slowPeriod: 10),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('MACD on empty list', () {
      final data = <Decimal>[];
      final result = data.macd();

      expect(result, isEmpty);
    });
  });

  group('KlineSeriesX MACD tests', () {
    test('MACD calculation on kline series', () {
      final klines = List.generate(
        50,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 102 + i.toDouble(),
          low: 99 + i.toDouble(),
          close: 100 + i.toDouble(),
        ),
      );

      final macd = klines.macd();

      // 最初の部分はnull
      expect(macd[0], isNull);
      expect(macd[20], isNull);

      // 十分なデータがある位置では値が入る
      expect(macd[34], isNotNull);
      expect(macd[40], isNotNull);

      final macd40 = macd[40]!;
      expect(macd40.macdLine, isA<double>());
      expect(macd40.signalLine, isA<double>());
      expect(macd40.histogram, isA<double>());
    });

    test('MACD with different price types', () {
      final klines = List.generate(
        50,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 110 + i.toDouble() * 1.5,
          low: 95 + i.toDouble() * 0.5,
          close: 102 + i.toDouble(),
        ),
      );

      final macdClose = klines.macd();
      final macdHigh = klines.macd(priceType: PriceType.high);

      // 異なる価格タイプでは異なる結果になる
      expect(macdClose.last, isNotNull);
      expect(macdHigh.last, isNotNull);

      // highの方が大きい傾きを持つため、MACDラインも異なるはず
      expect(
        (macdClose.last!.macdLine - macdHigh.last!.macdLine).abs(),
        greaterThan(0.01),
      );
    });

    test('MACD with custom periods on klines', () {
      final klines = List.generate(
        40,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 102 + i.toDouble(),
          low: 99 + i.toDouble(),
          close: 100 + i.toDouble(),
        ),
      );

      final macd = klines.macd(
        fastPeriod: 5,
        slowPeriod: 10,
        signalPeriod: 3,
      );

      expect(macd[11], isNotNull);
      expect(macd[20], isNotNull);

      final macd20 = macd[20]!;
      expect(
        macd20.histogram,
        closeTo(macd20.macdLine - macd20.signalLine, 0.0001),
      );
    });
  });

  group('RSI tests', () {
    test('RSI calculation with default period', () {
      // テスト用の価格データ（上昇トレンド）
      final data = List.generate(
        30,
        (i) => Decimal.parse((100 + i * 0.5).toString()),
      );

      final result = data.rsi(14);

      // 最初の14個はnull
      for (var i = 0; i < 14; i++) {
        expect(result[i], isNull);
      }

      // 15番目以降は値が入る
      expect(result[14], isNotNull);
      expect(result[20], isNotNull);
      expect(result[29], isNotNull);

      // RSI値は0〜100の範囲内
      for (var i = 14; i < result.length; i++) {
        expect(result[i]!.value, greaterThanOrEqualTo(0));
        expect(result[i]!.value, lessThanOrEqualTo(100));
      }

      // 上昇トレンドではRSIは高めになる傾向
      expect(result.last!.value, greaterThan(50));
    });

    test('RSI calculation with custom period', () {
      final data = List.generate(
        30,
        (i) => Decimal.parse((100 + i).toString()),
      );

      final result = data.rsi(10);

      // 最初の10個はnull
      for (var i = 0; i < 10; i++) {
        expect(result[i], isNull);
      }

      // 11番目以降は値が入る
      expect(result[10], isNotNull);
      expect(result[20], isNotNull);

      final rsi20 = result[20]!;
      expect(rsi20.value, isA<double>());
      expect(rsi20.value, greaterThanOrEqualTo(0));
      expect(rsi20.value, lessThanOrEqualTo(100));
    });

    test('RSI with uptrend shows high values', () {
      // 強い上昇トレンド
      final uptrend = List.generate(
        30,
        (i) => Decimal.parse((100 + i * 2).toString()),
      );

      final result = uptrend.rsi(14);
      final lastRsi = result.last!;

      // 強い上昇トレンドではRSIは高い値になる
      expect(lastRsi.value, greaterThan(70));
      expect(lastRsi.isOverbought(), isTrue);
      expect(lastRsi.isOversold(), isFalse);
      expect(lastRsi.isNeutral(), isFalse);
    });

    test('RSI with downtrend shows low values', () {
      // 強い下降トレンド
      final downtrend = List.generate(
        30,
        (i) => Decimal.parse((200 - i * 2).toString()),
      );

      final result = downtrend.rsi(14);
      final lastRsi = result.last!;

      // 強い下降トレンドではRSIは低い値になる
      expect(lastRsi.value, lessThan(30));
      expect(lastRsi.isOversold(), isTrue);
      expect(lastRsi.isOverbought(), isFalse);
      expect(lastRsi.isNeutral(), isFalse);
    });

    test('RSI with sideways market shows neutral values', () {
      // 横ばい相場（小さな上下動）
      final sideways = [
        Decimal.parse('100'),
        Decimal.parse('101'),
        Decimal.parse('100.5'),
        Decimal.parse('101.5'),
        Decimal.parse('100'),
        Decimal.parse('101'),
        Decimal.parse('100.5'),
        Decimal.parse('101.5'),
        Decimal.parse('100'),
        Decimal.parse('101'),
        Decimal.parse('100.5'),
        Decimal.parse('101.5'),
        Decimal.parse('100'),
        Decimal.parse('101'),
        Decimal.parse('100.5'),
        Decimal.parse('101.5'),
        Decimal.parse('100'),
        Decimal.parse('101'),
        Decimal.parse('100.5'),
      ];

      final result = sideways.rsi(14);
      final lastRsi = result.last!;

      // 横ばい相場ではRSIは中立的な値になる
      expect(lastRsi.isNeutral(), isTrue);
      expect(lastRsi.value, greaterThan(30));
      expect(lastRsi.value, lessThan(70));
    });

    test('RSI custom thresholds', () {
      final data = List.generate(
        30,
        (i) => Decimal.parse((100 + i).toString()),
      );

      final result = data.rsi(14);
      final rsi = result[20]!;

      // カスタム閾値でのテスト
      // RSIが50未満の場合はoversoldと判定される（閾値50）
      if (rsi.value < 50) {
        expect(rsi.isOversold(50), isTrue);
      } else {
        expect(rsi.isOversold(50), isFalse);
      }

      // RSIが60以上の場合はoverboughtと判定される（閾値60）
      if (rsi.value >= 60) {
        expect(rsi.isOverbought(60), isTrue);
      } else {
        expect(rsi.isOverbought(60), isFalse);
      }
    });

    test('RSI throws error on invalid period', () {
      final data = [Decimal.fromInt(100), Decimal.fromInt(101)];

      expect(
        () => data.rsi(0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => data.rsi(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('RSI on empty list', () {
      final data = <Decimal>[];
      final result = data.rsi(14);

      expect(result, isEmpty);
    });

    test('RSI on list with insufficient data', () {
      final data = [Decimal.fromInt(100)];
      final result = data.rsi(14);

      expect(result, isEmpty);
    });
  });

  group('KlineSeriesX RSI tests', () {
    test('RSI calculation on kline series', () {
      final klines = List.generate(
        30,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 102 + i.toDouble(),
          low: 99 + i.toDouble(),
          close: 100 + i.toDouble(),
        ),
      );

      final rsi = klines.rsi();

      // 最初の14個はnull
      for (var i = 0; i < 14; i++) {
        expect(rsi[i], isNull);
      }

      // 15番目以降は値が入る
      expect(rsi[14], isNotNull);
      expect(rsi[20], isNotNull);

      final rsi20 = rsi[20]!;
      expect(rsi20.value, isA<double>());
      expect(rsi20.value, greaterThanOrEqualTo(0));
      expect(rsi20.value, lessThanOrEqualTo(100));
    });

    test('RSI with different price types', () {
      // 変動パターンが異なるKlineデータを生成
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 98, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 100, close: 103),
        Kline.fromDouble(open: 103, high: 106, low: 99, close: 101),
        Kline.fromDouble(open: 101, high: 110, low: 100, close: 104),
        Kline.fromDouble(open: 104, high: 107, low: 102, close: 105),
        Kline.fromDouble(open: 105, high: 112, low: 103, close: 106),
        Kline.fromDouble(open: 106, high: 109, low: 104, close: 107),
        Kline.fromDouble(open: 107, high: 115, low: 105, close: 108),
        Kline.fromDouble(open: 108, high: 111, low: 106, close: 109),
        Kline.fromDouble(open: 109, high: 118, low: 107, close: 110),
        Kline.fromDouble(open: 110, high: 113, low: 108, close: 111),
        Kline.fromDouble(open: 111, high: 120, low: 109, close: 112),
        Kline.fromDouble(open: 112, high: 115, low: 110, close: 113),
        Kline.fromDouble(open: 113, high: 122, low: 111, close: 114),
        Kline.fromDouble(open: 114, high: 117, low: 112, close: 115),
        Kline.fromDouble(open: 115, high: 125, low: 113, close: 116),
        Kline.fromDouble(open: 116, high: 119, low: 114, close: 117),
        Kline.fromDouble(open: 117, high: 128, low: 115, close: 118),
        Kline.fromDouble(open: 118, high: 121, low: 116, close: 119),
        Kline.fromDouble(open: 119, high: 130, low: 117, close: 120),
      ];

      final rsiClose = klines.rsi();
      final rsiHigh = klines.rsi(priceType: PriceType.high);

      // 異なる価格タイプでは異なる結果になる
      expect(rsiClose.last, isNotNull);
      expect(rsiHigh.last, isNotNull);

      // close と high は異なる変動パターンを持つため、RSI値も異なる
      // ただし、両方とも上昇トレンドなので高い値になる
      expect(rsiClose.last!.value, greaterThan(50));
      expect(rsiHigh.last!.value, greaterThan(50));
    });

    test('RSI with custom period on klines', () {
      final klines = List.generate(
        30,
        (i) => Kline.fromDouble(
          open: 100 + i.toDouble(),
          high: 102 + i.toDouble(),
          low: 99 + i.toDouble(),
          close: 100 + i.toDouble(),
        ),
      );

      final rsi = klines.rsi(period: 10);

      expect(rsi[10], isNotNull);
      expect(rsi[20], isNotNull);

      final rsi20 = rsi[20]!;
      expect(rsi20.value, greaterThanOrEqualTo(0));
      expect(rsi20.value, lessThanOrEqualTo(100));
    });

    test('RSI trend detection on klines', () {
      // 上昇トレンドのKlineデータ
      final uptrendKlines = List.generate(
        30,
        (i) => Kline.fromDouble(
          open: 100 + i * 2.toDouble(),
          high: 103 + i * 2.toDouble(),
          low: 99 + i * 2.toDouble(),
          close: 102 + i * 2.toDouble(),
        ),
      );

      final rsiUptrend = uptrendKlines.rsi();
      expect(rsiUptrend.last!.value, greaterThan(70));
      expect(rsiUptrend.last!.isOverbought(), isTrue);

      // 下降トレンドのKlineデータ
      final downtrendKlines = List.generate(
        30,
        (i) => Kline.fromDouble(
          open: 200 - i * 2.toDouble(),
          high: 203 - i * 2.toDouble(),
          low: 199 - i * 2.toDouble(),
          close: 200 - i * 2.toDouble(),
        ),
      );

      final rsiDowntrend = downtrendKlines.rsi();
      expect(rsiDowntrend.last!.value, lessThan(30));
      expect(rsiDowntrend.last!.isOversold(), isTrue);
    });
  });

  group('PipeList with KlineSeries tests', () {
    test('calculate rate of change using pipe', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 103, close: 108),
        Kline.fromDouble(open: 108, high: 112, low: 107, close: 110),
        Kline.fromDouble(open: 110, high: 115, low: 109, close: 112),
      ];

      // prevを使って前のKlineとの変動率を計算
      final rateOfChange = klines.pipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        return (currentClose - prevClose) / prevClose * 100;
      });

      // 最初の要素はnull（前の要素がないため）
      expect(rateOfChange[0], isNull);

      // 2番目: (104 - 102) / 102 * 100 = 1.96%
      expect(rateOfChange[1], closeTo(1.96, 0.01));

      // 3番目: (108 - 104) / 104 * 100 = 3.85%
      expect(rateOfChange[2], closeTo(3.85, 0.01));

      // 4番目: (110 - 108) / 108 * 100 = 1.85%
      expect(rateOfChange[3], closeTo(1.85, 0.01));

      // 5番目: (112 - 110) / 110 * 100 = 1.82%
      expect(rateOfChange[4], closeTo(1.82, 0.01));
    });

    test('calculate rate of change using cleanPipe (null excluded)', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 103, close: 108),
        Kline.fromDouble(open: 108, high: 112, low: 107, close: 110),
        Kline.fromDouble(open: 110, high: 115, low: 109, close: 112),
      ];

      // cleanPipeを使うとnullが自動的に除外される
      final rateOfChange = klines.cleanPipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        return (currentClose - prevClose) / prevClose * 100;
      });

      // nullは除外されるので、長さは4（最初のnullが除外される）
      expect(rateOfChange.length, equals(4));

      // 1番目: (104 - 102) / 102 * 100 = 1.96%
      expect(rateOfChange[0], closeTo(1.96, 0.01));

      // 2番目: (108 - 104) / 104 * 100 = 3.85%
      expect(rateOfChange[1], closeTo(3.85, 0.01));

      // 3番目: (110 - 108) / 108 * 100 = 1.85%
      expect(rateOfChange[2], closeTo(1.85, 0.01));

      // 4番目: (112 - 110) / 110 * 100 = 1.82%
      expect(rateOfChange[3], closeTo(1.82, 0.01));
    });

    test('calculate rate of change with negative values', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 104),
        Kline.fromDouble(open: 104, high: 108, low: 101, close: 102),
        Kline.fromDouble(open: 102, high: 106, low: 98, close: 100),
        Kline.fromDouble(open: 100, high: 104, low: 96, close: 105),
      ];

      final rateOfChange = klines.pipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        return (currentClose - prevClose) / prevClose * 100;
      });

      expect(rateOfChange[0], isNull);

      // 2番目: (102 - 104) / 104 * 100 = -1.92%（下落）
      expect(rateOfChange[1], closeTo(-1.92, 0.01));

      // 3番目: (100 - 102) / 102 * 100 = -1.96%（下落）
      expect(rateOfChange[2], closeTo(-1.96, 0.01));

      // 4番目: (105 - 100) / 100 * 100 = 5.00%（上昇）
      expect(rateOfChange[3], closeTo(5.00, 0.01));
    });

    test('calculate average of current and next close using PipeList', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 103, close: 106),
        Kline.fromDouble(open: 106, high: 112, low: 105, close: 108),
      ];

      // nextを使って現在と次の終値の平均を計算
      final averages = klines.pipe<double?>((wrapper) {
        final next = wrapper.next;
        if (next == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final nextClose = next.body.close.toDouble();
        return (currentClose + nextClose) / 2;
      });

      // 1番目: (102 + 104) / 2 = 103
      expect(averages[0], closeTo(103.0, 0.01));

      // 2番目: (104 + 106) / 2 = 105
      expect(averages[1], closeTo(105.0, 0.01));

      // 3番目: (106 + 108) / 2 = 107
      expect(averages[2], closeTo(107.0, 0.01));

      // 最後の要素はnull（次の要素がないため）
      expect(averages[3], isNull);
    });

    test('calculate moving average using pipe with prev', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 100),
        Kline.fromDouble(open: 100, high: 106, low: 98, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 100, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 102, close: 106),
        Kline.fromDouble(open: 106, high: 112, low: 104, close: 108),
      ];

      // prevとcurrentを使って2期間の移動平均を計算
      final movingAvg = klines.pipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        return (currentClose + prevClose) / 2;
      });

      expect(movingAvg[0], isNull);
      expect(movingAvg[1], closeTo(101.0, 0.01)); // (100 + 102) / 2
      expect(movingAvg[2], closeTo(103.0, 0.01)); // (102 + 104) / 2
      expect(movingAvg[3], closeTo(105.0, 0.01)); // (104 + 106) / 2
      expect(movingAvg[4], closeTo(107.0, 0.01)); // (106 + 108) / 2
    });

    test('calculate moving average using cleanPipe with prev', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 100),
        Kline.fromDouble(open: 100, high: 106, low: 98, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 100, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 102, close: 106),
        Kline.fromDouble(open: 106, high: 112, low: 104, close: 108),
      ];

      // cleanPipeを使うとnullが除外される
      final movingAvg = klines.cleanPipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        return (currentClose + prevClose) / 2;
      });

      // nullが除外されるので長さは4
      expect(movingAvg.length, equals(4));
      expect(movingAvg[0], closeTo(101.0, 0.01)); // (100 + 102) / 2
      expect(movingAvg[1], closeTo(103.0, 0.01)); // (102 + 104) / 2
      expect(movingAvg[2], closeTo(105.0, 0.01)); // (104 + 106) / 2
      expect(movingAvg[3], closeTo(107.0, 0.01)); // (106 + 108) / 2
    });

    test('cleanPipe with next filters out null from last element', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 104),
        Kline.fromDouble(open: 104, high: 110, low: 103, close: 106),
        Kline.fromDouble(open: 106, high: 112, low: 105, close: 108),
      ];

      // nextを使って現在と次の終値の平均を計算
      final averages = klines.cleanPipe<double?>((wrapper) {
        final next = wrapper.next;
        if (next == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final nextClose = next.body.close.toDouble();
        return (currentClose + nextClose) / 2;
      });

      // 最後の要素のnullが除外されるので長さは3
      expect(averages.length, equals(3));
      expect(averages[0], closeTo(103.0, 0.01)); // (102 + 104) / 2
      expect(averages[1], closeTo(105.0, 0.01)); // (104 + 106) / 2
      expect(averages[2], closeTo(107.0, 0.01)); // (106 + 108) / 2
    });

    test('cleanPipe with conditional filtering', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 101, close: 104),
        Kline.fromDouble(open: 104, high: 106, low: 103, close: 103), // 下落
        Kline.fromDouble(open: 103, high: 110, low: 102, close: 108),
        Kline.fromDouble(open: 108, high: 115, low: 107, close: 112),
      ];

      // 前の足から上昇した場合のみ変動率を返す
      final uptrendRates = klines.cleanPipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        final currentClose = wrapper.body.close.toDouble();
        final prevClose = prev.body.close.toDouble();
        final rateOfChange = (currentClose - prevClose) / prevClose * 100;

        // 上昇した場合のみ返す（下落はnullを返して除外）
        return rateOfChange > 0 ? rateOfChange : null;
      });

      // 上昇したのは3回（インデックス1, 3, 4）
      expect(uptrendRates.length, equals(3));
      expect(uptrendRates[0], closeTo(1.96, 0.01)); // (104-102)/102*100
      expect(uptrendRates[1], closeTo(4.85, 0.01)); // (108-103)/103*100
      expect(uptrendRates[2], closeTo(3.70, 0.01)); // (112-108)/108*100
    });

    test('cleanPipe vs pipe comparison', () {
      final klines = [
        Kline.fromDouble(open: 100, high: 105, low: 99, close: 100),
        Kline.fromDouble(open: 100, high: 106, low: 98, close: 102),
        Kline.fromDouble(open: 102, high: 108, low: 100, close: 104),
      ];

      // pipeはnullを含む
      final withNull = klines.pipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        return wrapper.body.close.toDouble();
      });

      // cleanPipeはnullを除外
      final withoutNull = klines.cleanPipe<double?>((wrapper) {
        final prev = wrapper.prev;
        if (prev == null) {
          return null;
        }
        return wrapper.body.close.toDouble();
      });

      expect(withNull.length, equals(3));
      expect(withNull[0], isNull);
      expect(withNull[1], equals(102.0));
      expect(withNull[2], equals(104.0));

      expect(withoutNull.length, equals(2));
      expect(withoutNull[0], equals(102.0));
      expect(withoutNull[1], equals(104.0));
    });
  });

  group('correlation tests', () {
    test('perfect positive correlation (+1)', () {
      // 例: [1, 2, 3, 3] と [3, 4, 5, 5]
      // 一方が増えるともう一方も同じ割合で増える
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
        Decimal.fromInt(3),
      ];
      final list2 = [
        Decimal.fromInt(3),
        Decimal.fromInt(4),
        Decimal.fromInt(5),
        Decimal.fromInt(5),
      ];

      final correlation = list1.correlation(list2);
      expect(correlation, closeTo(1.0, 0.0001));
    });

    test('perfect positive correlation with alternating pattern (+1)', () {
      // 例: [1, 3, 1, 3] と [5, 7, 5, 7]
      // パターンが同じであれば完全な正の相関
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(3),
        Decimal.fromInt(1),
        Decimal.fromInt(3),
      ];
      final list2 = [
        Decimal.fromInt(5),
        Decimal.fromInt(7),
        Decimal.fromInt(5),
        Decimal.fromInt(7),
      ];

      final correlation = list1.correlation(list2);
      expect(correlation, closeTo(1.0, 0.0001));
    });

    test('perfect negative correlation (-1)', () {
      // 一方が増えるともう一方は減る
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
        Decimal.fromInt(4),
      ];
      final list2 = [
        Decimal.fromInt(4),
        Decimal.fromInt(3),
        Decimal.fromInt(2),
        Decimal.fromInt(1),
      ];

      final correlation = list1.correlation(list2);
      expect(correlation, closeTo(-1.0, 0.0001));
    });

    test('weak correlation', () {
      // より相関の弱いパターン
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(5),
        Decimal.fromInt(2),
        Decimal.fromInt(6),
        Decimal.fromInt(3),
      ];
      final list2 = [
        Decimal.fromInt(3),
        Decimal.fromInt(2),
        Decimal.fromInt(4),
        Decimal.fromInt(1),
        Decimal.fromInt(5),
      ];

      final correlation = list1.correlation(list2);
      // 相関が弱いことを確認（絶対値が1よりかなり小さい）
      expect(correlation.abs(), lessThan(0.8));
    });

    test('strong positive correlation (not perfect)', () {
      // おおよそ正の相関があるが完全ではない
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
        Decimal.fromInt(4),
        Decimal.fromInt(5),
      ];
      final list2 = [
        Decimal.fromInt(2),
        Decimal.fromInt(4),
        Decimal.fromInt(5),
        Decimal.fromInt(7),
        Decimal.fromInt(10),
      ];

      final correlation = list1.correlation(list2);
      expect(correlation, greaterThan(0.9));
      expect(correlation, lessThanOrEqualTo(1.0));
    });

    test('decimal values correlation', () {
      // 完全に線形な関係: y = 2x + 8
      // x: 1.5, 2.5, 3.5, 4.5
      // y: 11, 13, 15, 17
      final list1 = [
        Decimal.parse('1.5'),
        Decimal.parse('2.5'),
        Decimal.parse('3.5'),
        Decimal.parse('4.5'),
      ];
      final list2 = [
        Decimal.parse('11'),
        Decimal.parse('13'),
        Decimal.parse('15'),
        Decimal.parse('17'),
      ];

      final correlation = list1.correlation(list2);
      expect(correlation, closeTo(1.0, 0.0001));
    });

    test('throws on empty list', () {
      final empty = <Decimal>[];
      final other = [Decimal.fromInt(1), Decimal.fromInt(2)];

      expect(
        () => empty.correlation(other),
        throwsArgumentError,
      );
    });

    test('throws on different length lists', () {
      final list1 = [Decimal.fromInt(1), Decimal.fromInt(2)];
      final list2 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
      ];

      expect(
        () => list1.correlation(list2),
        throwsArgumentError,
      );
    });

    test('throws on single element', () {
      final list1 = [Decimal.fromInt(1)];
      final list2 = [Decimal.fromInt(2)];

      expect(
        () => list1.correlation(list2),
        throwsArgumentError,
      );
    });

    test('throws on zero variance (all same values)', () {
      final list1 = [
        Decimal.fromInt(5),
        Decimal.fromInt(5),
        Decimal.fromInt(5),
      ];
      final list2 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
      ];

      expect(
        () => list1.correlation(list2),
        throwsStateError,
      );
    });

    test('symmetry property (correlation(A, B) = correlation(B, A))', () {
      final list1 = [
        Decimal.fromInt(1),
        Decimal.fromInt(2),
        Decimal.fromInt(3),
        Decimal.fromInt(4),
      ];
      final list2 = [
        Decimal.fromInt(2),
        Decimal.fromInt(4),
        Decimal.fromInt(5),
        Decimal.fromInt(7),
      ];

      final correlation1 = list1.correlation(list2);
      final correlation2 = list2.correlation(list1);

      expect(correlation1, closeTo(correlation2, 0.0001));
    });
  });
}
