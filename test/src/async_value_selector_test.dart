import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_selectable/value_selectable.dart';

void main() {
  test('should compute initial value correctly', () async {
    final valueNotifier = ValueNotifier<int>(1);
    final selector = AsyncValueSelector<int>(
      0,
      (get) async => get(valueNotifier) + 1,
      (action) => valueNotifier.value = action as int,
    );

    selector.addListener(expectAsync0(() {
      expect(selector.value, anyOf([2, 4]));
    }, count: 2));

    selector.value = 3;
  });

  test('should update value when dependent notifiers change', () async {
    final valueNotifier = ValueNotifier<int>(1);
    final selector =
        AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

    await selector.isReady;
    valueNotifier.value = 2;
    await Future.delayed(
        Duration.zero); // Allow notifyListeners to be processed
    expect(selector.value, 3);
  });

  test('should notify listeners on value change', () async {
    final valueNotifier = ValueNotifier<int>(1);
    final selector =
        AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

    int listenerCallCount = 0;
    selector.addListener(() {
      listenerCallCount++;
    });

    await selector.isReady;

    valueNotifier.value = 2;
    await Future.delayed(
        Duration.zero); // Allow notifyListeners to be processed
    expect(listenerCallCount, 2);
    expect(selector.value, 3);
  });

  test('should dispose correctly', () async {
    final valueNotifier = ValueNotifier<int>(1);
    final selector =
        AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

    await selector.isReady;

    selector.dispose();

    valueNotifier.value = 2;
    // Ensure no exceptions are thrown on dispose
  });
}
