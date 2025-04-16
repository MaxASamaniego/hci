import 'package:bluetooth_classic/models/device.dart';
import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  final List<Device> pairedDevices = <Device>[];

  @override
  void onInit() {
    super.onInit();
    bluetooth.init();
  }

  Future<void> findSmartkitDevices() async {
    await bluetooth.toggleScan();
  }
}
