import 'dart:async';
import 'dart:convert';
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

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? target;

  void Function()? _onScanStart;
  void Function()? _onScanEnd;

  void Function(BluetoothDevice)? _deviceListener;
  void Function(String)? _onMessageReceived;

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

  void startScan() async {
    if (FlutterBluePlus.isScanningNow) return;

    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          _logger.fine('${r.device.remoteId}: "${r.advertisementData.advName}" found!');

          if (r.advertisementData.advName == "HMSoft") {
            _logger.info("Found HMSoft device");
            connect(r.device);
            _deviceListener?.call(r.device);
            stopScan();
          }
        }
      },
      onError: (e) => _logger.severe(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    FlutterBluePlus.startScan();
    _onScanStart?.call();
  }

  void stopScan() async {
    if (!FlutterBluePlus.isScanningNow) return;

    FlutterBluePlus.stopScan();
    _onScanEnd?.call();
  }

  void connect(BluetoothDevice device) async {
    // listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        _logger.info("Device disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}");

        //TODO: Attempt to reconnect
      }
      if (state == BluetoothConnectionState.connected) {
        _logger.info("Device connected");
      }
    });

    // cleanup: cancel subscription when disconnected
    //   - [delayed] This option is only meant for `connectionState` subscriptions.
    //     When `true`, we cancel after a small delay. This ensures the `connectionState`
    //     listener receives the `disconnected` event.
    //   - [next] if true, the the stream will be canceled only on the *next* disconnection,
    //     not the current disconnection. This is useful if you setup your subscriptions
    //     before you connect.
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    // Connect to the device
    await device.connect();
    _connectedDevice = device;
  }

  void disconnect(BluetoothDevice device) async {
    await device.disconnect();
    target = null;
  }

  Future<bool> write(String message, {Encoding encoding = utf8, bool expectResponse = false}) async {
    if (_connectedDevice == null) {
      _logger.severe("Illegal state: Not connected to a device");
      throw Exception("Not connected to a device");
    }

    if (target == null) {
      final services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          _logger.finer("Characteristic: ${char.properties}");
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _logger.finer("Characteristic found");
            // You can also check UUID if you know it
            target = char;
            break;
          }
        }
      }

      if (target != null) {
        // Should only run once when getting the target
        final subscription = target!.onValueReceived.listen((value) {
          _onMessageReceived?.call(encoding.decode(value));
        });

        _connectedDevice!.cancelWhenDisconnected(subscription);
      } else {
        _logger.warning("No characteristic with write properties found");
        return false;
      }
    }

    await target!.write(encoding.encode(message), withoutResponse: !expectResponse);

    return true;
  }

  Future<String> read({Encoding encoding = utf8}) async {
    if (target == null) {
      _logger.severe("Illegal state: Target characteristic is null");
      throw Exception("No target characteristic found");
    }

    List<int> value = await target!.read();
    return encoding.decode(value);
  }

  void onScanStart(void Function() onScanStart) {
    _onScanStart = onScanStart;
  }

  void onScanEnd(void Function() onScanEnd) {
    _onScanEnd = onScanEnd;
  }

  void onDeviceFound(void Function(BluetoothDevice device) onDeviceFound) {
    _deviceListener = onDeviceFound;
  }

  void onMessageReceived(void Function(String message) onMessageReceived) {
    _onMessageReceived = onMessageReceived;
  }
}
