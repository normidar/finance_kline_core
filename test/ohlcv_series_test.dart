import 'package:decimal/decimal.dart';
import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  group('OhlcvSeries.subByTimestamp', () {
    late List<Ohlcv> testData;
    late OhlcvSeries series;

    setUp(() {
      testData = [
        Ohlcv(
          open: Decimal.parse('100'),
          high: Decimal.parse('110'),
          low: Decimal.parse('90'),
          close: Decimal.parse('105'),
          volume: Decimal.parse('1000'),
          openTimestamp: 1000,
          closeTimestamp: 2000,
        ),
        Ohlcv(
          open: Decimal.parse('105'),
          high: Decimal.parse('115'),
          low: Decimal.parse('95'),
          close: Decimal.parse('110'),
          volume: Decimal.parse('1100'),
          openTimestamp: 2000,
          closeTimestamp: 3000,
        ),
        Ohlcv(
          open: Decimal.parse('110'),
          high: Decimal.parse('120'),
          low: Decimal.parse('100'),
          close: Decimal.parse('115'),
          volume: Decimal.parse('1200'),
          openTimestamp: 3000,
          closeTimestamp: 4000,
        ),
        Ohlcv(
          open: Decimal.parse('115'),
          high: Decimal.parse('125'),
          low: Decimal.parse('105'),
          close: Decimal.parse('120'),
          volume: Decimal.parse('1300'),
          openTimestamp: 4000,
          closeTimestamp: 5000,
        ),
        Ohlcv(
          open: Decimal.parse('120'),
          high: Decimal.parse('130'),
          low: Decimal.parse('110'),
          close: Decimal.parse('125'),
          volume: Decimal.parse('1400'),
          openTimestamp: 5000,
          closeTimestamp: 6000,
        ),
      ];
      series = OhlcvSeries(data: testData);
    });

    test('should throw UnsupportedError when data length is less than 2', () {
      final emptyData = <Ohlcv>[];
      final emptySeries = OhlcvSeries(data: emptyData);
      expect(
        emptySeries.subByTimestamp,
        throwsA(isA<UnsupportedError>()),
      );

      final singleData = [testData[0]];
      final singleSeries = OhlcvSeries(data: singleData);
      expect(
        singleSeries.subByTimestamp,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should return all data when no parameters are provided', () {
      final result = series.subByTimestamp();
      expect(result.length, equals(4));
      expect(result.first.openTimestamp, equals(1000));
      expect(result.last.closeTimestamp, equals(5000));
    });

    test('should filter by start timestamp', () {
      final result = series.subByTimestamp(start: 3000);
      expect(result.length, equals(2));
      expect(result.first.openTimestamp, equals(3000));
      expect(result.last.closeTimestamp, equals(5000));
    });

    test('should filter by end timestamp', () {
      final result = series.subByTimestamp(end: 4000);
      expect(result.length, equals(3));
      expect(result.first.openTimestamp, equals(1000));
      expect(result.last.closeTimestamp, equals(4000));
    });

    test('should filter by both start and end timestamps', () {
      final result = series.subByTimestamp(start: 2000, end: 4000);
      expect(result.length, equals(2));
      expect(result.first.openTimestamp, equals(2000));
      expect(result.last.closeTimestamp, equals(4000));
    });

    test('should throw UnsupportedError when end is after last closeTimestamp',
        () {
      expect(
        () => series.subByTimestamp(end: 7000),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test(
        'should throw UnsupportedError when start is before first openTimestamp',
        () {
      expect(
        () => series.subByTimestamp(start: 500),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should handle exact boundary timestamps for start', () {
      final result = series.subByTimestamp(start: 1000);
      expect(result.length, equals(4));
      expect(result.first.openTimestamp, equals(1000));
    });

    test('should handle exact boundary timestamps for end', () {
      final result = series.subByTimestamp(end: 6000);
      expect(result.length, equals(5));
      expect(result.last.closeTimestamp, equals(6000));
    });

    test('should handle timestamps between intervals', () {
      final result = series.subByTimestamp(start: 2500);
      expect(result.length, equals(3));
      expect(result.first.openTimestamp, equals(2000));
    });

    test('should work with narrow range', () {
      final result = series.subByTimestamp(start: 3000, end: 4000);
      expect(result.length, equals(1));
      expect(result.first.openTimestamp, equals(3000));
      expect(result.first.closeTimestamp, equals(4000));
    });

    test('should calculate correct indices with interval division', () {
      final result = series.subByTimestamp(start: 1000, end: 5000);
      expect(result.length, equals(4));
      expect(result.first.openTimestamp, equals(1000));
      expect(result.last.closeTimestamp, equals(5000));
    });

    test('should handle only start parameter at last data point', () {
      final result = series.subByTimestamp(start: 5000);
      expect(result.length, equals(0));
    });

    test('should handle only end parameter at first data point', () {
      final result = series.subByTimestamp(end: 2000);
      expect(result.length, equals(1));
      expect(result.first.closeTimestamp, equals(2000));
    });
  });
}
