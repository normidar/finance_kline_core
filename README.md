# finance_kline_core

[![GitHub](https://img.shields.io/github/license/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/finance_kline_core.svg)](https://pub.dartlang.org/packages/finance_kline_core)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/stargazers)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/normidar2.svg?style=social&label=Follow%20%40normidar2)](https://twitter.com/normidar2)
[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/normidar)

A comprehensive Dart package for financial candlestick (K-line) data analysis with technical indicators, statistical analysis, and precision decimal calculations.

📖 **[日本語ドキュメント (Japanese Documentation)](README_ja.md)**

---

### Features

- **Technical Indicators**

  - EMA (Exponential Moving Average) - Fast-responsive trend following
  - SMA (Simple Moving Average) - Classic trend analysis
  - MACD (Moving Average Convergence Divergence) - Momentum and trend strength

- **Statistical Analysis**

  - Linear Regression with R² (Coefficient of Determination)
  - Price Prediction using linear fitting
  - Trend analysis with confidence metrics

- **K-line Operations**

  - Flexible K-line merging with alignment options (left/right)
  - Multiple merge modes (strict/partial)
  - Conversion between Kline and OHLCV formats

- **Precision Calculations**
  - Uses `Decimal` type for accurate financial calculations
  - Avoids floating-point precision errors
  - Configurable decimal scale

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  finance_kline_core: ^0.0.1
```

Then run:

```bash
dart pub get
```

### Usage Examples

#### Creating K-lines

```dart
import 'package:finance_kline_core/finance_kline_core.dart';

// Create from double values
final kline = Kline.fromDouble(
  open: 100.0,
  high: 105.0,
  low: 99.0,
  close: 103.0,
  scale: 4,  // Decimal precision
);

// Create from Decimal values
final klineDecimal = Kline(
  open: Decimal.parse('100.0000'),
  high: Decimal.parse('105.0000'),
  low: Decimal.parse('99.0000'),
  close: Decimal.parse('103.0000'),
);

// Create OHLCV with volume
final ohlcv = Ohlcv(
  open: Decimal.parse('100.0'),
  high: Decimal.parse('105.0'),
  low: Decimal.parse('99.0'),
  close: Decimal.parse('103.0'),
  volume: Decimal.parse('1000000.0'),
);
```

#### Calculating Technical Indicators

```dart
// Create a series of K-lines
final klineSeries = <Kline>[
  Kline.fromDouble(open: 100, high: 105, low: 99, close: 103),
  Kline.fromDouble(open: 103, high: 108, low: 102, close: 106),
  Kline.fromDouble(open: 106, high: 110, low: 105, close: 108),
  // ... more klines
];

// Calculate EMA (Exponential Moving Average)
final ema12 = klineSeries.ema(period: 12);
final ema26 = klineSeries.ema(period: 26);

// Calculate on different price types
final emaHigh = klineSeries.ema(
  period: 12,
  priceType: PriceType.high,
);

// Calculate SMA (Simple Moving Average)
final closes = klineSeries.closes;
final sma20 = closes.sma(20);

// Calculate MACD
final macd = klineSeries.macd(
  fastPeriod: 12,
  slowPeriod: 26,
  signalPeriod: 9,
);

// Check MACD signals
for (final m in macd) {
  if (m != null) {
    if (m.isBullish) {
      print('Buy signal: MACD line above signal line');
    } else if (m.isBearish) {
      print('Sell signal: MACD line below signal line');
    }
  }
}
```

#### Linear Regression and Prediction

```dart
// Get closing prices
final closes = klineSeries.closes;

// Perform linear regression
final fit = closes.linearFit();
print('Slope: ${fit.slope}');
print('Intercept: ${fit.intercept}');
print('R²: ${fit.rSquared}');  // Closer to 1.0 means better fit

// Predict future values
final nextValue = fit.predict(closes.length.toDouble() + 1);
print('Predicted next close: $nextValue');

// Predict the next K-line
final nextKline = klineSeries.predictNext(scale: 4);
print('Predicted next K-line:');
print('  Open: ${nextKline.open}');
print('  High: ${nextKline.high}');
print('  Low: ${nextKline.low}');
print('  Close: ${nextKline.close}');
```

#### Merging K-lines

```dart
// Merge K-lines with different strategies

// Left-aligned merge (from oldest data)
// Drops incomplete chunks at the end
final mergedLeft = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.left,
  mode: MergeMode.strict,
);

// Right-aligned merge (from newest data)
// Drops incomplete chunks at the beginning
final mergedRight = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.right,
  mode: MergeMode.strict,
);

// Partial mode: includes incomplete chunks
final mergedPartial = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.left,
  mode: MergeMode.partial,
);

// Merged K-line combines:
// - open: first K-line's open
// - high: highest of all highs
// - low: lowest of all lows
// - close: last K-line's close
```

#### Working with OHLCV Data

```dart
final ohlcvSeries = <Ohlcv>[
  Ohlcv(
    open: Decimal.parse('100'),
    high: Decimal.parse('105'),
    low: Decimal.parse('99'),
    close: Decimal.parse('103'),
    volume: Decimal.parse('1000000'),
  ),
  // ... more OHLCV data
];

// Extract specific price series
final closes = ohlcvSeries.closes;
final highs = ohlcvSeries.highs;
final volumes = ohlcvSeries.volumes;

// Convert to K-line series (without volume)
final klines = ohlcvSeries.toKlineSeries();

// Calculate indicators on OHLCV
final ema = ohlcvSeries.closes.ema(12);
```

### API Reference

#### `Kline`

Core candlestick data structure with OHLC values.

**Properties:**

- `open: Decimal` - Opening price
- `high: Decimal` - Highest price
- `low: Decimal` - Lowest price
- `close: Decimal` - Closing price

**Constructors:**

- `Kline({required Decimal open, high, low, close})`
- `Kline.fromDouble({required double open, high, low, close, int scale = 4})`
- `Kline.fromOhlcv(Ohlcv ohlcv)`

**Methods:**

- `bool check()` - Validates K-line data consistency
- `Decimal price(PriceType type)` - Gets price by type
- `Ohlcv toOhlcv({required Decimal volume})` - Converts to OHLCV

#### `KlineSeries` (List<Kline>)

Extension methods for K-line series operations.

**Properties:**

- `closes: DecList` - All closing prices
- `highs: DecList` - All high prices
- `lows: DecList` - All low prices
- `opens: DecList` - All opening prices

**Methods:**

- `ema({required int period, PriceType priceType})` - Calculate EMA
- `macd({int fastPeriod, slowPeriod, signalPeriod, PriceType priceType})` - Calculate MACD
- `merge({required int count, MergeAlignment alignment, MergeMode mode})` - Merge K-lines
- `predictNext({int scale})` - Predict next K-line using linear regression
- `prices(PriceType type)` - Extract prices by type
- `toOhlcvSeries({required DecList volume})` - Convert to OHLCV series

#### `Ohlcv`

OHLC data with volume.

**Properties:**

- `open: Decimal` - Opening price
- `high: Decimal` - Highest price
- `low: Decimal` - Lowest price
- `close: Decimal` - Closing price
- `volume: Decimal` - Trading volume

**Methods:**

- `Decimal price(OhlcvType type)` - Gets price or volume by type
- `Kline toKline()` - Converts to K-line (drops volume)

#### `Macd`

MACD indicator result.

**Properties:**

- `macdLine: double` - MACD line (fast EMA - slow EMA)
- `signalLine: double` - Signal line (EMA of MACD line)
- `histogram: double` - MACD histogram (MACD line - signal line)
- `isBullish: bool` - True if MACD line > signal line (buy signal)
- `isBearish: bool` - True if MACD line < signal line (sell signal)

#### `DecList` (List<Decimal>)

Extension methods for decimal list operations.

**Methods:**

- `ema(int period)` - Calculate Exponential Moving Average
- `sma(int period)` - Calculate Simple Moving Average
- `macd({int fastPeriod, slowPeriod, signalPeriod})` - Calculate MACD
- `linearFit()` - Perform linear regression, returns `LinearFitResult`

#### `LinearFitResult`

Result of linear regression analysis.

**Properties:**

- `slope: double` - Line slope
- `intercept: double` - Y-intercept
- `rSquared: double` - Coefficient of determination (0-1, closer to 1 is better fit)

**Methods:**

- `predict(double x)` - Predict Y value for given X

### Key Concepts

#### Price Types

```dart
enum PriceType {
  open,   // Opening price
  high,   // Highest price
  low,    // Lowest price
  close,  // Closing price
}
```

#### Merge Alignment

```dart
enum MergeAlignment {
  left,   // Left-aligned (starts from oldest data)
  right,  // Right-aligned (starts from newest data)
}
```

**Example:**

- Data: `[1, 2, 3, 4, 5, 6, 7]`, merge count: 3
- Left alignment: `[[1,2,3], [4,5,6]]` (drops 7)
- Right alignment: `[[2,3,4], [5,6,7]]` (drops 1)

#### Merge Mode

```dart
enum MergeMode {
  strict,   // Drops incomplete chunks
  partial,  // Includes incomplete chunks
}
```

**Example:**

- Data: `[1, 2, 3, 4, 5]`, merge count: 3, left-aligned
- Strict mode: `[[1,2,3]]` (drops 4,5)
- Partial mode: `[[1,2,3], [4,5]]` (includes incomplete chunk)

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Links

- [GitHub Repository](https://github.com/normidar/finance_kline_core)
- [Pub Package](https://pub.dartlang.org/packages/finance_kline_core)
- [Issue Tracker](https://github.com/normidar/finance_kline_core/issues)
