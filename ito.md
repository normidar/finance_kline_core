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
- `analyze<T>()` はバーごとに関数を呼び出して結果リストを返す

### 6. シグナルアーキテクチャ

```
SignalLogic (abstract)      ← 戦略の「計算ロジック」
  ├── EmaLogic              → EmaSeries
  ├── RsiLogic              → RsiSeries
  └── MacdLogic             → MacdSeries

SignalParams (abstract)     ← 戦略の「パラメータ」
  ├── EmaParams (periods: Set<int>)
  ├── RsiParams (period, overbought, oversold)
  └── MacdParams (fastPeriod, slowPeriod, signalPeriod)

SignalSeries (abstract)     ← 戦略の「出力系列」
  ├── EmaSeries             (Map<period, List<double?>> + isBullishCross / isBearishCross)
  ├── RsiSeries             + stateOf() + RsiState enum
  ├── MacdSeries            + isBullishCross / isBearishCross
  └── LinearSignalSeries<T> (タイムスタンプ付き汎用系列、未活用)
```

---

## 実装状況

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
| Series MACDキャッシュバグ修正 | 完成 |
| Series RSIキャッシュバグ修正 | 完成 |
| Series EMAキャッシュのpriceType対応 | 完成 |
| K線マージ（OhlcvSeries.merge） | 完成 |
| FKCEngine.analyze() | 完成 |
| OhlcvSeriesWrapper.analyze() | 完成 |
| MTF analyze内でのjumpToスライス対応 | 完成 |
| EmaLogic / EmaSeries | 完成 |
| RsiLogic / RsiParams / RsiSeries | 完成 |
| MacdLogic / MacdParams / MacdSeries | 完成 |
| EmaSeries クロス検出（isBullishCross / isBearishCross） | 完成 |
| テスト（80テスト・全パス） | 完成 |
| README.md 現行API対応 | 完成 |
| FKCEngine マージ連携 | 未実装（設計判断待ち） |
| LinearSignalSeries の活用 | 未実装（削除候補） |

---

## 残っている課題

### 設計判断: FKCEngine へのマージ連携

`addOhlcvSeries` 時に、`baseInterval` から上位時間足を自動マージ生成するかを決めていない。
現在は各時間足のデータを手動で別々に登録する方式のみ。

選択肢:
1. 手動登録のみ（現状維持）→ シンプルだが利便性が低い
2. `addOhlcvSeries` 時に上位時間足を自動生成 → 利便性は高いが `Interval` の倍数整合性チェックが必要

---

### 設計判断: LinearSignalSeries の活用か削除か

`LinearSignalSeries<T extends SignalUnit>` はタイムスタンプ付きの汎用シリーズとして設計されているが、
`EmaSeries` / `RsiSeries` / `MacdSeries` はいずれもインデックスベースで実装されており、
`LinearSignalSeries` を使っていない。

将来的にシグナル結果に時刻情報を付与したい場合に活用するか、
あるいは不要と判断して削除するかを決める必要がある。

---

## TODO — 残りのロードマップ

### v1.0.0 公開に向けて完了済み ✅

- [x] Series._emaキャッシュキーに `priceType` を追加（バグ修正）
- [x] `OhlcvSeriesWrapper.analyze()` の追加（`engine.select(interval).analyze(...)` 記法）
- [x] MTF analyze 内での `jumpTo` 時刻スライス対応（ルックアヘッドバイアス防止）
- [x] `EmaSeries` にクロス検出追加（`isBullishCross` / `isBearishCross`）
- [x] テスト追加（80テスト・全パス）
  - `test/dec_list_test.dart` — EMA/SMA/MACD/RSI/linearFit/correlation
  - `test/ohlcv_series_test.dart` — merge全4通り・subUpToTimestamp・キャッシュ
  - `test/signal_logic_test.dart` — SignalLogic群・FKCEngine・MTF
- [x] README.md を現行APIに合わせて完全書き直し

---

### 設計判断が必要なもの

- [ ] **FKCEngine マージ連携の方針を決める**
  - 手動登録のみ継続か、上位時間足の自動生成を追加するか

- [ ] **`LinearSignalSeries` の活用か削除かを決める**
  - タイムスタンプ付きシグナルが必要になったら活用
  - 不要なら除去してコードをシンプルに保つ

---

### 将来の発展（中長期）

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

### 優先順序まとめ

```
✅ Series._emaキャッシュキー修正
✅ OhlcvSeriesWrapper.analyze() 追加
✅ EmaSeriesにクロス検出追加
✅ MTF jumpTo 時刻スライス対応
✅ テスト追加（80テスト・全パス）
✅ README更新
  ↓
【次のステップ】FKCEngine自動マージ / LinearSignalSeries設計判断
  ↓
v1.0.0 pub.dev公開
  ↓
戦略合成 / バックテスト / ストリーミング（将来）
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
