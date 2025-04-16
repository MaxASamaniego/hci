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

  String platformVersion = "Unknown";

  List<BluetoothService> services = [];
  BluetoothCharacteristic? target;

  void Function()? onScanStart;
  void Function()? onScanEnd;

  void Function(BluetoothDevice)? onDeviceDiscovered;

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
            _logger.fine(
                '${r.device.remoteId}: "${r.advertisementData.advName}" found!');

            if (r.advertisementData.advName == "HMSoft") {
              _logger.info("Found HMSoft device");
              onDeviceDiscovered?.call(r.device);
            }
          }
        },
        onError: (e) => _logger.severe(e),
      );

      // cleanup: cancel subscription when scanning stops
      FlutterBluePlus.cancelWhenScanComplete(subscription);

      FlutterBluePlus.startScan();
    }
  }

  void connect(BluetoothDevice device) async {
    // listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        _logger.info(
            "Device disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}");
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
    services = await device.discoverServices();
    _logger.finer("Found services: $services");
    write("Hello world");
  }

  void disconnect(BluetoothDevice device) async {
    await device.disconnect();
    services = [];
  }

  void write(String message) async {
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

    await target!.write(utf8.encode(message), withoutResponse: false);

    target!.onValueReceived.listen((value) {
      try {
        // Allow malformed input in case the data is not valid UTF-8.
        String response = utf8.decode(value, allowMalformed: true);
        _logger.info("Received: $response");
      } catch (e) {
        _logger.warning("Failed to decode response: $e");
      }
    });

    target!.read();
  }

  Future<String> read() async {
    if (target == null) {
      throw Exception("No target characteristic found");
    }

    List<int> value = await target!.read();
    return utf8.decode(value);
  }
}
