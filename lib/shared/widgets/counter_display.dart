import 'package:flutter/material.dart';

class CounterDisplay extends StatelessWidget {
  final int counter;
  final String text;

  const CounterDisplay({super.key, required this.counter, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontSize: 16)),
        Text(
          '$counter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
