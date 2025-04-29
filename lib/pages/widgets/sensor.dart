import 'package:flutter/material.dart';

class SensorWidget extends StatelessWidget {
  const SensorWidget({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 32,),
          ),
        ),
        Text(text)
      ],
    );
  }
}