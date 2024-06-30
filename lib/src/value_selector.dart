import 'package:flutter/foundation.dart';

/// A selector that computes a synchronous value based on a given scope.
class ValueSelector<T> extends ChangeNotifier implements ValueListenable<T> {
  final T Function(GetValue get) scope;
  late T _value;
  final _listenables = <Listenable>{};

  @override
  T get value => _value;

  late final _get = GetValue._(onListenableIdentified);

  void onListenableIdentified(Listenable listenable) {
    if (_listenables.add(listenable)) {
      listenable.addListener(notifyListeners);
    }
  }

  /// Constructs a ValueSelector with an initial value and a scope function.
  ValueSelector(this.scope) {
    _value = scope(_get);
  }

  @override
  void notifyListeners() {
    _listenables.clear();
    final newValue = scope(_get);

    if (newValue == _value) return;
    _value = newValue;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _get.dispose();
    for (var listenable in _listenables) {
      listenable.removeListener(notifyListeners);
    }
    super.dispose();
  }
}

/// Helper class to manage value dependencies and tracking for selectors.
final class GetValue {
  final void Function(Listenable listenable) _selectorIdentifyListenable;
  GetValue._(this._selectorIdentifyListenable);

  bool _isDisposed = false;

  /// Registers a notifier and returns its value.
  R call<R>(ValueListenable<R> notifier) {
    if (_isDisposed) throw Exception('It is disposed');
    _selectorIdentifyListenable.call(notifier);
    return notifier.value;
  }

  /// Disposes of all registered listeners.
  void dispose() {
    _isDisposed = true;
  }
}
