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
}
