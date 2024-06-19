import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_selectable/value_selectable.dart';

void main() {
  test('ValueSelectable', () async {
    final counterState = ValueNotifier<int>(0);

    final selectorState = ValueSelector<int>(
      (get) => get(counterState) + 1,
      (String action) {
        if (action == 'INCREMENT') counterState.value++;
        if (action == 'DECREMENT') counterState.value--;
      },
    );

    selectorState.addListener(expectAsync0(() {
      expect(selectorState.value, anyOf([2, 3]));
    }, count: 3));

    // directly change
    counterState.value = 1;

    // indirectly change
    selectorState.value = 'INCREMENT';
    selectorState.value = 'DECREMENT';

    await Future.delayed(const Duration(seconds: 1));
    selectorState.dispose();
  });

  test('ValueSelectable throw assert if reducer has more one arguments', () async {
    expect(() {
      return ValueSelector<int>(
        (get) => 1,
        (String action, int id) {},
      );
    }, throwsAssertionError);
  });

  test('ValueSelectable action zero arguments', () async {
    ValueSelector<int>(
      (get) => 1,
      () {},
    );
  });

  test('ValueSelectable action one arguments', () async {
    ValueSelector<int>(
      (get) => 1,
      (String action) {},
    );
  });
}
