import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialService {
  static final SerialService _instance = SerialService._internal();
  factory SerialService() => _instance;
  SerialService._internal();

  SerialPort? _port;
  String? _connectedPortName;

  bool get isConnected => _port != null && _port!.isOpen;
  String? get connectedPortName => _connectedPortName;

  List<String> get availablePorts => SerialPort.availablePorts;

  bool connect(String portName, int baudRate) {
    disconnect(); // Close existing

    try {
      final port = SerialPort(portName);
      if (port.openReadWrite()) {
        _port = port;
        _connectedPortName = portName;

        SerialPortConfig config = port.config;
        config.baudRate = baudRate;
        config.bits = 8;
        config.stopBits = 1;
        config.parity = 0; // None
        port.config = config;

        return true;
      }
    } catch (e) {
      debugPrint("Error connecting to $portName: $e");
    }
    return false;
  }

  void disconnect() {
    if (_port != null) {
      _port!.close();
      _port!.dispose();
      _port = null;
      _connectedPortName = null;
    }
  }

  Stream<String> getReaderStream() {
    if (_port == null) return const Stream.empty();

    // Simple line reader approach
    return SerialPortReader(_port!).stream.map((Uint8List data) {
      return String.fromCharCodes(data);
    });
  }

  void write(String data) {
    if (isConnected) {
      _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }
}
