class PipeWrapper<T> {
  PipeWrapper({required this.body, required int index, required List<T> list})
    : _list = list,
      _index = index;

  final T body;

  final int _index;

  final List<T> _list;

  /// 次の要素
  PipeWrapper<T>? get next {
    return this[1];
  }

  /// 前の要素
  PipeWrapper<T>? get prev {
    return this[-1];
  }

  /// 相対的要素を取得する
  PipeWrapper<T>? operator [](int index) {
    final ind = _index + index;
    if (ind < 0 || ind >= _list.length) {
      return null;
    }
    return PipeWrapper(body: _list[ind], index: ind, list: _list);
  }

  /// 相対的なインデックスで要素のリスト（null除外）を取得する
  List<T> cleanCombo(int start, int end) {
    final result = <T>[];
    for (var i = start; i <= end; i++) {
      final item = this[i];
      if (item != null) {
        result.add(item.body);
      }
    }
    return result;
  }

  /// 相対的なインデックスで要素のリスト（null可能）を取得する
  List<T?> combo(int start, int end) {
    final result = <T?>[];
    for (var i = start; i <= end; i++) {
      final item = this[i];
      result.add(item?.body);
    }
    return result;
  }
}

extension PipeList<T> on List<T> {
  /// null除外のpipe
  List<A> cleanPipe<A>(A Function(PipeWrapper<T>) func) {
    final result = <A>[];
    for (var i = 0; i < length; i++) {
      final res = func(PipeWrapper(body: this[i], index: i, list: this));
      if (res != null) {
        result.add(res);
      }
    }
    return result;
  }

  List<A> pipe<A>(A Function(PipeWrapper<T>) func) {
    final result = <A>[];
    for (var i = 0; i < length; i++) {
      result.add(func(PipeWrapper(body: this[i], index: i, list: this)));
    }
    return result;
  }
}
