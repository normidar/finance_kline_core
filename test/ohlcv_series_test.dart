import 'package:finance_kline_core/finance_kline_core.dart';
import 'package:test/test.dart';

void main() {
  // ─── merge: left + strict ──────────────────────────────────────────────────

  group('merge left+strict（デフォルト）', () {
    // 5本 → 2本ずつマージ → [0,1] [2,3]  残り[4]は端数で捨てる
    final s = makeMinuteSeries(5);

    test('端数チャンクが捨てられる', () {
      expect(s.merge(2).length, 2);
    });

    test('open は先頭の open', () {
      expect(s.merge(2)[0].open, 100.0);
      expect(s.merge(2)[1].open, 102.0);
    });

    test('close は末尾の close', () {
      expect(s.merge(2)[0].close, 103.0); // index 1 の close
      expect(s.merge(2)[1].close, 105.0); // index 3 の close
    });

    test('high は最大値', () {
      expect(s.merge(2)[0].high, 106.0); // max(105, 106)
    });

    test('low は最小値', () {
      expect(s.merge(2)[0].low, 99.0); // min(99, 100)
    });

    test('volume は合計', () {
      expect(s.merge(2)[0].volume, 2000.0);
    });

    test('openTimestamp は先頭、closeTimestamp は末尾', () {
      final bar = s.merge(2)[0];
      expect(bar.openTimestamp, 0);
      expect(bar.closeTimestamp, 119999); // index 1 の closeTimestamp
    });
  });

  // ─── merge: left + partial ────────────────────────────────────────────────

  group('merge left+partial', () {
    final s = makeMinuteSeries(5);

    test('端数チャンクも含まれる', () {
      expect(s.merge(2, mode: MergeMode.partial).length, 3);
    });

    test('最後のチャンクは 1 本のみ', () {
      final last = s.merge(2, mode: MergeMode.partial).last;
      expect(last.open, 104.0);
      expect(last.close, 106.0);
    });
  });

  // ─── merge: right + strict ───────────────────────────────────────────────

  group('merge right+strict', () {
    // 5本 → 2本ずつ右から → [3,4] [1,2]  残り[0]は端数で捨てる
    final s = makeMinuteSeries(5);

    test('端数チャンクが捨てられる', () {
      expect(s.merge(2, alignment: MergeAlignment.right).length, 2);
    });

    test('最新のチャンクが最後', () {
      final last = s.merge(2, alignment: MergeAlignment.right).last;
      expect(last.close, 106.0); // index 4 の close
    });

    test('チャンクは時刻昇順', () {
      final result = s.merge(2, alignment: MergeAlignment.right);
      expect(
        result[0].openTimestamp < result[1].openTimestamp,
        isTrue,
      );
    });
  });

  // ─── merge: right + partial ──────────────────────────────────────────────

  group('merge right+partial', () {
    final s = makeMinuteSeries(5);

    test('端数チャンクも含まれる', () {
      expect(
        s
            .merge(2, alignment: MergeAlignment.right, mode: MergeMode.partial)
            .length,
        3,
      );
    });

    test('先頭チャンクが端数（1本）', () {
      final first = s
          .merge(
            2,
            alignment: MergeAlignment.right,
            mode: MergeMode.partial,
          )
          .first;
      expect(first.open, 100.0);
      expect(first.close, 102.0);
    });
  });

  // ─── merge: エッジケース ─────────────────────────────────────────────────

  group('merge エッジケース', () {
    test('n=1 はコピーを返す', () {
      expect(makeMinuteSeries(5).merge(1).length, 5);
    });

    test('空シリーズは空を返す', () {
      expect(OhlcvSeries(data: []).merge(3).length, 0);
    });

    test('n <= 0 で ArgumentError', () {
      expect(() => makeMinuteSeries(3).merge(0), throwsArgumentError);
    });

    test('n がデータ長より大きい場合 strict は空', () {
      expect(makeMinuteSeries(3).merge(5).length, 0);
    });

    test('n がデータ長より大きい場合 partial は 1 チャンク', () {
      expect(
        makeMinuteSeries(3).merge(5, mode: MergeMode.partial).length,
        1,
      );
    });
  });

  // ─── subUpToTimestamp ────────────────────────────────────────────────────

  group('subUpToTimestamp', () {
    final s =
        makeMinuteSeries(5); // closeTimestamps: 59999, 119999, 179999, ...

    test('指定以前のバーのみ返す', () {
      final result = s.subUpToTimestamp(119999); // index 0, 1
      expect(result.length, 2);
    });

    test('空のシリーズを返す（全バーより古い）', () {
      expect(s.subUpToTimestamp(0).length, 0);
    });

    test('全バー返す（最後の closeTimestamp）', () {
      expect(s.subUpToTimestamp(300000).length, 5);
    });
  });

  // ─── Series キャッシュの正確性 ───────────────────────────────────────────

  group('Series MACD キャッシュ', () {
    final data = List.generate(
      50,
      (i) => Ohlcv(
        open: 100,
        high: 105,
        low: 99,
        close: 100.0 + i * 0.5,
        volume: 1000,
        openTimestamp: i * 60000,
        closeTimestamp: (i + 1) * 60000 - 1,
      ),
    );
    final series = OhlcvSeries(data: data);

    test('同じパラメータは同一インスタンスを返す', () {
      final a = series.macd();
      final b = series.macd();
      expect(identical(a, b), isTrue);
    });

    test('異なるパラメータは別の結果を返す', () {
      final a = series.macd(fastPeriod: 3, slowPeriod: 6, signalPeriod: 3);
      final b = series.macd(fastPeriod: 5, slowPeriod: 10, signalPeriod: 5);
      expect(identical(a, b), isFalse);
    });
  });

  group('Series EMA キャッシュ (priceType 別)', () {
    final data = List.generate(
      20,
      (i) => Ohlcv(
        open: 90.0 + i,
        high: 105.0 + i,
        low: 99.0 + i,
        close: 100.0 + i,
        volume: 1000,
        openTimestamp: i * 60000,
        closeTimestamp: (i + 1) * 60000 - 1,
      ),
    );
    final series = OhlcvSeries(data: data);

    test('period が同じでも priceType が違えば別の結果', () {
      final closeEma = series.ema(period: 5);
      final highEma = series.ema(period: 5, priceType: PriceType.high);
      expect(identical(closeEma, highEma), isFalse);
      // close と high の値は異なるはずなので末尾の非 null を比較
      final closeVal = closeEma.whereType<double>().last;
      final highVal = highEma.whereType<double>().last;
      expect(closeVal, isNot(equals(highVal)));
    });

    test('同じ priceType の再呼び出しはキャッシュ済みインスタンスを返す', () {
      final a = series.ema(period: 5);
      final b = series.ema(period: 5);
      expect(identical(a, b), isTrue);
    });
  });
}

/// タイムスタンプ付きの OhlcvSeries を生成するヘルパー
///
/// バー n 本: closeTimestamp は 1分ずつ増加
OhlcvSeries makeMinuteSeries(int count) {
  const minuteMs = 60000;
  final data = List.generate(
    count,
    (i) => Ohlcv(
      open: 100.0 + i,
      high: 105.0 + i,
      low: 99.0 + i,
      close: 102.0 + i,
      volume: 1000,
      openTimestamp: i * minuteMs,
      closeTimestamp: (i + 1) * minuteMs - 1,
    ),
  );
  return OhlcvSeries(data: data);
}
