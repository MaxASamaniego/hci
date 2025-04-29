import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';
import 'package:hci/pages/widgets/sensor.dart';

class SensorBar extends StatefulWidget {
  const SensorBar({super.key});

  @override
  State<SensorBar> createState() => _SensorBarState();
}

class _SensorBarState extends State<SensorBar> {
  SmartKitController controller = Get.find<SmartKitController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 15,
        children: [
          SensorWidget(
            icon: Icons.co2, 
            text: controller.data.value["g"] ?? ""
          ),
          
          SensorWidget(
            icon: Icons.lightbulb, 
            text: controller.data.value["l"] ?? ""
          ),

          SensorWidget(
            icon: Icons.sensors, 
            text: controller.data.value["i"] ?? ""
          ),
          
          SensorWidget(
            icon: Icons.water_drop,
            text: controller.data.value["w"] ?? ""
          ),
          
          SensorWidget(
            icon: Icons.grass, 
            text: controller.data.value["s"] ?? ""
          ),
        ],
      )
    );
  }
}