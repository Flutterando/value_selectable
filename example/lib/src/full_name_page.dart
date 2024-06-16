import 'package:flutter/material.dart';
import 'package:value_selectable/value_selectable.dart';

final nameState = ValueNotifier<String>('');
final lastNameState = ValueNotifier<String>('');

final fullNameState = ValueSelector(
  (get) => '${get(nameState)} ${get(lastNameState)}',
);

class FullNamePage extends StatelessWidget {
  const FullNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 1'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (text) => nameState.value = text,
          ),
          TextField(
            onChanged: (text) => lastNameState.value = text,
          ),
          ValueListenableBuilder(
            valueListenable: fullNameState,
            builder: (context, value, child) {
              return Text(value);
            },
          ),
        ],
      ),
    );
  }
}
