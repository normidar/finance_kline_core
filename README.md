# finance_kline_core

[![GitHub](https://img.shields.io/github/license/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/finance_kline_core.svg)](https://pub.dartlang.org/packages/finance_kline_core)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/stargazers)

A Dart package for financial candlestick (K-line) data analysis.
Provides technical indicators, K-line merging, signal detection, and a multi-timeframe engine.

📖 **[日本語ドキュメント (Japanese Documentation)](README_ja.md)**

---

## Features

- **Technical Indicators** — EMA, SMA, MACD, RSI, Linear Regression, Pearson Correlation
- **K-line Merging** — Convert lower timeframes to higher (e.g. 1m → 5m) with flexible alignment/mode options
- **Signal Architecture** — Pluggable `SignalLogic` / `SignalParams` / `SignalSeries` for composable strategies
- **Multi-Timeframe Engine** — `FKCEngine` manages multiple timeframes and iterates bar-by-bar
- **Pipeline Utilities** — `PipeList` for context-aware iteration over bar series

---

## Installation

```yaml
dependencies:
  finance_kline_core: ^0.0.4
```

---

## Usage

### Creating OHLCV Data

```dart
import 'package:finance_kline_core/finance_kline_core.dart';

final ohlcv = Ohlcv(
  open: 100.0,
  high: 105.0,
  low:  99.0,
  close: 103.0,
  volume: 1000000.0,
  openTimestamp:  1700000000000,
  closeTimestamp: 1700000059999,
);

final series = OhlcvSeries(data: [ohlcv, /* ... */]);
```

---

### Technical Indicators

All indicators are available as extension methods on `List<double>` (`DecList`),
or via cached methods on `OhlcvSeries`.

```dart
// ── via OhlcvSeries ──────────────────────────────────────────────
final ema12  = series.ema(period: 12);
final ema26  = series.ema(period: 26, priceType: PriceType.high);
final macd   = series.macd(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9);
final rsi    = series.rsi(period: 14);

// ── via DecList (List<double>) ───────────────────────────────────
final closes = series.closes;
final sma20  = closes.sma(20);
final fit    = closes.linearFit();

print('slope:     ${fit.slope}');
print('intercept: ${fit.intercept}');
print('R²:        ${fit.rSquared}');
print('next pred: ${fit.predict(closes.length.toDouble())}');
```

---

### K-line Merging

`OhlcvSeries.merge(n)` combines every `n` bars into one.

```dart
// 1-minute → 5-minute (left-aligned, strict)
final fiveMin = oneMin.merge(5);

// Right-aligned: anchor from newest bar, keep partial (incomplete) chunk
final rightPartial = series.merge(3,
  alignment: MergeAlignment.right,
  mode: MergeMode.partial,
);
```

**Merge rules:** `open` = first, `high` = max, `low` = min, `close` = last, `volume` = sum.

| | `strict` | `partial` |
|---|---|---|
| `left`  | Drop trailing incomplete chunk | Keep trailing incomplete chunk |
| `right` | Drop leading incomplete chunk  | Keep leading incomplete chunk  |

---

### Signal Logic

Use `SignalLogic` + `SignalParams` to compute indicator signals.

```dart
// EMA cross detection
final emaResult = EmaLogic().calculate(
  params: EmaParams(periods: {12, 26}),
  data: series.closes,
) as EmaSeries;

if (emaResult.isBullishCross(fast: 12, slow: 26)) {
  print('Golden cross → buy signal');
}
if (emaResult.isBearishCross(fast: 12, slow: 26)) {
  print('Dead cross → sell signal');
}

// RSI overbought / oversold
final rsiParams = RsiParams(period: 14, overbought: 70, oversold: 30);
final rsiResult = RsiLogic().calculate(
  params: rsiParams,
  data: series.closes,
) as RsiSeries;

switch (rsiResult.stateOf(rsiParams)) {
  case RsiState.overbought: print('Overbought');
  case RsiState.oversold:   print('Oversold');
  case RsiState.neutral:    print('Neutral');
}

// MACD cross detection
final macdResult = MacdLogic().calculate(
  params: MacdParams(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9),
  data: series.closes,
) as MacdSeries;

if (macdResult.isBullishCross) print('MACD golden cross');
if (macdResult.isBearishCross) print('MACD dead cross');
```

You can also compute from an `OhlcvSeries` with a chosen price type:

```dart
final result = MacdLogic().calculateWithKline(
  klineSeries: series,
  priceType: PriceType.close,
  params: MacdParams(),
) as MacdSeries;
```

---

### Multi-Timeframe Engine

`FKCEngine` iterates bar-by-bar over the base timeframe, calling your function with
data up to and including each bar.

```dart
final engine = FKCEngine(baseInterval: Interval.$1m);
engine.addOhlcvSeries(Interval.$1m, oneMinSeries);
engine.addOhlcvSeries(Interval.$1h, oneHourSeries);

// analyze returns a List<T>, one value per bar from `start` to end
final signals = engine.analyze<bool>(
  start: 33,  // MACD warm-up: slowPeriod(26) + signalPeriod(9) - 2
  func: (wrapper) {
    // `wrapper.ohlcvSeries` is sliced to the current bar
    final result = MacdLogic().calculateWithKline(
      klineSeries: wrapper.ohlcvSeries,
      priceType: PriceType.close,
      params: MacdParams(),
    ) as MacdSeries;

    return result.isBullishCross;
  },
);
```

You can also call `analyze` directly on a wrapper:

```dart
final signals = engine.select(Interval.$1m)!.analyze(
  start: 33,
  func: (wrapper) { /* ... */ },
);
```

#### Multi-Timeframe (MTF) inside analyze

`jumpTo` inside an `analyze` loop automatically filters to data up to the
current bar's timestamp — preventing look-ahead bias.

```dart
engine.analyze<String>(
  start: 26,
  func: (wrapper) {
    // 1-hour data sliced to current bar's time
    final hourly = wrapper.jumpTo(Interval.$1h);
    final trend = hourly?.ohlcvSeries.closes.sma(20);
    // ...
    return 'signal';
  },
);
```

---

### Pipeline Utilities

`PipeList` lets you access previous/next bars in a context-aware loop:

```dart
final results = series.closes.pipe((wrapper) {
  final curr = wrapper.getBody(0);
  final prev = wrapper.prev;   // previous element (nullable)
  final next = wrapper.next;   // next element (nullable)
  return (prev != null && curr > prev) ? 'up' : 'down';
});
```

---

## API Reference

### Enums

| Enum | Values |
|---|---|
| `Interval` | `$1s` `$1m` `$3m` `$5m` `$15m` `$30m` `$1h` `$2h` `$4h` `$6h` `$8h` `$12h` `$1d` `$2d` `$3d` `$1w` `$1M` |
| `PriceType` | `open` `high` `low` `close` |
| `MergeAlignment` | `left` `right` |
| `MergeMode` | `strict` `partial` |

### `Ohlcv`

Immutable OHLCV bar (`@freezed`). Supports `toJson` / `fromJson`.

| Property | Type | Description |
|---|---|---|
| `open` / `high` / `low` / `close` | `double` | OHLC prices |
| `volume` | `double` | Trading volume |
| `openTimestamp` / `closeTimestamp` | `int` | Unix ms timestamps |

### `OhlcvSeries`

Wraps `List<Ohlcv>` with cached indicator methods.

| Method | Returns | Description |
|---|---|---|
| `ema({period, priceType})` | `List<double?>` | Exponential Moving Average |
| `macd({fastPeriod, slowPeriod, signalPeriod, priceType})` | `List<Macd?>` | MACD |
| `rsi({period, priceType})` | `List<Rsi?>` | RSI |
| `merge(n, {alignment, mode})` | `OhlcvSeries` | Merge n bars into one |
| `subUpToTimestamp(ts)` | `OhlcvSeries` | Filter to bars ≤ timestamp |
| `subByTimestamp({start, end})` | `List<Ohlcv>` | Slice by timestamp range |

### `DecList` / `DecListX`

Extension methods on `List<double>`.

| Method | Returns |
|---|---|
| `ema(period)` | `List<double?>` |
| `sma(period)` | `List<double?>` |
| `macd({fastPeriod, slowPeriod, signalPeriod})` | `List<Macd?>` |
| `rsi(period)` | `List<Rsi?>` |
| `linearFit()` | `LinearFitResult` |
| `correlation(other)` | `double` |

### Signal Classes

| Class | Key API |
|---|---|
| `EmaSeries` | `operator[](period)`, `isBullishCross(fast:, slow:)`, `isBearishCross(fast:, slow:)` |
| `RsiSeries` | `last`, `stateOf(RsiParams)` → `RsiState` |
| `MacdSeries` | `last`, `isBullishCross`, `isBearishCross` |

---

## License

MIT License — see [LICENSE](LICENSE) for details.

## Links

- [GitHub Repository](https://github.com/normidar/finance_kline_core)
- [Pub Package](https://pub.dartlang.org/packages/finance_kline_core)
- [Issue Tracker](https://github.com/normidar/finance_kline_core/issues)
