import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_selectable/value_selectable.dart';

void main() {
  group('AsyncValueSelector', () {
    test('should compute initial value correctly', () async {
      final valueNotifier = ValueNotifier<int>(1);
      final selector = AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

      await selector.isReady;
      expect(selector.value, 2);
    });

    test('should update value when dependent notifiers change', () async {
      final valueNotifier = ValueNotifier<int>(1);
      final selector = AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

      await selector.isReady;
      valueNotifier.value = 2;
      await Future.delayed(Duration.zero); // Allow notifyListeners to be processed
      expect(selector.value, 3);
    });

    test('should notify listeners on value change', () async {
      final valueNotifier = ValueNotifier<int>(1);
      final selector = AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

      await selector.isReady;

      int listenerCallCount = 0;
      selector.addListener(() {
        listenerCallCount++;
      });

      valueNotifier.value = 2;
      await Future.delayed(Duration.zero); // Allow notifyListeners to be processed
      expect(listenerCallCount, 1);
      expect(selector.value, 3);
    });

    test('should dispose correctly', () async {
      final valueNotifier = ValueNotifier<int>(1);
      final selector = AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

      await selector.isReady;
      selector.dispose();
      // Ensure no exceptions are thrown on dispose
    });
  });
}
