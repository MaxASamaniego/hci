import 'package:flutter/material.dart';
import 'package:hci/infrastructure/bluetooth.dart';
import 'package:hci/log_utils.dart';

void main() {
  initializeLogger();

  runApp(const MainApp());
  
  final bluetooth = Bluetooth();
  bluetooth.init();
  bluetooth.toggleScan();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
