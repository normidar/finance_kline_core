import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  // ─── EMA ───────────────────────────────────────────────────────────────────

  group('EMA', () {
    // [10, 11, 12, 13, 14]、period=3
    // index 0,1 : null
    // index 2   : SMA = (10+11+12)/3 = 11.0
    // index 3   : (13-11) * 0.5 + 11 = 12.0
    // index 4   : (14-12) * 0.5 + 12 = 13.0
    final data = [10.0, 11.0, 12.0, 13.0, 14.0];

    test('先頭 period-1 個が null', () {
      final result = EmaLogic.compute(data, 3);
      expect(result[0], isNull);
      expect(result[1], isNull);
    });

    test('最初の非 null 値は SMA で初期化される', () {
      expect(EmaLogic.compute(data, 3)[2], 11.0);
    });

    test('後続の値が正しく計算される', () {
      final result = EmaLogic.compute(data, 3);
      expect(result[3], 12.0);
      expect(result[4], 13.0);
    });

    test('入力と同じ長さを返す', () {
      expect(EmaLogic.compute(data, 3).length, data.length);
    });

    test('period <= 0 で ArgumentError', () {
      expect(() => EmaLogic.compute(data, 0), throwsArgumentError);
    });

    test('空リストは空を返す', () {
      expect(EmaLogic.compute(<double>[], 3), isEmpty);
    });

    test('period と同じ長さのデータは 1 つだけ非 null', () {
      final result = EmaLogic.compute([1.0, 2.0, 3.0], 3);
      expect(result.where((v) => v != null).length, 1);
    });
  });

  // ─── SMA ───────────────────────────────────────────────────────────────────

  group('SMA', () {
    final data = [10.0, 11.0, 12.0, 13.0, 14.0];

    test('先頭 period-1 個が null', () {
      final result = data.sma(3);
      expect(result[0], isNull);
      expect(result[1], isNull);
    });

    test('ローリング平均が正しい', () {
      final result = data.sma(3);
      expect(result[2], 11.0); // (10+11+12)/3
      expect(result[3], 12.0); // (11+12+13)/3
      expect(result[4], 13.0); // (12+13+14)/3
    });

    test('入力と同じ長さを返す', () {
      expect(data.sma(3).length, data.length);
    });

    test('period <= 0 で ArgumentError', () {
      expect(() => data.sma(0), throwsArgumentError);
    });
  });

  // ─── MACD ──────────────────────────────────────────────────────────────────

  group('MACD', () {
    final data = List.generate(50, (i) => 100.0 + i * 0.5);

    test('入力と同じ長さを返す', () {
      expect(MacdLogic.compute(data).length, data.length);
    });

    test('ウォームアップ期間は null', () {
      // fastPeriod=3, slowPeriod=6, signalPeriod=3
      // MACDライン確定: index 5 (slowPeriod-1)
      // シグナル確定:   index 5 + (signalPeriod-1) = 7
      final result = MacdLogic.compute(
        data,
        fastPeriod: 3,
        slowPeriod: 6,
        signalPeriod: 3,
      );
      for (var i = 0; i < 7; i++) {
        expect(result[i], isNull, reason: 'index $i は null のはず');
      }
    });

    test('histogram = macdLine - signalLine', () {
      final result = MacdLogic.compute(
        data,
        fastPeriod: 3,
        slowPeriod: 6,
        signalPeriod: 3,
      );
      for (final m in result) {
        if (m != null) {
          expect(
            m.histogram,
            closeTo(m.macdLine - m.signalLine, 1e-10),
          );
        }
      }
    });

    test('fastPeriod >= slowPeriod で ArgumentError', () {
      expect(
        () => MacdLogic.compute(data, fastPeriod: 26, slowPeriod: 12),
        throwsArgumentError,
      );
    });

    test('空リストは空を返す', () {
      expect(MacdLogic.compute(<double>[]), isEmpty);
    });
  });

  // ─── RSI ───────────────────────────────────────────────────────────────────

  group('RSI', () {
    final data = List.generate(30, (i) => 100.0 + (i % 5 == 0 ? -2.0 : 1.0));

    test('入力と同じ長さを返す', () {
      expect(RsiLogic.compute(data, 14).length, data.length);
    });

    test('先頭 period 個が null', () {
      final result = RsiLogic.compute(data, 14);
      for (var i = 0; i < 14; i++) {
        expect(result[i], isNull, reason: 'index $i は null のはず');
      }
    });

    test('非 null 値は 0〜100 の範囲', () {
      for (final r in RsiLogic.compute(data, 14)) {
        if (r != null) {
          expect(r.value, inInclusiveRange(0.0, 100.0));
        }
      }
    });

    test('損失なしのデータは RSI が非常に高い（≥99）', () {
      // avgLoss=0 のとき実装は RS=100 を使うため RSI=100-100/101≈99.01
      final alwaysUp = List.generate(20, (i) => 100.0 + i.toDouble());
      final firstNonNull = RsiLogic.compute(alwaysUp, 5).whereType<Rsi>().first;
      expect(firstNonNull.value, greaterThanOrEqualTo(99.0));
    });

    test('利益なしのデータは RSI=0', () {
      final alwaysDown = List.generate(20, (i) => 100.0 - i.toDouble());
      final firstNonNull =
          RsiLogic.compute(alwaysDown, 5).whereType<Rsi>().first;
      expect(firstNonNull.value, 0.0);
    });

    test('period <= 0 で ArgumentError', () {
      expect(() => RsiLogic.compute(data, 0), throwsArgumentError);
    });
  });

  // ─── linearFit ─────────────────────────────────────────────────────────────

  group('linearFit', () {
    test('完全な線形データは R²=1.0、slope=1.0', () {
      final data = [1.0, 2.0, 3.0, 4.0, 5.0]; // y = x + 1
      final fit = data.linearFit();
      expect(fit.rSquared, closeTo(1.0, 1e-10));
      expect(fit.slope, closeTo(1.0, 1e-10));
    });

    test('y=2x に相当するデータで slope≈2', () {
      final data = [0.0, 2.0, 4.0, 6.0, 8.0];
      final fit = data.linearFit();
      expect(fit.slope, closeTo(2.0, 1e-10));
    });

    test('predict が正しい値を返す', () {
      final fit = [0.0, 2.0, 4.0, 6.0, 8.0].linearFit();
      expect(fit.predict(5), closeTo(10.0, 1e-10));
    });

    test('全て同じ値は R²=1.0', () {
      expect([5.0, 5.0, 5.0, 5.0].linearFit().rSquared, 1.0);
    });

    test('空リストで ArgumentError', () {
      expect(() => <double>[].linearFit(), throwsArgumentError);
    });

    test('要素 1 つで ArgumentError', () {
      expect(() => [1.0].linearFit(), throwsArgumentError);
    });
  });

  // ─── correlation ───────────────────────────────────────────────────────────

  group('correlation', () {
    test('完全な正の相関は +1.0', () {
      final a = [1.0, 2.0, 3.0, 4.0, 5.0];
      final b = [2.0, 4.0, 6.0, 8.0, 10.0];
      expect(a.correlation(b), closeTo(1.0, 1e-10));
    });

    test('完全な負の相関は -1.0', () {
      final a = [1.0, 2.0, 3.0, 4.0, 5.0];
      final b = [5.0, 4.0, 3.0, 2.0, 1.0];
      expect(a.correlation(b), closeTo(-1.0, 1e-10));
    });

    test('長さが違うと ArgumentError', () {
      expect(
        () => [1.0, 2.0].correlation([1.0, 2.0, 3.0]),
        throwsArgumentError,
      );
    });
  });
}
