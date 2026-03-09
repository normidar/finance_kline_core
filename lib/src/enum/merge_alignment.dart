enum MergeAlignment {
  left, // 左寄せ（古いデータから）
  right, // 右寄せ（新しいデータから）
}

enum MergeMode {
  strict, // 余りを捨てる（完全なチャンクのみ）
  partial, // 余りもそのままマージ
}
