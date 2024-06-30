import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_selectable/value_selectable.dart';

void main() {
  test('ValueSelectable', () async {
    final counterState = ValueNotifier<int>(0);
    final selectorState = ValueSelector<int>((get) => get(counterState) + 1);

    selectorState.addListener(expectAsync0(() {
      expect(selectorState.value, anyOf([2, 3]));
    }, count: 2));

    // directly change
    counterState.value = 1;
    counterState.value = 2;

    // await Future.delayed(const Duration(seconds: 1));
    selectorState.dispose();
  });

  test('ValueSelectable action zero arguments', () async {
    ValueSelector<int>((get) => 1);
  });

  test('ValueSelectable action one arguments', () async {
    final counterState = ValueNotifier<int>(0);
    ValueSelector<int>((get) => get(counterState));
  });

  test('Listen other notifiers after the first value', () {
    final mockCallback = Param1Callback<bool>();

    final nameState = ValueNotifier('Deivão');
    final ageState = ValueNotifier(15);

    final canAccess = ValueSelector((get) {
      if (get(nameState) == 'Deivão') return true;
      if (get(ageState) >= 18) return true;
      return false;
    });

    canAccess.addListener(() => mockCallback.call(canAccess.value));

    // Return false
    nameState.value = "Jacob";

    // Return true (doesn't work)
    ageState.value = 18;

    expect(mockCallback, orderedEquals([false, true]));
  });

  test('Do not emit repeated values', () {
    final mockCallback = Param1Callback<bool>();

    final nameState = ValueNotifier('Jacob');
    final ageState = ValueNotifier(17);

    final canAccess = ValueSelector((get) {
      if (get(nameState) == 'Deivão') return true;
      if (get(ageState) >= 18) return true;
      return false;
    });

    canAccess.addListener(() => mockCallback.call(canAccess.value));

    nameState.value = "Deivão";
    ageState.value = 17;
    ageState.value = 16;

    expect(mockCallback, orderedEquals([true]));
  });
}

class Param1Callback<T> extends Iterable<T> {
  final _callStack = <T>[];
  void call(T value) {
    _callStack.add(value);
  }

  @override
  Iterator<T> get iterator => _callStack.iterator;
}
