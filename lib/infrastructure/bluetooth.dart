import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger("bluetooth");

Bluetooth? _instance;

class Bluetooth {
  Bluetooth._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetWrite;
  List<BluetoothService> _targetServices = [];
  Map<String, BluetoothDevice> devices = {};

  void Function()? _onScanStart;
  void Function()? _onScanEnd;
  void Function(ScanResult)? _onDeviceFound;

  void Function(BluetoothDevice)? _onConnect;
  void Function(BluetoothDevice)? _onDisconnect;

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

  Future<void> startScan() async {
    //searches for devices, finishes when scan is stopped
    if (FlutterBluePlus.isScanningNow) return;

    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        _logger.fine(
          '${r.device.remoteId}: "${r.advertisementData.advName}" found!',
        );
        devices[r.advertisementData.advName] = r.device;

        _onDeviceFound?.call(r);
      }
    }, onError: (e) => _logger.severe(e));

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    _onScanStart?.call();
    await FlutterBluePlus.startScan();
  }

  void stopScan() async {
    if (!FlutterBluePlus.isScanningNow) return;

    FlutterBluePlus.stopScan();
    _onScanEnd?.call();
  }

  Future<void> connect(String deviceName) async {
    //connects to device of given name, if none where found throws an error
    if (devices.isEmpty) {
      _logger.severe(
        "No devices found, make sure bluetooth is on and scanned previously",
      );
      throw Exception(
        "No se encontraron dispositivos, asegúrate que bluetooth este activado y haya sido escaneado previamente",
      );
    }
    if (!devices.containsKey(deviceName)) {
      _logger.severe("Device not found");
      throw Exception("No se encontró bluetooth con ese nombre");
    }

    BluetoothDevice? device = devices[deviceName];
    if (device == null) {
      _logger.severe("Device is null");
      throw Exception("Error, device is null");
    }
    var subscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        _logger.info(
          "Device disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}",
        );
        _connectedDevice = null;
        _onDisconnect?.call(device);
      }
      if (state == BluetoothConnectionState.connected) {
        _logger.info("Device connected");
        _connectedDevice = device;
        _onConnect?.call(device);
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
    _targetWrite = null;
  }

  void _ensureConnected() {
    if (_connectedDevice == null) {
      _logger.severe("Illegal state: Not connected to a device");
      throw Exception("Not connected to a device!");
    }
  }

  Future<List<BluetoothService>> getServices() async {
    _ensureConnected();

    if (_targetServices.isEmpty) {
      _targetServices = await _connectedDevice!.discoverServices();
    }

    return _targetServices;
  }

  Future<bool> write(
    String message, {
    Encoding encoding = utf8,
    bool expectResponse = false,
  }) async {
    if (_targetWrite == null) {
      for (var service in await getServices()) {
        _logger.finer("Service: $service");
        for (var char in service.characteristics) {
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _logger.finer("Characteristic found");
            // You can also check UUID if you know it
            _targetWrite = char;
            break;
          }
        }
      }

      if (_targetWrite == null) {
        _logger.warning("No characteristic with read properties found");
        return false;
      }
    }

    _ensureConnected();

    await _targetWrite!.write(
      encoding.encode(message),
      withoutResponse: !expectResponse,
    );

    _logger.finest("Sent: ${encoding.encode(message)}");

    return true;
  }

  void subscribeAll(void Function(List<int>) onNotification) async {
    for (var service in await getServices()) {
      for (var char in service.characteristics) {
        if (char.properties.notify) {
          final sub = char.onValueReceived.listen((value) {
            _logger.finer("Char UUID: ${char.characteristicUuid}");
            onNotification(value);
          });
          char.setNotifyValue(true);
          
          _connectedDevice!.cancelWhenDisconnected(sub);
        }
      }
    }
  }

  Future<void> subscribe(String uuid, void Function(List<int>) onNotification) async {
    for (var service in await getServices()) {
      for (var char in service.characteristics) {
        if (char.properties.notify && char.uuid.toString() == uuid) {
          final sub = char.onValueReceived.listen((data) {
            onNotification(data);
          });

          char.setNotifyValue(true);
          _logger.fine("Subscribed to characteristic: $uuid");
          _connectedDevice!.cancelWhenDisconnected(sub);
        }
      }
    }
  }

  void onScanStart(void Function() onScanStart) {
    _onScanStart = onScanStart;
  }

  void onScanEnd(void Function() onScanEnd) {
    _onScanEnd = onScanEnd;
  }

  void onDeviceFound(void Function(ScanResult result) onDeviceFound) {
    _onDeviceFound = onDeviceFound;
  }

  void onConnect(void Function(BluetoothDevice device) onConnect) {
    _onConnect = onConnect;
  }

  void onDisconnect(void Function(BluetoothDevice device) onDisconnect) {
    _onDisconnect = onDisconnect;
  }
}
