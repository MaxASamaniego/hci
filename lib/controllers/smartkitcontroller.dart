import 'dart:convert';

import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  var connected = false.obs;
  var response = "".obs;

  void findSmartkitDevices() async {
    bluetooth.onDeviceFound((result) {
      if (result.advertisementData.advName != "HMSoft") {
        return;
      }

      bluetooth.connect(result.advertisementData.advName);
      bluetooth.stopScan();
      connected.value = true;
    });
    
    try {
      await bluetooth.startScan();
    } catch (e) {
      _logger.severe("Error connecting to device: $e");
      connected.value = false;
    }
  }

  void writeAndRead(String message, {Encoding encoding = utf8}) async {
    await bluetooth.write(message, encoding: encoding);
    response.value = await bluetooth.read(encoding: encoding);
  }

  void write(String message) {
    bluetooth.write(message);
  }

  Future<String> read() {
    return bluetooth.read();
  }
}
