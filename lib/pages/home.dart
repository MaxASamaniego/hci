import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';
import 'package:hci/pages/widgets/control_panel.dart';
import 'package:hci/pages/widgets/sensor_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final textController = TextEditingController();
  final smartKitController = Get.find<SmartKitController>();
  final notEmpty = false.obs;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const SensorBar()],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ControlPanel(),
                    SizedBox(
                      width: 500,
                      child: TextField(
                        controller: textController, 
                        onChanged: (value) => notEmpty.value = value.isNotEmpty,
                      ),
                    ),
                    Obx(
                      () => IconButton.filled(
                        onPressed: notEmpty.value ? 
                          () {
                            smartKitController.write(textController.text);
                            textController.text = "";
                            notEmpty.value = false;
                          } 
                        :
                          null, 
                        icon: Icon(Icons.send), 
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    ),
                    IconButton.filled(
                      onPressed: () => Get.toNamed("/piano"), 
                      icon: Icon(Icons.music_note),
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
