import 'dart:convert';

import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Smart Kit Controller");

class SmartKitController extends GetxController {
  final bluetooth = Bluetooth();

  var connected = false.obs;
  Rx<Map<String, String>> data = Rx({});

  void findSmartKitDevices() async {
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
    this.data.value = _Parser.parseToMap(_Parser.parse(decodedMessage));
  }
}

sealed class _Parser {
  static final RegExp pattern = RegExp(
    r'^g:\d+\|l:\d+\|i:\d+\|w:\d+\|s:\d+\|$',
  );
  static String buffer = "";
  static String lastRead = "";

  static Map<String, String> parseToMap(String message) {
    final Map<String, String> parsedData = {};

    if (message.isEmpty) {
      return parsedData;
    }

    final List<String> parts = message.split("|");

    for (String part in parts) {
      final List<String> keyValue = part.split(":");
      if (keyValue.length == 2) {
        parsedData[keyValue[0]] = keyValue[1];
      }
    }

    return parsedData;
  }

  static String parse(String message) {
    String read = "";
    int i = 0;

    if (buffer.isEmpty) {
      bool store = false;

      for (; i < message.length; i++) {
        if (message[i] == "\$") {
          store = true;
          continue;
        } else if (message[i] == "#") {
          break;
        }

        if (store) {
          buffer += message[i];
        }
      }
    }

    for (; i < message.length; i++) {
      if (message[i] == "#") {
        read = buffer;

        // Optimistic guess since the end of the message and the start of the next one
        // should be next to each other, so the character next to # should be $
        if (i + 2 < message.length) {
          buffer = message.substring(i + 2);
        }

        break;
      } else if (message[i] == "\$") {
        buffer = "";
        continue;
      }

      buffer += message[i];
    }

    if (pattern.hasMatch(read)) {
      lastRead = read;
    }

    return lastRead;
  }
}
