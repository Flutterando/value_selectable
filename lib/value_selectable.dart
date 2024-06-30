library value_selectable;

import 'package:flutter/foundation.dart';

export 'src/value_selector.dart';

/// Abstract class for a selectable value, extending ChangeNotifier.
abstract class ValueSelectable<T> extends ChangeNotifier
    implements ValueListenable<T> {}

typedef SetValue<T> = void Function(T value);

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
