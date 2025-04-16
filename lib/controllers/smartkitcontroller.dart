import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  BluetoothDevice? hmSoftDevice;
  // final List<Device> pairedDevices = <Device>[];

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  void findSmartkitDevices() {
    bluetooth.onDeviceDiscovered = (device) {
      bluetooth.connect(device);
      bluetooth.toggleScan();
    };

    bluetooth.toggleScan();
  }
}
