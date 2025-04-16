import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  // final List<Device> pairedDevices = <Device>[];

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  void findSmartkitDevices() {
    bluetooth.onMessageReceived((message) => _logger.info("Message received: $message"));
    bluetooth.startScan();

    //TODO: Write and read
  }
}
