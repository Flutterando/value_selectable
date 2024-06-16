part of '../value_selectable.dart';

/// A selector that computes an asynchronous value based on a given scope.
class AsyncValueSelector<T> extends ValueSelectable<T> {
  final FutureOr<T> Function(GetValue get) scope;
  final FutureOr<void> Function(dynamic action)? _set;

  final Queue<FutureOr Function()> _requestQueue = Queue();
  bool _isProcessing = false;
  bool _isInitialized = false;

  late final _get = GetValue._(notifyListeners);
  final _readyCompleter = Completer<bool>();

  /// Future that completes when the selector is ready.
  Future<bool> get isReady {
    _initialize();
    return _readyCompleter.future;
  }

  late T _value;

  void _initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      _requestQueue.add(_initializeSelector);
      _processQueue();
    }
  }

  @override
  T get value {
    _initialize();
    return _value;
  }

  set value(dynamic newValue) {
    _initialize();
    _requestQueue.add(() => _set?.call(newValue));
    _processQueue();
  }

  /// Constructs an AsyncValueSelector with an initial value and a scope function.
  AsyncValueSelector(this._value, this.scope, [this._set]);

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
      if (_get._isDisposed) return;
      super.notifyListeners();
    });
    _processQueue();
  }

  /// Initializes the selector by computing the initial value.
  Future<void> _initializeSelector() async {
    _value = await scope(_get);
    super.notifyListeners();
    _get._tracking = false;
    _readyCompleter.complete(true);
  }

  @override
  void dispose() {
    _get.dispose();
    super.dispose();
  }
}
