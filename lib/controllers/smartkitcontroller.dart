import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  var connected = false.obs;
  var response = "".obs;

  void findSmartkitDevices() async {
    try {
      await bluetooth.startScan();
      await bluetooth.connect("HMSoft");
      connected.value = true;
    } catch (e) {
      _logger.severe("Error connecting to device: $e");
      connected.value = false;
    }
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
