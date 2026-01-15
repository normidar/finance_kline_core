# finance_kline_core

[![GitHub](https://img.shields.io/github/license/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/finance_kline_core.svg)](https://pub.dartlang.org/packages/finance_kline_core)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/finance_kline_core.svg)](https://github.com/normidar/finance_kline_core/stargazers)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/normidar2.svg?style=social&label=Follow%20%40normidar2)](https://twitter.com/normidar2)
[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/normidar)

金融のローソク足（K-line）データ分析のための包括的な Dart パッケージ。テクニカル指標、統計分析、高精度な小数計算を提供します。

📖 **[English Documentation](README.md)**

---

## 機能

- **テクニカル指標**

  - EMA（指数移動平均）- 高速反応型のトレンド追従
  - SMA（単純移動平均）- 古典的なトレンド分析
  - MACD（移動平均収束拡散法）- モメンタムとトレンドの強さ

- **統計分析**

  - R²（決定係数）を用いた線形回帰
  - 線形フィッティングによる価格予測
  - 信頼性指標付きのトレンド分析

- **ローソク足操作**

  - 配置オプション（左寄せ/右寄せ）を使った柔軟なローソク足マージ
  - 複数のマージモード（strict/partial）
  - Kline と OHLCV 形式間の変換

- **高精度計算**

  - 正確な金融計算のための`Decimal`型の使用
  - 浮動小数点精度エラーの回避
  - 設定可能な小数点桁数

## インストール

`pubspec.yaml`ファイルに以下を追加してください：

```yaml
dependencies:
  finance_kline_core: ^0.0.1
```

その後、以下を実行：

```bash
dart pub get
```

## 使用例

### ローソク足の作成

```dart
import 'package:finance_kline_core/finance_kline_core.dart';

// double値から作成
final kline = Kline.fromDouble(
  open: 100.0,
  high: 105.0,
  low: 99.0,
  close: 103.0,
  scale: 4,  // 小数点精度
);

// Decimal値から作成
final klineDecimal = Kline(
  open: Decimal.parse('100.0000'),
  high: Decimal.parse('105.0000'),
  low: Decimal.parse('99.0000'),
  close: Decimal.parse('103.0000'),
);

// 出来高付きのOHLCVを作成
final ohlcv = Ohlcv(
  open: Decimal.parse('100.0'),
  high: Decimal.parse('105.0'),
  low: Decimal.parse('99.0'),
  close: Decimal.parse('103.0'),
  volume: Decimal.parse('1000000.0'),
);
```

### テクニカル指標の計算

```dart
// ローソク足のシリーズを作成
final klineSeries = <Kline>[
  Kline.fromDouble(open: 100, high: 105, low: 99, close: 103),
  Kline.fromDouble(open: 103, high: 108, low: 102, close: 106),
  Kline.fromDouble(open: 106, high: 110, low: 105, close: 108),
  // ... さらにローソク足を追加
];

// EMA（指数移動平均）を計算
final ema12 = klineSeries.ema(period: 12);
final ema26 = klineSeries.ema(period: 26);

// 異なる価格タイプで計算
final emaHigh = klineSeries.ema(
  period: 12,
  priceType: PriceType.high,
);

// SMA（単純移動平均）を計算
final closes = klineSeries.closes;
final sma20 = closes.sma(20);

// MACDを計算
final macd = klineSeries.macd(
  fastPeriod: 12,
  slowPeriod: 26,
  signalPeriod: 9,
);

// MACDシグナルをチェック
for (final m in macd) {
  if (m != null) {
    if (m.isBullish) {
      print('買いシグナル: MACDラインがシグナルラインより上');
    } else if (m.isBearish) {
      print('売りシグナル: MACDラインがシグナルラインより下');
    }
  }
}
```

### 線形回帰と予測

```dart
// 終値を取得
final closes = klineSeries.closes;

// 線形回帰を実行
final fit = closes.linearFit();
print('傾き: ${fit.slope}');
print('切片: ${fit.intercept}');
print('R²: ${fit.rSquared}');  // 1.0に近いほど良好なフィット

// 将来の値を予測
final nextValue = fit.predict(closes.length.toDouble() + 1);
print('予測される次の終値: $nextValue');

// 次のローソク足を予測
final nextKline = klineSeries.predictNext(scale: 4);
print('予測される次のローソク足:');
print('  始値: ${nextKline.open}');
print('  高値: ${nextKline.high}');
print('  安値: ${nextKline.low}');
print('  終値: ${nextKline.close}');
```

### ローソク足のマージ

```dart
// 異なる戦略でローソク足をマージ

// 左寄せマージ（古いデータから）
// 末尾の不完全なチャンクを削除
final mergedLeft = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.left,
  mode: MergeMode.strict,
);

// 右寄せマージ（新しいデータから）
// 先頭の不完全なチャンクを削除
final mergedRight = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.right,
  mode: MergeMode.strict,
);

// partialモード: 不完全なチャンクも含める
final mergedPartial = klineSeries.merge(
  count: 4,
  alignment: MergeAlignment.left,
  mode: MergeMode.partial,
);

// マージされたローソク足の組み合わせ:
// - 始値: 最初のローソク足の始値
// - 高値: すべての高値の最高値
// - 安値: すべての安値の最安値
// - 終値: 最後のローソク足の終値
```

### OHLCV データの操作

```dart
final ohlcvSeries = <Ohlcv>[
  Ohlcv(
    open: Decimal.parse('100'),
    high: Decimal.parse('105'),
    low: Decimal.parse('99'),
    close: Decimal.parse('103'),
    volume: Decimal.parse('1000000'),
  ),
  // ... さらにOHLCVデータを追加
];

// 特定の価格シリーズを抽出
final closes = ohlcvSeries.closes;
final highs = ohlcvSeries.highs;
final volumes = ohlcvSeries.volumes;

// ローソク足シリーズに変換（出来高なし）
final klines = ohlcvSeries.toKlineSeries();

// OHLCVで指標を計算
final ema = ohlcvSeries.closes.ema(12);
```

## API リファレンス

### `Kline`

OHLC 値を持つコアのローソク足データ構造。

**プロパティ:**

- `open: Decimal` - 始値
- `high: Decimal` - 高値
- `low: Decimal` - 安値
- `close: Decimal` - 終値

**コンストラクタ:**

- `Kline({required Decimal open, high, low, close})`
- `Kline.fromDouble({required double open, high, low, close, int scale = 4})`
- `Kline.fromOhlcv(Ohlcv ohlcv)`

**メソッド:**

- `bool check()` - ローソク足データの一貫性を検証
- `Decimal price(PriceType type)` - タイプ別に価格を取得
- `Ohlcv toOhlcv({required Decimal volume})` - OHLCV に変換

### `KlineSeries` (List<Kline>)

ローソク足シリーズ操作のための拡張メソッド。

**プロパティ:**

- `closes: DecList` - すべての終値
- `highs: DecList` - すべての高値
- `lows: DecList` - すべての安値
- `opens: DecList` - すべての始値

**メソッド:**

- `ema({required int period, PriceType priceType})` - EMA を計算
- `macd({int fastPeriod, slowPeriod, signalPeriod, PriceType priceType})` - MACD を計算
- `merge({required int count, MergeAlignment alignment, MergeMode mode})` - ローソク足をマージ
- `predictNext({int scale})` - 線形回帰を使用して次のローソク足を予測
- `prices(PriceType type)` - タイプ別に価格を抽出
- `toOhlcvSeries({required DecList volume})` - OHLCV シリーズに変換

### `Ohlcv`

出来高付きの OHLC データ。

**プロパティ:**

- `open: Decimal` - 始値
- `high: Decimal` - 高値
- `low: Decimal` - 安値
- `close: Decimal` - 終値
- `volume: Decimal` - 出来高

**メソッド:**

- `Decimal price(OhlcvType type)` - タイプ別に価格または出来高を取得
- `Kline toKline()` - ローソク足に変換（出来高を削除）

### `Macd`

MACD 指標の結果。

**プロパティ:**

- `macdLine: double` - MACD ライン（短期 EMA - 長期 EMA）
- `signalLine: double` - シグナルライン（MACD ラインの EMA）
- `histogram: double` - MACD ヒストグラム（MACD ライン - シグナルライン）
- `isBullish: bool` - MACD ライン > シグナルラインの場合 true（買いシグナル）
- `isBearish: bool` - MACD ライン < シグナルラインの場合 true（売りシグナル）

### `DecList` (List<Decimal>)

Decimal リスト操作のための拡張メソッド。

**メソッド:**

- `ema(int period)` - 指数移動平均を計算
- `sma(int period)` - 単純移動平均を計算
- `macd({int fastPeriod, slowPeriod, signalPeriod})` - MACD を計算
- `linearFit()` - 線形回帰を実行、`LinearFitResult`を返す

### `LinearFitResult`

線形回帰分析の結果。

**プロパティ:**

- `slope: double` - 直線の傾き
- `intercept: double` - Y 切片
- `rSquared: double` - 決定係数（0-1、1 に近いほど良好なフィット）

**メソッド:**

- `predict(double x)` - 与えられた X に対する Y 値を予測

## 主要な概念

### 価格タイプ

```dart
enum PriceType {
  open,   // 始値
  high,   // 高値
  low,    // 安値
  close,  // 終値
}
```

### マージの配置

```dart
enum MergeAlignment {
  left,   // 左寄せ（古いデータから開始）
  right,  // 右寄せ（新しいデータから開始）
}
```

**例:**

- データ: `[1, 2, 3, 4, 5, 6, 7]`、マージ数: 3
- 左寄せ: `[[1,2,3], [4,5,6]]` (7 を削除)
- 右寄せ: `[[2,3,4], [5,6,7]]` (1 を削除)

### マージモード

```dart
enum MergeMode {
  strict,   // 不完全なチャンクを削除
  partial,  // 不完全なチャンクも含める
}
```

**例:**

- データ: `[1, 2, 3, 4, 5]`、マージ数: 3、左寄せ
- strict モード: `[[1,2,3]]` (4,5 を削除)
- partial モード: `[[1,2,3], [4,5]]` (不完全なチャンクも含む)

## ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## 貢献

貢献を歓迎します！プルリクエストを自由に提出してください。

## リンク

- [GitHub リポジトリ](https://github.com/normidar/finance_kline_core)
- [Pub パッケージ](https://pub.dartlang.org/packages/finance_kline_core)
- [Issue トラッカー](https://github.com/normidar/finance_kline_core/issues)
