import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final smartKitController = Get.find<SmartKitController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Home"),
            ElevatedButton(
              onPressed: () {
                smartKitController.findSmartKitDevices();
              },
              child: const Text("Search Devices"),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    smartKitController.connected.value
                        ? () => smartKitController.writeAndRead("h")
                        : null,
                child: const Text("Send message"),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String result = await smartKitController.read();
                debugPrint("read result: $result");
              },
              child: Text("read values"),
            ),
            Obx(() => Text("${smartKitController.response}")),
            ElevatedButton(
              onPressed:
                  true
                      ? () {
                        Get.toNamed('/monitor');
                      }
                      : null,
              child: const Text("monitor values"),
            ),
          ],
        ),
      ),
    );
  }
}
