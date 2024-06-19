part of '../value_selectable.dart';

/// A selector that computes a synchronous value based on a given scope.
class ValueSelector<T> extends ValueSelectable<T> {
  final T Function(GetValue get) scope;
  final Function? _set;
  late final bool kActionWithArguments;
  late T _value;

  @override
  T get value => _value;

  set value(dynamic newValue) {
    if (_set != null) {
      Function.apply(_set!, kActionWithArguments ? [newValue] : []);
    }
  }

  late final _get = GetValue._(notifyListeners);

  /// Constructs a ValueSelector with an initial value and a scope function.
  ValueSelector(this.scope, [this._set]) {
    if (_set != null) {
      var funcText = _set.runtimeType.toString();
      assert(!funcText.contains(','), 'Function must have one argument.');
      kActionWithArguments = !funcText.startsWith('() =>');
    }

    _value = scope(_get);
    _get._tracking = false;
  }

  @override
  void notifyListeners() {
    _value = scope(_get);
    super.notifyListeners();
  }

  @override
  void dispose() {
    _get.dispose();
    super.dispose();
  }
}
