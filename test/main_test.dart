import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/src/type/dec_list.dart';
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
}
