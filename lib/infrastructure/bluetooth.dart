import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger("bluetooth");
final _serialUUID = "00001101-0000-1000-8000-00805F9B34FB";

Bluetooth? _instance;

class Bluetooth {
  Bluetooth._internal();

  String platformVersion = "Unknown";
  bool _scanning = false;

  //List<Device> _pairedDevices = [];
  // List<Device> _discoveredDevices = [];

  Uint8List _data = Uint8List(0);
  bool _preserveData = false;

  List<void Function(int)> _deviceStatusListeners = [];
  List<void Function(Uint8List)> _dataReceivedListeners = [];
  void Function()? onScanStart;
  void Function()? onScanEnd;
  void Function(ScanResult)? onDeviceDiscovered;

  factory Bluetooth() {
    if (_instance == null) {
      _instance = Bluetooth._internal();
      _instance!.init();
    }

    return _instance!;
  }

  void init() async {
    FlutterBluePlus.setLogLevel(LogLevel.info);

    if (await FlutterBluePlus.isSupported == false) {
      _logger.severe("Bluetooth is not supported");
      return;
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      _logger.info("Bluetooth adapter state changed: $state");
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        FlutterBluePlus.stopScan();
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> toggleScan() async {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
      onScanEnd?.call();
    } else {
      var subscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last; // the most recently found device
            _logger.fine('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            onDeviceDiscovered?.call(r);
          }
        },
        onError: (e) => _logger.severe(e),
      );

      // cleanup: cancel subscription when scanning stops
      FlutterBluePlus.cancelWhenScanComplete(subscription);

      FlutterBluePlus.startScan();
    }
  }
}
