class PipeWrapper<T> {
  PipeWrapper({required this.body, required int index, required List<T> list})
    : _list = list,
      _index = index;

  final T body;

  final int _index;

  final List<T> _list;

  PipeWrapper<T>? get next {
    if (_index + 1 >= _list.length) {
      return null;
    }
    return PipeWrapper(body: _list[_index + 1], index: _index + 1, list: _list);
  }

  PipeWrapper<T>? get prev {
    if (_index - 1 < 0) {
      return null;
    }
    return PipeWrapper(body: _list[_index - 1], index: _index - 1, list: _list);
  }
}

extension PipeList<T> on List<T> {
  /// null除外
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
