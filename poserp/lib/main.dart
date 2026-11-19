import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'data/services/bluetooth_printer_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);

  // Initialize Bluetooth Printer Service
  final bluetoothPrinterService = BluetoothPrinterService();
  await bluetoothPrinterService.init();
  Get.put<BluetoothPrinterService>(bluetoothPrinterService, permanent: true);

  runApp(const PosErpApp());
}
