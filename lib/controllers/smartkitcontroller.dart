import 'dart:convert';

import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class SmartkitController extends GetxController {
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

    bluetooth.onConnect((_) {
      subscribeToDevice();
    });

    try {
      await bluetooth.startScan();
    } catch (e) {
      _logger.severe("Error connecting to device: $e");
      connected.value = false;
    }
  }

  void writeAndRead(String message, {Encoding encoding = utf8}) async {
    await bluetooth.write(message, encoding: encoding, expectResponse: true);
  }

  void write(String message) {
    bluetooth.write(message);
  }

  Future<String> read() async {
    bluetooth.subscribeAll((data) {
      _logger.finer("Received: $data");
      _logger.finest("Decoded: ${String.fromCharCodes(data)}");
    });
    return '';
  }

  void subscribeToDevice() async {
    await bluetooth.subscribe("ffe1", onDeviceNotification);
  }

  void onDeviceNotification(List<int> data) {
    String decodedMessage = String.fromCharCodes(data);
    // String type = decodedMessage.split(":")[0];
    // String value = decodedMessage.split(":")[1];
    ///definir funciones para cada tipo de mensaje
    response.value = decodedMessage;
  }
}
