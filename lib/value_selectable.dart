library value_selectable;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Abstract class for a selectable value, extending ChangeNotifier.
abstract class ValueSelectable<T> extends ChangeNotifier
    implements ValueListenable<T> {}

/// A selector that computes a synchronous value based on a given scope.
class ValueSelector<T> extends ValueSelectable<T> {
  final T Function(ValueRegistrator get) scope;
  late T _value;

  @override
  T get value => _value;

  late final _get = ValueRegistrator._(notifyListeners);

  /// Constructs a ValueSelector with an initial value and a scope function.
  ValueSelector(this.scope) {
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

/// A selector that computes an asynchronous value based on a given scope.
class AsyncValueSelector<T> extends ValueSelectable<T> {
  final FutureOr<T> Function(ValueRegistrator get) scope;
  final Queue<FutureOr Function()> _requestQueue = Queue();
  bool _isProcessing = false;

  late final _get = ValueRegistrator._(notifyListeners);
  final _readyCompleter = Completer<bool>();

  /// Future that completes when the selector is ready.
  Future<bool> get isReady => _readyCompleter.future;

  late T _value;

  @override
  T get value => _value;

  /// Constructs an AsyncValueSelector with an initial value and a scope function.
  AsyncValueSelector(this._value, this.scope) {
    _requestQueue.add(_initializeSelector);
    _processQueue();
  }

  /// Processes the request queue, ensuring only one request is processed at a time.
  Future<void> _processQueue() async {
    if (_isProcessing || _requestQueue.isEmpty) return;

    _isProcessing = true;
    try {
      while (_requestQueue.isNotEmpty) {
        final request = _requestQueue.removeFirst();
        await request();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void notifyListeners() {
    _requestQueue.add(() async {
      _value = await scope(_get);
      super.notifyListeners();
    });
    _processQueue();
  }

  /// Initializes the selector by computing the initial value.
  Future<void> _initializeSelector() async {
    try {
      _value = await scope(_get);
      notifyListeners();
      _get._tracking = false;
      _readyCompleter.complete(true);
    } catch (e) {
      _readyCompleter.completeError(e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _get.dispose();
    super.dispose();
  }
}

/// Helper class to manage value dependencies and tracking for selectors.
final class ValueRegistrator {
  final void Function() _selectorNotifyListeners;
  final List<void Function()> _disposers = [];
  var _tracking = true;

  ValueRegistrator._(this._selectorNotifyListeners);

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
    for (final disposer in _disposers) {
      disposer();
    }
  }
}
