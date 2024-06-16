library value_selectable;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

part 'src/async_value_selector.dart';
part 'src/value_selector.dart';

/// Abstract class for a selectable value, extending ChangeNotifier.
abstract class ValueSelectable<T> extends ChangeNotifier
    implements ValueListenable<T> {}

typedef SetValue<T> = void Function(T value);

/// Helper class to manage value dependencies and tracking for selectors.
final class GetValue {
  final void Function() _selectorNotifyListeners;
  final List<void Function()> _disposers = [];
  var _tracking = true;
  bool _isDisposed = false;

  GetValue._(this._selectorNotifyListeners);

  /// Registers a notifier and returns its value.
  R call<R>(ValueListenable<R> notifier) {
    if (_tracking) {
      notifier.addListener(_selectorNotifyListeners);
      _disposers.add(() => notifier.removeListener(_selectorNotifyListeners));
    }
    return notifier.value;
  }

  /// Disposes of all registered listeners.
  void dispose() {
    _isDisposed = true;
    for (final disposer in _disposers) {
      disposer();
    }
  }
}
