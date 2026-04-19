// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BluetoothManager {
//   BluetoothDevice? _device;
//   StreamSubscription<List<ScanResult>>? _scanSubscription;
//   StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
//   StreamSubscription<List<int>>? _characteristicSubscription;
//   Timer? _scanTimer;
//   bool _isConnected = false;
//   String? _lastMessage;
//   bool _isScanning = false;

//   Future<bool> _checkPermissions() async {
//     print("Checking Bluetooth permissions...");
//     Map<Permission, PermissionStatus> statuses =
//         await [
//           Permission.bluetooth,
//           Permission.bluetoothScan,
//           Permission.bluetoothConnect,
//           Permission.location,
//         ].request();

//     bool allGranted = statuses.values.every((status) => status.isGranted);
//     if (!allGranted) {
//       print("Permissions denied: $statuses");
//     }
//     return allGranted;
//   }

//   Future<void> _clearBonding(BluetoothDevice device) async {
//     try {
//       print("Clearing bonding for device: ${device.id}");
//       await device.disconnect();
//       await Future.delayed(const Duration(milliseconds: 500));
//     } catch (e) {
//       print("Error clearing bonding: $e");
//     }
//   }

//   Future<void> connectToBluetooth({
//     required BuildContext context,
//     required String docId,
//     required Function(String) onHeartRateUpdate,
//     required Function(String) onMessage,
//     required Function(bool) onFetchingStateChange,
//     required bool isRefresh,
//   }) async {
//     try {
//       if (_isConnected && !isRefresh) {
//         print("Already connected to NanoHRM, skipping connection");
//         return;
//       }
//       onFetchingStateChange(true);
//       print("Starting Bluetooth connection for NanoHRM...");

//       // Check permissions
//       bool hasPermissions = await _checkPermissions();
//       if (!hasPermissions) {
//         print("Bluetooth permissions not granted");
//         _showMessage(
//           "Please grant Bluetooth and location permissions",
//           onMessage,
//         );
//         onFetchingStateChange(false);
//         return;
//       }

//       // Check Bluetooth state
//       try {
//         bool isBluetoothOn = await FlutterBluePlus.isOn.timeout(
//           const Duration(seconds: 5),
//           onTimeout: () => false,
//         );
//         if (!isBluetoothOn) {
//           print("Bluetooth is off");
//           _showMessage("Please turn on Bluetooth", onMessage);
//           onFetchingStateChange(false);
//           return;
//         }
//         print("Bluetooth is on");
//       } catch (e) {
//         print("Error checking Bluetooth state: $e");
//         _showMessage("Bluetooth unavailable", onMessage);
//         onFetchingStateChange(false);
//         return;
//       }

//       // Check system paired devices
//       print("Checking for paired NanoHRM...");
//       List<BluetoothDevice> systemDevices = await FlutterBluePlus.systemDevices(
//         [],
//       );
//       for (BluetoothDevice device in systemDevices) {
//         String deviceName = device.name.isEmpty ? "Unnamed" : device.name;
//         print("System device: $deviceName (${device.id})");
//         if (deviceName.toLowerCase().contains("nanohrm")) {
//           _device = device;
//           print("Found paired NanoHRM: ${device.id}");
//           await _clearBonding(device);
//           try {
//             print("Attempting to connect to paired NanoHRM...");
//             await device.connect(timeout: const Duration(seconds: 10));
//             _isConnected = true;
//             print("Connected to paired NanoHRM: ${device.id}");
//             await _setupHeartRateSubscription(
//               docId: docId,
//               onHeartRateUpdate: onHeartRateUpdate,
//               onMessage: onMessage,
//               onFetchingStateChange: onFetchingStateChange,
//             );
//             return;
//           } catch (e) {
//             print("Failed to connect to paired NanoHRM: $e");
//             if (e.toString().contains("pairing")) {
//               _showMessage(
//                 "Pairing error. Please unpair NanoHRM from Bluetooth settings, restart Bluetooth, and try again",
//                 onMessage,
//               );
//             } else {
//               _showMessage("Failed to connect to NanoHRM", onMessage);
//             }
//             onFetchingStateChange(false);
//             await device.disconnect();
//             _device = null;
//             break;
//           }
//         }
//       }

//       // Check connected devices
//       print("Checking for connected NanoHRM...");
//       List<BluetoothDevice> connectedDevices =
//           await FlutterBluePlus.connectedDevices;
//       for (BluetoothDevice device in connectedDevices) {
//         String deviceName = device.name.isEmpty ? "Unnamed" : device.name;
//         print("Connected device: $deviceName (${device.id})");
//         if (deviceName.toLowerCase().contains("nanohrm")) {
//           _device = device;
//           _isConnected = true;
//           print("Using already connected NanoHRM: ${device.id}");
//           await _setupHeartRateSubscription(
//             docId: docId,
//             onHeartRateUpdate: onHeartRateUpdate,
//             onMessage: onMessage,
//             onFetchingStateChange: onFetchingStateChange,
//           );
//           return;
//         }
//       }

//       // Fallback to scanning
//       print("NanoHRM not found in system/connected devices, starting scan...");
//       if (_isScanning) {
//         print("Stopping previous scan...");
//         await FlutterBluePlus.stopScan();
//         _scanSubscription?.cancel();
//         _scanTimer?.cancel();
//         await Future.delayed(const Duration(milliseconds: 1000));
//       }

//       try {
//         print("Initiating scan...");
//         _isScanning = true;
//         await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//         print("Scan started");
//       } catch (e) {
//         print("Scan start error: $e");
//         _showMessage("Failed to start Bluetooth scan", onMessage);
//         _isScanning = false;
//         onFetchingStateChange(false);
//         return;
//       }

//       _scanTimer?.cancel();
//       _scanTimer = Timer(const Duration(seconds: 15), () {
//         FlutterBluePlus.stopScan();
//         _isScanning = false;
//         print("Scan timeout, stopping...");
//         _showMessage(
//           "Please ensure NanoHRM is turned on and not connected elsewhere",
//           onMessage,
//         );
//         onFetchingStateChange(false);
//       });

//       _scanSubscription?.cancel();
//       _scanSubscription = FlutterBluePlus.scanResults.listen(
//         (results) async {
//           for (ScanResult result in results) {
//             String deviceName =
//                 result.device.name.isEmpty ? "Unnamed" : result.device.name;
//             String serviceUuids = result.advertisementData.serviceUuids.join(
//               ", ",
//             );
//             print(
//               "Scan found: $deviceName (${result.device.id}), UUIDs: $serviceUuids",
//             );
//             bool isNanoHRM =
//                 result.advertisementData.serviceUuids.contains("180d") ||
//                 deviceName.toLowerCase().contains("nanohrm");
//             if (isNanoHRM && (!_isConnected || isRefresh)) {
//               _device = result.device;
//               print("NanoHRM found: ${result.device.id}");
//               await FlutterBluePlus.stopScan();
//               _isScanning = false;
//               _scanTimer?.cancel();
//               _scanSubscription?.cancel();

//               for (int attempt = 1; attempt <= 3; attempt++) {
//                 try {
//                   print("Connecting to NanoHRM, attempt $attempt...");
//                   await _clearBonding(_device!);
//                   await _device!.connect(timeout: const Duration(seconds: 10));
//                   print("Connected to NanoHRM: ${_device!.id}");
//                   _isConnected = true;

//                   _connectionSubscription?.cancel();
//                   _connectionSubscription = _device!.connectionState.listen((
//                     state,
//                   ) async {
//                     print("Connection state: $state");
//                     if (state == BluetoothConnectionState.disconnected) {
//                       print("NanoHRM disconnected");
//                       _isConnected = false;
//                       try {
//                         await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(docId)
//                             .collection('health_info')
//                             .doc('data')
//                             .set({
//                               'connectionStatus': 'disconnected',
//                               'lastUpdated': FieldValue.serverTimestamp(),
//                             }, SetOptions(merge: true));
//                         print("Firestore updated with disconnection status");
//                       } catch (e) {
//                         print("Error updating disconnection status: $e");
//                       }
//                       await _device?.disconnect();
//                       if (!isRefresh && attempt < 3) {
//                         print("Retrying connection silently...");
//                         await connectToBluetooth(
//                           context: context,
//                           docId: docId,
//                           onHeartRateUpdate: onHeartRateUpdate,
//                           onMessage: onMessage,
//                           onFetchingStateChange: onFetchingStateChange,
//                           isRefresh: true,
//                         );
//                       } else {
//                         _showMessage("NanoHRM disconnected", onMessage);
//                       }
//                     } else if (state == BluetoothConnectionState.connected) {
//                       try {
//                         await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(docId)
//                             .collection('health_info')
//                             .doc('data')
//                             .set({
//                               'connectionStatus': 'connected',
//                               'lastUpdated': FieldValue.serverTimestamp(),
//                             }, SetOptions(merge: true));
//                         print("Firestore updated with connection status");
//                       } catch (e) {
//                         print("Error updating connection status: $e");
//                       }
//                     }
//                   });

//                   await _setupHeartRateSubscription(
//                     docId: docId,
//                     onHeartRateUpdate: onHeartRateUpdate,
//                     onMessage: onMessage,
//                     onFetchingStateChange: onFetchingStateChange,
//                   );
//                   return;
//                 } catch (e) {
//                   print("Connection error, attempt $attempt: $e");
//                   _isConnected = false;
//                   await _device?.disconnect();
//                   if (e.toString().contains("pairing")) {
//                     _showMessage(
//                       "Pairing error. Please unpair NanoHRM from Bluetooth settings, restart Bluetooth, and try again",
//                       onMessage,
//                     );
//                     onFetchingStateChange(false);
//                     return;
//                   }
//                   if (attempt == 3) {
//                     _showMessage(
//                       "Please ensure NanoHRM is turned on and not connected elsewhere",
//                       onMessage,
//                     );
//                     onFetchingStateChange(false);
//                     break;
//                   }
//                   await Future.delayed(const Duration(seconds: 2));
//                 }
//               }
//               return;
//             }
//           }
//         },
//         onError: (e) {
//           print("Scan error: $e");
//           _showMessage("Scan failed", onMessage);
//           _isScanning = false;
//           onFetchingStateChange(false);
//         },
//       );
//     } catch (e) {
//       print("Unexpected Bluetooth error: $e");
//       _showMessage("Bluetooth error occurred", onMessage);
//       _isScanning = false;
//       onFetchingStateChange(false);
//     }
//   }

//   Future<void> _setupHeartRateSubscription({
//     required String docId,
//     required Function(String) onHeartRateUpdate,
//     required Function(String) onMessage,
//     required Function(bool) onFetchingStateChange,
//   }) async {
//     try {
//       List<BluetoothService> services = await _device!.discoverServices();
//       for (BluetoothService service in services) {
//         if (service.uuid.toString().toLowerCase().startsWith("180d")) {
//           for (BluetoothCharacteristic char in service.characteristics) {
//             if (char.uuid.toString().toLowerCase().startsWith("2a37")) {
//               if (char.properties.notify) {
//                 bool notifyEnabled = false;
//                 for (
//                   int notifyAttempt = 1;
//                   notifyAttempt <= 3;
//                   notifyAttempt++
//                 ) {
//                   try {
//                     print(
//                       "Enabling notifications for 2A37, attempt $notifyAttempt",
//                     );
//                     await char.setNotifyValue(true);
//                     notifyEnabled = true;
//                     print("Notifications enabled for 2A37");
//                     break;
//                   } catch (e) {
//                     print("Notify enable error, attempt $notifyAttempt: $e");
//                     if (notifyAttempt == 3) {
//                       _showMessage(
//                         "Failed to enable heart rate notifications",
//                         onMessage,
//                       );
//                       onFetchingStateChange(false);
//                       return;
//                     }
//                     await Future.delayed(const Duration(milliseconds: 500));
//                   }
//                 }
//                 if (notifyEnabled) {
//                   await Future.delayed(const Duration(milliseconds: 500));
//                   _characteristicSubscription?.cancel();
//                   _characteristicSubscription = char.value.listen(
//                     (data) {
//                       print("Raw heart rate data: $data");
//                       if (data.isNotEmpty) {
//                         int heartRate = 0;
//                         if (data.length >= 2) {
//                           heartRate = data[0] | (data[1] << 8);
//                         } else if (data.length == 1) {
//                           heartRate = data[0];
//                         }
//                         if (heartRate >= 60 && heartRate <= 100) {
//                           onHeartRateUpdate(heartRate.toString());
//                           FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(docId)
//                               .collection('health_info')
//                               .doc('data')
//                               .set({
//                                 'heartRate': heartRate.toString(),
//                                 'lastUpdated': FieldValue.serverTimestamp(),
//                               }, SetOptions(merge: true))
//                               .then(
//                                 (_) => print(
//                                   "Firestore updated with heart rate: $heartRate",
//                                 ),
//                               )
//                               .catchError(
//                                 (e) => print("Error updating Firestore: $e"),
//                               );
//                           print("Heart rate: $heartRate");
//                         } else {
//                           print("Invalid heart rate: $heartRate");
//                         }
//                       }
//                     },
//                     onError: (e) {
//                       print("Characteristic error: $e");
//                     },
//                   );
//                   _showMessage("Connected to NanoHRM", onMessage);
//                   onFetchingStateChange(false);
//                   return;
//                 }
//               }
//             }
//           }
//         }
//       }
//       print("Heart rate service not found");
//       _isConnected = false;
//       await _device!.disconnect();
//       _showMessage("Heart rate service not found on NanoHRM", onMessage);
//       onFetchingStateChange(false);
//     } catch (e) {
//       print("Error setting up heart rate subscription: $e");
//       _showMessage("Failed to setup heart rate monitoring", onMessage);
//       _isConnected = false;
//       await _device?.disconnect();
//       onFetchingStateChange(false);
//     }
//   }

//   void _showMessage(String message, Function(String) onMessage) {
//     if (_lastMessage != message) {
//       onMessage(message);
//       _lastMessage = message;
//       if (message == "Connected to NanoHRM") {
//         _lastMessage = null;
//       }
//     }
//   }

//   void dispose() {
//     _scanSubscription?.cancel();
//     _scanSubscription = null;
//     _connectionSubscription?.cancel();
//     _connectionSubscription = null;
//     _characteristicSubscription?.cancel();
//     _characteristicSubscription = null;
//     _scanTimer?.cancel();
//     _scanTimer = null;
//     if (_device != null) {
//       _device!.disconnect();
//       _device = null;
//     }
//     _isConnected = false;
//     _isScanning = false;
//     _lastMessage = null;
//     print("BluetoothManager disposed");
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothManager {
  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  Timer? _scanTimer;
  bool _isConnected = false;
  String? _lastMessage;
  bool _isScanning = false;
  bool _isConnecting = false;

  Future<bool> _checkPermissions() async {
    print("Checking Bluetooth permissions...");
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      print("Permissions denied: $statuses");
    }
    return allGranted;
  }

  Future<void> _ensureDisconnected(BluetoothDevice device) async {
    try {
      print("Ensuring device is disconnected: ${device.id}");
      await device.disconnect();
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      print("Error ensuring disconnection: $e");
    }
  }

  Future<bool> _isDeviceBonded(BluetoothDevice device) async {
    List<BluetoothDevice> systemDevices = await FlutterBluePlus.systemDevices(
      [],
    );
    return systemDevices.any((d) => d.id == device.id);
  }

  Future<void> connectToBluetooth({
    required BuildContext? context,
    required String docId,
    required Function(String) onHeartRateUpdate,
    required Function(String) onMessage,
    required Function(bool) onFetchingStateChange,
    required bool isRefresh,
  }) async {
    if (_isConnecting) {
      print("Connection already in progress, ignoring...");
      return;
    }

    try {
      _isConnecting = true;
      onFetchingStateChange(true);
      print("Starting Bluetooth connection for NanoHRM...");

      // Check permissions
      bool hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        _showMessage(
          context,
          "Please grant Bluetooth and location permissions in settings",
          onMessage,
        );
        onFetchingStateChange(false);
        return;
      }

      // Check Bluetooth state
      bool isBluetoothOn = await FlutterBluePlus.isOn.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!isBluetoothOn) {
        print("Bluetooth is off");
        _showMessage(
          context,
          "Please turn on Bluetooth in settings",
          onMessage,
        );
        onFetchingStateChange(false);
        return;
      }
      print("Bluetooth is on");

      // Check connected devices first
      print("Checking for connected NanoHRM...");
      List<BluetoothDevice> connectedDevices =
          await FlutterBluePlus.connectedDevices;
      for (BluetoothDevice device in connectedDevices) {
        String deviceName = device.name.isEmpty ? "Unnamed" : device.name;
        print("Connected device: $deviceName (${device.id})");
        if (deviceName.toLowerCase().contains("nanohrm")) {
          _device = device;
          _isConnected = true;
          print("Using already connected NanoHRM: ${device.id}");
          await _setupHeartRateSubscription(
            docId: docId,
            onHeartRateUpdate: onHeartRateUpdate,
            onMessage: onMessage,
            onFetchingStateChange: onFetchingStateChange,
            context: context,
          );
          return;
        }
      }

      // Check system paired devices
      print("Checking for paired NanoHRM...");
      List<BluetoothDevice> systemDevices = await FlutterBluePlus.systemDevices(
        [],
      );
      BluetoothDevice? pairedDevice;
      for (BluetoothDevice device in systemDevices) {
        String deviceName = device.name.isEmpty ? "Unnamed" : device.name;
        print("System device: $deviceName (${device.id})");
        if (deviceName.toLowerCase().contains("nanohrm")) {
          pairedDevice = device;
          break;
        }
      }

      if (pairedDevice != null && (!isRefresh || !_isConnected)) {
        _device = pairedDevice;
        print("Found paired NanoHRM: ${_device!.id}");
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            print("Connecting to paired NanoHRM, attempt $attempt...");
            await _ensureDisconnected(_device!);
            await _device!.connect(timeout: const Duration(seconds: 15));
            _isConnected = true;
            print("Connected to paired NanoHRM: ${_device!.id}");
            await _setupConnectionMonitoring(
              docId: docId,
              onHeartRateUpdate: onHeartRateUpdate,
              onMessage: onMessage,
              onFetchingStateChange: onFetchingStateChange,
              isRefresh: isRefresh,
              context: context,
            );
            await _setupHeartRateSubscription(
              docId: docId,
              onHeartRateUpdate: onHeartRateUpdate,
              onMessage: onMessage,
              onFetchingStateChange: onFetchingStateChange,
              context: context,
            );
            return;
          } catch (e) {
            print("Connection error, attempt $attempt: $e");
            _isConnected = false;
            if (e.toString().contains("pairing")) {
              _showMessage(
                context,
                "Pairing error. Please unpair NanoHRM from Bluetooth settings, restart Bluetooth, and try again",
                onMessage,
              );
              onFetchingStateChange(false);
              return;
            }
            if (attempt == 3) {
              _showMessage(
                context,
                "Failed to connect to NanoHRM. Ensure it's powered on and not connected to another device",
                onMessage,
              );
              onFetchingStateChange(false);
              return;
            }
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      // Fallback to scanning
      print("NanoHRM not found in system/connected devices, starting scan...");
      if (_isScanning) {
        print("Stopping previous scan...");
        await FlutterBluePlus.stopScan();
        _scanSubscription?.cancel();
        _scanTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      try {
        print("Initiating scan...");
        _isScanning = true;
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));
        print("Scan started");
      } catch (e) {
        print("Scan start error: $e");
        _showMessage(context, "Failed to start Bluetooth scan", onMessage);
        _isScanning = false;
        onFetchingStateChange(false);
        return;
      }

      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: 20), () {
        if (_isScanning) {
          FlutterBluePlus.stopScan();
          _isScanning = false;
          print("Scan timeout, stopping...");
          _showMessage(
            context,
            "NanoHRM not found. Ensure it's powered on and not connected elsewhere",
            onMessage,
          );
          onFetchingStateChange(false);
        }
      });

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) async {
          for (ScanResult result in results) {
            String deviceName =
                result.device.name.isEmpty ? "Unnamed" : result.device.name;
            String serviceUuids = result.advertisementData.serviceUuids.join(
              ", ",
            );
            print(
              "Scan found: $deviceName (${result.device.id}), UUIDs: $serviceUuids",
            );
            if (deviceName.toLowerCase().contains("nanohrm") ||
                result.advertisementData.serviceUuids.contains("180d")) {
              _device = result.device;
              print("NanoHRM found: ${_device!.id}");
              await FlutterBluePlus.stopScan();
              _isScanning = false;
              _scanTimer?.cancel();
              _scanSubscription?.cancel();

              for (int attempt = 1; attempt <= 3; attempt++) {
                try {
                  print("Connecting to NanoHRM, attempt $attempt...");
                  await _ensureDisconnected(_device!);
                  await _device!.connect(timeout: const Duration(seconds: 15));
                  _isConnected = true;
                  print("Connected to NanoHRM: ${_device!.id}");
                  await _setupConnectionMonitoring(
                    docId: docId,
                    onHeartRateUpdate: onHeartRateUpdate,
                    onMessage: onMessage,
                    onFetchingStateChange: onFetchingStateChange,
                    isRefresh: isRefresh,
                    context: context,
                  );
                  await _setupHeartRateSubscription(
                    docId: docId,
                    onHeartRateUpdate: onHeartRateUpdate,
                    onMessage: onMessage,
                    onFetchingStateChange: onFetchingStateChange,
                    context: context,
                  );
                  return;
                } catch (e) {
                  print("Connection error, attempt $attempt: $e");
                  _isConnected = false;
                  if (e.toString().contains("pairing")) {
                    _showMessage(
                      context,
                      "Pairing error. Please unpair NanoHRM from Bluetooth settings, restart Bluetooth, and try again",
                      onMessage,
                    );
                    onFetchingStateChange(false);
                    return;
                  }
                  if (attempt == 3) {
                    _showMessage(
                      context,
                      "Failed to connect to NanoHRM. Ensure it's powered on and not connected to another device",
                      onMessage,
                    );
                    onFetchingStateChange(false);
                    return;
                  }
                  await Future.delayed(const Duration(seconds: 3));
                }
              }
            }
          }
        },
        onError: (e) {
          print("Scan error: $e");
          _showMessage(context, "Failed to scan for NanoHRM", onMessage);
          _isScanning = false;
          onFetchingStateChange(false);
        },
      );
    } catch (e) {
      print("Unexpected Bluetooth error: $e");
      _showMessage(context, "Bluetooth error occurred", onMessage);
      _isScanning = false;
      onFetchingStateChange(false);
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _setupConnectionMonitoring({
    required String docId,
    required Function(String) onHeartRateUpdate,
    required Function(String) onMessage,
    required Function(bool) onFetchingStateChange,
    required bool isRefresh,
    required BuildContext? context,
  }) async {
    _connectionSubscription?.cancel();
    _connectionSubscription = _device!.connectionState.listen((state) async {
      print("Connection state: $state");
      if (state == BluetoothConnectionState.disconnected) {
        print("NanoHRM disconnected");
        _isConnected = false;
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .collection('health_info')
              .doc('data')
              .set({
                'connectionStatus': 'disconnected',
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
          print("Firestore updated with disconnection status");
        } catch (e) {
          print("Error updating disconnection status: $e");
        }
        _characteristicSubscription?.cancel();
        if (!isRefresh) {
          print("Attempting to reconnect silently...");
          await connectToBluetooth(
            context: context,
            docId: docId,
            onHeartRateUpdate: onHeartRateUpdate,
            onMessage: onMessage,
            onFetchingStateChange: onFetchingStateChange,
            isRefresh: true,
          );
        } else {
          _showMessage(context, "NanoHRM disconnected", onMessage);
        }
      } else if (state == BluetoothConnectionState.connected) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .collection('health_info')
              .doc('data')
              .set({
                'connectionStatus': 'connected',
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
          print("Firestore updated with connection status");
        } catch (e) {
          print("Error updating connection status: $e");
        }
      }
    });
  }

  Future<void> _setupHeartRateSubscription({
    required String docId,
    required Function(String) onHeartRateUpdate,
    required Function(String) onMessage,
    required Function(bool) onFetchingStateChange,
    required BuildContext? context,
  }) async {
    try {
      // Wait briefly to ensure connection stability
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!_isConnected || _device == null) {
        print("Device not connected, cannot setup subscription");
        _showMessage(context, "Device not connected", onMessage);
        onFetchingStateChange(false);
        return;
      }

      List<BluetoothService> services = await _device!
          .discoverServices()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Service discovery timed out");
            },
          );
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().startsWith("180d")) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString().toLowerCase().startsWith("2a37")) {
              if (char.properties.notify) {
                bool notifyEnabled = false;
                for (
                  int notifyAttempt = 1;
                  notifyAttempt <= 3;
                  notifyAttempt++
                ) {
                  try {
                    print(
                      "Enabling notifications for 2A37, attempt $notifyAttempt",
                    );
                    await char
                        .setNotifyValue(true)
                        .timeout(
                          const Duration(seconds: 5),
                          onTimeout: () {
                            throw Exception("Notification enable timed out");
                          },
                        );
                    notifyEnabled = true;
                    print("Notifications enabled for 2A37");
                    break;
                  } catch (e) {
                    print("Notify enable error, attempt $notifyAttempt: $e");
                    if (notifyAttempt == 3) {
                      _showMessage(
                        context,
                        "Failed to enable heart rate notifications",
                        onMessage,
                      );
                      onFetchingStateChange(false);
                      return;
                    }
                    await Future.delayed(const Duration(milliseconds: 1000));
                  }
                }
                if (notifyEnabled) {
                  _characteristicSubscription?.cancel();
                  _characteristicSubscription = char.value.listen(
                    (data) {
                      print("Raw heart rate data: $data");
                      if (data.isNotEmpty) {
                        int heartRate = 0;
                        if (data.length >= 2) {
                          heartRate = data[0] | (data[1] << 8);
                          print(
                            "Parsed heart rate (data[0] | (data[1] << 8)): $heartRate",
                          );
                        } else if (data.length == 1) {
                          heartRate = data[0];
                          print("Parsed heart rate (data[0]): $heartRate");
                        }
                        if (heartRate >= 60 && heartRate <= 100) {
                          onHeartRateUpdate(heartRate.toString());
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(docId)
                              .collection('health_info')
                              .doc('data')
                              .set({
                                'heartRate': heartRate.toString(),
                                'lastUpdated': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true))
                              .then(
                                (_) => print(
                                  "Firestore updated with heart rate: $heartRate",
                                ),
                              )
                              .catchError(
                                (e) => print("Error updating Firestore: $e"),
                              );
                          print("Valid heart rate: $heartRate");
                        } else {
                          print(
                            "Invalid heart rate: $heartRate (out of range)",
                          );
                        }
                      } else {
                        print("Empty heart rate data received");
                      }
                    },
                    onError: (e) {
                      print("Characteristic error: $e");
                    },
                  );
                  _showMessage(context, "Connected to NanoHRM", onMessage);
                  onFetchingStateChange(false);
                  return;
                }
              }
            }
          }
        }
      }
      print("Heart rate service not found");
      _isConnected = false;
      _showMessage(
        context,
        "Heart rate service not found on NanoHRM",
        onMessage,
      );
      onFetchingStateChange(false);
    } catch (e) {
      print("Error setting up heart rate subscription: $e");
      _showMessage(context, "Failed to setup heart rate monitoring", onMessage);
      _isConnected = false;
      onFetchingStateChange(false);
    }
  }

  void _showMessage(
    BuildContext? context,
    String message,
    Function(String) onMessage,
  ) {
    if (_lastMessage != message) {
      onMessage(message);
      print("Bluetooth message: $message");
      _lastMessage = message;
      if (message == "Connected to NanoHRM") {
        _lastMessage = null;
      }
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _scanTimer?.cancel();
    _scanTimer = null;
    _isConnected = false;
    _isScanning = false;
    _isConnecting = false;
    _lastMessage = null;
    print("BluetoothManager disposed");
  }
}
