import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  var connected = false.obs;
  var response = "".obs;

  void findSmartkitDevices() {
    bluetooth.onMessageReceived((message) => _logger.info("Message received: $message"));
    bluetooth.onConnect((_) => connected.value = true);
    bluetooth.onDisconnect((_) => connected.value = false);
    bluetooth.startScan();
  }

  void writeAndRead(String message) async {
    await bluetooth.write(message);
    response.value = await bluetooth.read();
  }

  void write(String message) {
    bluetooth.write(message);
  }

  Future<String> read() {
    return bluetooth.read();
  }
}
