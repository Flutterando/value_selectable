# ValueSelectable


![image](https://github.com/Flutterando/value_selectable/blob/main/assets/image.png?raw=true)

A Flutter package that provides computed values for `ValueNotifier`, inspired by the Selectors from Recoil.


## Overview

This package includes two main classes:

- `ValueSelector`: Computes a synchronous value based on a given scope.
- `AsyncValueSelector`: Computes an asynchronous value based on a given scope.

These classes allow you to create computed values that automatically update when their dependencies change, providing a reactive programming model similar to Recoil selectors.

## Features

- Reactive computation of values based on dependencies.
- Synchronous and asynchronous selectors.
- Automatic updates when dependencies change.
- Easy integration with Flutter's ValueNotifier.


## Installation

Add the following to your `pubspec.yaml`:

```
flutter pub add value_selectable
```


## Usage

### ValueSelector

Computes a synchronous value based on a given scope:

```dart
import 'package:flutter/widgets.dart';
import 'package:value_selectable/value_selectable.dart';

void main() {
  final valueNotifier = ValueNotifier<int>(1);
  final selector = ValueSelector<int>((get) => get(valueNotifier) + 1);

  print(selector.value); // Outputs: 2

  valueNotifier.value = 2;
  print(selector.value); // Outputs: 3
}

```

### AsyncValueSelector

Computes an asynchronous value based on a given scope.

```dart
import 'package:flutter/widgets.dart';
import 'package:value_notifier_selectors/value_notifier_selectors.dart';
import 'dart:async';

void main() async {
  final valueNotifier = ValueNotifier<int>(1);
  final selector = AsyncValueSelector<int>(0, (get) async => get(valueNotifier) + 1);

  await selector.isReady;
  print(selector.value); // Outputs: 2

  valueNotifier.value = 2;
  await Future.delayed(Duration(milliseconds: 300));
  print(selector.value); // Outputs: 3
}

```

## Advance Usage

As classes `ValueSelectable` trabalham devirando valores de outros `ValueListenable`, mas isso
também pode ser feito por meio de ações utilizando o setter do `value` de um `ValueSelectable`.
Note que ao alterar esse `value` nada acontecerá se a função `set` não for implementada no construtor de uma das classes do `ValueSelectable`.

Com isso em mente poderemos fazer derivações utilizando ações de uma forma parecida com um `Reducer`:

```dart
  final counterState = ValueNotifier<int>(0);

  final selectorState = ValueSelector<int>(
    (get) => get(counterState) + 1,
    (action) {
      if (action == 'INCREMENT') counterState.value++;
      if (action == 'DECREMENT') counterState.value--;
    },
  );

  // directly change
  counterState.value = 1;

  // indirectly change
  selectorState.value = 'INCREMENT';
  selectorState.value = 'DECREMENT';

```


## Contributing

Contributions are welcome! Please open an issue or submit a pull request.