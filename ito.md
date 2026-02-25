# finance_kline_core — 意図と設計方針

## プロジェクトの核心的な意図

> 「トレード戦略を、1つの関数で表現できるようにする」

これが本パッケージの最終目標である。
金融のローソク足（K線）データに対して、テクニカル指標の計算・時間足変換・シグナル判定を統一的なAPIで扱えるDartライブラリを構築することを目指す。

---

## ドメイン

金融チャート（仮想通貨・株式等）のOHLCVデータを扱う純粋なDartパッケージ。
FlutterアプリやDartサーバーから利用される。

---

## 設計の意図

### 1. データモデルの二層構造

| 層 | クラス | 用途 |
|---|---|---|
| 生データ | `Ohlcv` (@freezed) | 外部APIから受け取る不変なOHLCVデータ |
| 分析モデル | `Kline` (extends SignalUnit) | シグナル計算の文脈で使う時刻付きローソク足 |

- `Ohlcv` はJSONシリアライズ可能な「値オブジェクト」
- `Kline` は `SignalUnit` を継承することで、シグナルアーキテクチャに組み込める設計

### 2. 指標計算の責務分離

```
List<double> (DecList)
    └── DecListX (extension)
            ├── ema()
            ├── sma()
            ├── macd()
            ├── rsi()
            ├── linearFit()
            └── correlation()
```

- すべての指標計算は `List<double>` に対するextension methodとして実装
- データ型に依存せず、純粋な数値列に対して動作する
- `OhlcvSeries` → `closes` / `highs` / `lows` → `DecList` → 指標計算、という変換パイプラインを想定

### 3. Seriesによるキャッシュと統一アクセス

```
Series (abstract)
  └── OhlcvSeries
```

- `Series` が指標結果をメモ化し、同じパラメータでの再計算を防ぐ
- `ema(period:, priceType:)` のように、価格種別（OHLC）を指定して指標を取得できる

### 4. パイプライン処理の抽象化

```
List<T>
  └── PipeList (extension)
        ├── pipe()         // 全要素にPipeWrapperで変換
        └── cleanPipe()    // null除去版
```

- `PipeWrapper` により「現在の要素・前後の要素・任意オフセットの要素」を文脈付きで参照できる
- ローソク足の「前のバー・次のバー」を自然に扱えるようにする

### 5. 多時間足エンジン（FKCEngine）

```
FKCEngine
  ├── baseInterval: Interval
  ├── Map<Interval, OhlcvSeries>
  └── OhlcvSeriesWrapper (jumpTo でタイムフレーム切り替え)
```

- 複数の時間足（1分・5分・1時間等）のデータを一元管理
- `select(interval)` で任意の時間足のシリーズを取得
- `analyze<T>()` は戦略計算のエントリーポイントとして設計（現在実装中）

### 6. シグナルアーキテクチャ（拡張中）

```
SignalLogic (abstract)   ← 戦略の「計算ロジック」
  └── (未実装)

SignalParams (abstract)  ← 戦略の「パラメータ」
  └── EmaParams

SignalSeries (abstract)  ← 戦略の「出力系列」
  └── LinearSignalSeries<T extends SignalUnit>
```

- 将来的に「EMAクロス」「RSIオーバーソールド」などの戦略を `SignalLogic` として実装し、組み合わせて使う設計
- `SignalUnit` を基底とすることで、あらゆる時刻付きデータをシグナル系列として扱える

---

## 実装済みの機能

| 機能 | 状態 |
|---|---|
| EMA計算 | 完成 |
| SMA計算 | 完成 |
| MACD計算 | 完成 |
| RSI計算 | 完成 |
| 線形回帰（R²付き） | 完成 |
| ピアソン相関係数 | 完成 |
| OhlcvSeries（時刻スライス付き） | 完成 |
| PipeList（文脈付き反復） | 完成 |
| FKCEngine（多時間足管理） | 部分実装 |
| K線マージ（時間足変換） | 削除済み・再実装待ち |
| SignalLogic具体実装 | 未実装 |
| テスト | 未実装 |

---

## 現在の課題と未来の方向性

### 解決すべき問題

1. **K線マージロジックの消失**: `KlineSeries` クラス削除時にマージ機能も失われた。`MergeAlignment` / `MergeMode` のenumは残っているが、実装がない。再設計が必要。

2. **FKCEngine.analyze() の未完成**: ループ本体が空。シグナル計算のオーケストレーション設計が必要。

3. **Series のキャッシュ設計の不完全さ**: MACD・RSIは単一インスタンスしかキャッシュされず、パラメータを変えて呼ぶと最初の結果が返る（バグ相当）。

4. **SignalLogic の未実装**: 戦略パターンの骨格だけあり、具体的な実装がない。

### 目指す姿

```dart
// こういう記述で戦略を表現できるようにする
final result = engine
  .select(Interval.$1h)
  .analyze(EmaCrossStrategy(fast: 12, slow: 26));
```

- 戦略を関数・クラスとして定義し、時間足・データ範囲を指定して実行
- 複数時間足にまたがるシグナル（MTF分析）をサポート
- バックテストへの応用も視野に入れる

---

## TODO — 目標達成までのロードマップ

目標「`engine.select(interval).analyze(MyStrategy())`」を実現するために、
何が足りないかを層ごとに整理する。

---

### P0: 今すぐ直すべきバグ

- [ ] **`Series` のキャッシュバグを修正する**
  - `_macd` と `_rsi` は単一インスタンスしかキャッシュしない設計
  - 異なるパラメータで呼ぶと最初の結果が返る（バグ）
  - EMAと同様に `Map<String, T>` でキャッシュキーをパラメータから生成する

---

### P1: データ基盤の復元（これがないと多時間足が機能しない）

- [ ] **K線マージ機能を `OhlcvSeries` に再実装する**
  - `KlineSeries` 削除時に機能が消えたが `MergeAlignment` / `MergeMode` のenumは残存
  - `OhlcvSeries.merge(int n, {MergeAlignment, MergeMode})` → `OhlcvSeries` として設計
  - ルール: `open=最初`, `high=最大`, `low=最小`, `close=最後`, `volume=合計`
  - `MergeAlignment.left` / `right` と `MergeMode.strict` / `partial` の4通りを実装

- [ ] **`FKCEngine` へのマージ連携を設計する**
  - `addOhlcvSeries` 時に `baseInterval` より大きい時間足は自動マージで生成するか、
    手動登録のみにするかを決める
  - `Interval.duration` を使った整合性チェック（例: 1分足から5分足を作れるか判定）

---

### P2: SignalLogic インターフェースの再設計（戦略が書けない根本問題）

現在の `SignalLogic.compute(List<double> data, SignalParams params)` は **単一の数値列** しか受け取れない。
MACDクロス・RSI+EMAの複合判定など、実用的な戦略は **`OhlcvSeries` 全体** を必要とする。

- [ ] **`SignalLogic` の入力を `OhlcvSeries` に変更する（または多入力対応にする）**
  ```dart
  // 現状（限定的）
  SignalSeries compute(List<double> data, SignalParams params);

  // 目標（戦略が自由にSeriesを参照できる）
  SignalSeries compute(OhlcvSeries series, SignalParams params);
  ```

- [ ] **`SignalLogic` の出力型を明確化する**
  - `LinearSignalSeries<T extends SignalUnit>` を返すのか
  - `List<bool?>` のような単純なシグナル列を返すのか
  - バーごとの「エントリー/エグジット/ホールド」を表す enum を返すのか
  - → 設計決定が必要

- [ ] **`EmaParams` に対応する具体的な `SignalLogic` を1つ実装する（動作実証）**
  - `EmaLogic implements SignalLogic` として最初の具体実装を作る
  - これにより `SignalLogic` の設計が正しいか検証できる

---

### P3: FKCEngine.analyze() の完成（戦略実行のオーケストレーション）

- [ ] **`analyze<T>()` の型パラメータの意味を確定させる**
  - `T` は `SignalSeries`? `SignalUnit`? 戻り値の型?
  - ループ本体が空のまま — 設計を決めて実装する

- [ ] **`OhlcvSeriesWrapper.analyze()` として委譲できるようにする**
  ```dart
  // 目標の記法
  final signals = engine
    .select(Interval.$1h)
    .analyze(EmaCrossLogic(EmaParams(periods: {12, 26})));
  ```
  - `OhlcvSeriesWrapper` が `SignalLogic` を受け取り、内部の `OhlcvSeries` を渡して実行

- [ ] **複数時間足にまたがる戦略のアクセスパターンを設計する**
  - `OhlcvSeriesWrapper.jumpTo(interval)` で別時間足に切り替えられるが、
    戦略の中でどう使うか（例: 日足トレンド確認 → 1時間足でエントリー）のAPIを決める

---

### P4: 戦略の具体実装（ライブラリとしての価値証明）

最低限の実用的な戦略を実装し、パッケージの使い勝手を検証する。

- [ ] **EMAクロス戦略** (`EmaCrossLogic`): fast EMA が slow EMA を上抜け/下抜けで売買シグナル
- [ ] **RSI戦略** (`RsiLogic`): 閾値超え/割れでオーバーソールド/オーバーボートシグナル
- [ ] **MACDシグナルクロス** (`MacdCrossLogic`): MACDラインがシグナルラインをクロス

これらを実装することで、戦略コンポーネントの設計が実用的かどうか検証できる。

---

### P5: テスト（publishできる品質にする）

現在テストが一切ない。指標計算の正確性はパッケージの信頼性の根幹。

- [ ] **指標計算のユニットテスト**
  - EMA: 既知の入力に対して既知の出力を検証（TradingViewの値と照合）
  - SMA: 同上
  - MACD: `macdLine`, `signalLine`, `histogram` の各値
  - RSI: Wilder's smoothing の精度検証
  - 線形回帰: `slope`, `intercept`, `rSquared` の数値検証

- [ ] **エッジケースのテスト**
  - 空のリスト、`period` より短いデータ、全て同じ値のデータ
  - `rsi` で `avgLoss == 0` のケース（RS = 100）

- [ ] **K線マージのテスト**
  - 4通りの `MergeAlignment` × `MergeMode` の組み合わせ
  - タイムスタンプの整合性（`openTimestamp` / `closeTimestamp`）

- [ ] **`OhlcvSeries` のキャッシュ正確性テスト**
  - 同じパラメータで2回呼んで同一インスタンスが返るか
  - 異なるパラメータで別の結果が返るか（キャッシュバグ修正後）

---

### P6: ドキュメントの整合性修正

- [ ] **README.md を現在の実装に合わせて更新する**
  - `merge` / `predictNext` / `toOhlcvSeries` などの削除済みAPIへの言及を削除
  - `OhlcvSeries` / `FKCEngine` / `PipeList` の実際の使い方を追記

- [ ] **README_ja.md のTODOを整理する**
  - 完了済みの `[ ]` を `[x]` に更新
  - 新しい設計方針を反映

---

### P7: 将来の発展（中長期）

- [ ] **戦略の合成演算子**
  ```dart
  final combined = EmaCrossLogic() & RsiLogic();  // AND合成
  final either   = EmaCrossLogic() | MacdLogic();  // OR合成
  ```

- [ ] **バックテスト機能**
  - 過去データに戦略を適用し、シグナル発生点と損益を計算
  - `BacktestResult` に勝率・最大ドローダウン・シャープレシオ等を含める

- [ ] **ストリーミング対応（リアルタイム更新）**
  - `OhlcvSeries` への `append(Ohlcv)` でインクリメンタルに指標を更新
  - キャッシュを部分的に無効化する仕組み

---

### 実装の優先順序まとめ

```
P0 キャッシュバグ修正
  ↓
P1 K線マージ復元
  ↓
P2 SignalLogicインターフェース再設計
  ↓
P3 FKCEngine.analyze() 完成
  ↓
P4 具体的な戦略を3つ実装（EMAクロス・RSI・MACD）
  ↓
P5 テスト追加
  ↓
P6 ドキュメント整合性修正
  ↓
v1.0.0 としてpub.devに公開
  ↓
P7 戦略合成・バックテスト・ストリーミング（将来）
```

---

## 技術スタック

| 項目 | 内容 |
|---|---|
| 言語 | Dart (SDK >=3.8.0) |
| 不変データ | freezed + json_serializable |
| コード生成 | build_runner + auto_exporter |
| Lint | very_good_analysis |
| CI | GitHub Actions |
| 配布 | pub.dev (finance_kline_core) |
