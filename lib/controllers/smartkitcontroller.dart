import 'package:get/get.dart';
import 'package:hci/infrastructure/bluetooth.dart';

class Smartkitcontroller extends GetxController {
  final bluetooth = Bluetooth();
  // final List<Device> pairedDevices = <Device>[];

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  Future<void> findSmartkitDevices() async {
    await bluetooth.toggleScan();
  }
}
