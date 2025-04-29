import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  final smarkitController = Get.find<SmartKitController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [monitorData()],
        ),
      ),
    );
  }

  Obx monitorData() {
    return Obx(
      () => Column(
        children: [
          Text("Gas: ${smarkitController.data.value["g"]}"),
          Text("Light: ${smarkitController.data.value["l"]}"),
          Text("movement: ${smarkitController.data.value["i"]}"),
          Text("Water: ${smarkitController.data.value["w"]}"),
          Text("Soil: ${smarkitController.data.value["s"]}"),
        ],
      ),
    );
  }
}
