import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final smartkitController = Get.find<Smartkitcontroller>();

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
                smartkitController.findSmartkitDevices();
              },
              child: const Text("Search Devices"),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    smartkitController.connected.value
                        ? () => smartkitController.writeAndRead("hhhhhhhhhhhhhhhhhhh")
                        : null,
                child: const Text("Send message"),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String result = await smartkitController.read();
                debugPrint("read result: $result");
              },
              child: Text("read values"),
            ),
            Obx(() => Text("${smartkitController.response}")),
          ],
        ),
      ),
    );
  }
}
