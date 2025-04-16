import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hci/bindings/homebinding.dart';
import 'package:hci/log_utils.dart';
import 'package:hci/pages/home.dart';

void main() {
  initializeLogger();
  runApp(GetMaterialApp(home: Home(), initialBinding: Homebinding()));
}
