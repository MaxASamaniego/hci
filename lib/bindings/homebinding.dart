import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Add your dependencies here
    // For example: Get.lazyPut<YourController>(() => YourController());
    Get.put<SmartKitController>(SmartKitController());
  }
}
