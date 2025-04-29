import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class ScanPage extends StatefulWidget{
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  final _controller = Get.find<SmartKitController>();
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _controller.findSmartKitDevices();
    _sub = _controller.connected.stream.listen(
      (val) {
        if (val) {
          Get.toNamed("/home");
          _sub!.cancel();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Text("Scanning...")
          ],
        ),
      ),
    );
  }
}