import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger("bluetooth");
final _bluetoothClassicPlugin = BluetoothClassic();
final _serialUUID = "00001101-0000-1000-8000-00805F9B34FB";

class Bluetooth {
  String platformVersion = "Unknown";
  bool _scanning = false;

  List<Device> _pairedDevices = [];
  List<Device> _discoveredDevices = [];
  int _deviceStatus = Device.disconnected;

  Uint8List _data = Uint8List(0);
  bool _preserveData = false;

  List<void Function(int)> _deviceStatusListeners = [];
  List<void Function(Uint8List)> _dataReceivedListeners = [];
  void Function()? onScanStart;
  void Function()? onScanEnd;
  void Function(Device)? onDeviceDiscovered;

  void init() async {
    await _bluetoothClassicPlugin.initPermissions();

    try {
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ?? "Unknown platform version";
      _logger.info("Platform version: $platformVersion");
    } on PlatformException catch (e) {
      platformVersion = "Failed to get platform version";
      _logger.warning("Failed to get platform version: $e");
    }

    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((event) {
      _logger.finer("Device status changed: $event");
      _deviceStatus = event;

      for (var listener in _deviceStatusListeners) {
        listener(event);
      }
    });

    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      _data = _preserveData ? Uint8List.fromList([..._data, ...event]): event;
      _logger.finer("Received data: $event");

      for (var listener in _dataReceivedListeners) {
        listener(_data);
      }
    });
  }

  void addStatusCallback(void Function(int) callback) {
    _deviceStatusListeners.add(callback);
  }

  void removeStatusCallback(void Function(int) callback) {
    _deviceStatusListeners.remove(callback);
  }

  Future<void> getPairedDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    _pairedDevices = res;
  }

  Future<void> toggleScan() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      _scanning = false;
      onScanEnd?.call();
    } else {
      await _bluetoothClassicPlugin.startScan();
      
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (event) {
          _logger.finer("Discovered device: ${event.name}");
          _discoveredDevices = [..._discoveredDevices, event];
          onDeviceDiscovered?.call(event);
        },
      );
      
      _scanning = true;
      onScanStart?.call();
      _logger.info("Scanning for devices...");
    }
  }

  void connect(Device device) async {
    await _bluetoothClassicPlugin.connect(device.address, _serialUUID);
  }

  void write(String message, void Function() onError) {
    if (_deviceStatus == Device.connected) {
      _bluetoothClassicPlugin.write(message);
    } else {
      _logger.severe("Device not connected");
      onError();
    }
  }
}