import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class SensorWidget extends StatefulWidget {
  const SensorWidget({super.key, required this.icon, required this.text});

  final IconData icon;
  final RxString text;

  @override
  State<StatefulWidget> createState() => SensorState();
}

class SensorState extends State<SensorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Icon(widget.icon),
        ),
        Obx(() => 
          Text(widget.text.value),
        )
      ],
    );
  }
}