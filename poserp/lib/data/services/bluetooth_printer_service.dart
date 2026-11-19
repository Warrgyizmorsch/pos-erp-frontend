import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../core/utils/app_snackbar.dart';
import 'thermal_receipt_generator.dart';

class BluetoothPrinterService extends GetxService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  late final GetStorage _box;

  static const String keyPrinterMac = 'bt_printer_mac';
  static const String keyPrinterName = 'bt_printer_name';
  static const String keyPaperSize = 'bt_paper_size';

  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool isPrinting = false.obs;
  final RxBool isBluetoothOn = false.obs;

  final RxString connectedPrinterName = ''.obs;
  final RxString connectedPrinterMac = ''.obs;
  final RxString paperSize = '80mm'.obs; // '80mm' or '58mm'

  final RxList<BluetoothInfo> availableDevices = <BluetoothInfo>[].obs;

  Future<BluetoothPrinterService> init() async {
    _box = GetStorage();

    // Load saved preferences
    final savedMac = _box.read<String>(keyPrinterMac);
    final savedName = _box.read<String>(keyPrinterName);
    final savedSize = _box.read<String>(keyPaperSize);

    if (savedSize != null && (savedSize == '80mm' || savedSize == '58mm')) {
      paperSize.value = savedSize;
    }

    if (savedMac != null && savedMac.isNotEmpty) {
      connectedPrinterMac.value = savedMac;
      connectedPrinterName.value = savedName ?? 'Saved Printer';
    }

    await checkBluetoothState();

    // Check if still connected on startup
    if (_isSupportedPlatform()) {
      try {
        final currentStatus = await PrintBluetoothThermal.connectionStatus;
        isConnected.value = currentStatus;
      } catch (e) {
        _logger.w('Initial connection status check failed: $e');
      }
    }

    return this;
  }

  bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS;
  }

  /// Check whether Bluetooth is powered on
  Future<bool> checkBluetoothState() async {
    if (!_isSupportedPlatform()) {
      isBluetoothOn.value = false;
      return false;
    }
    try {
      final on = await PrintBluetoothThermal.bluetoothEnabled;
      isBluetoothOn.value = on;
      return on;
    } catch (e) {
      _logger.e('Failed to check bluetooth state: $e');
      isBluetoothOn.value = false;
      return false;
    }
  }

  /// Request runtime permissions on Android
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      try {
        // Request modern Bluetooth permissions (Android 12+)
        final statuses = await [
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.locationWhenInUse,
        ].request();

        final connectGranted =
            statuses[Permission.bluetoothConnect]?.isGranted ?? false;
        final scanGranted =
            statuses[Permission.bluetoothScan]?.isGranted ?? false;
        final locationGranted =
            statuses[Permission.locationWhenInUse]?.isGranted ?? false;

        // If Android 12+, connect & scan are needed. If older, location is needed.
        final pluginPermission =
            await PrintBluetoothThermal.isPermissionBluetoothGranted;

        return pluginPermission ||
            (connectGranted && scanGranted) ||
            locationGranted;
      } catch (e) {
        _logger.e('Error requesting bluetooth permissions: $e');
        return false;
      }
    } else if (Platform.isIOS) {
      try {
        final status = await Permission.bluetooth.request();
        return status.isGranted;
      } catch (e) {
        _logger.e('Error requesting iOS bluetooth permission: $e');
        return false;
      }
    }

    return true;
  }

  /// Scan for paired / nearby Bluetooth devices
  Future<void> scanDevices() async {
    if (!_isSupportedPlatform()) {
      AppSnackbar.warning(
        'Bluetooth printing is only supported on Android, iOS, and Windows.',
        title: 'Platform Unsupported',
      );
      return;
    }

    try {
      isScanning.value = true;

      final permGranted = await requestPermissions();
      if (!permGranted) {
        AppSnackbar.warning(
          'Bluetooth permissions are required to search for thermal printers.',
          title: 'Permission Denied',
        );
        return;
      }

      final btEnabled = await checkBluetoothState();
      if (!btEnabled) {
        AppSnackbar.warning(
          'Please turn ON Bluetooth on your device to search for printers.',
          title: 'Bluetooth Off',
        );
        return;
      }

      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;
      availableDevices.assignAll(devices);

      // Also check real-time connection status
      final isConn = await PrintBluetoothThermal.connectionStatus;
      isConnected.value = isConn;

      if (devices.isEmpty) {
        AppSnackbar.info(
          'No paired Bluetooth printers found. Please pair your Posiflow / thermal printer in your device Settings first.',
          title: 'No Printers Found',
        );
      }
    } catch (e) {
      _logger.e('Failed scanning bluetooth devices: $e');
      AppSnackbar.error('Error scanning devices: $e', title: 'Bluetooth Error');
    } finally {
      isScanning.value = false;
    }
  }

  /// Connect to a specific thermal printer by MAC address
  Future<bool> connect(String macAddress, {String? name}) async {
    if (!_isSupportedPlatform()) return false;

    try {
      isConnecting.value = true;

      final permGranted = await requestPermissions();
      if (!permGranted) {
        AppSnackbar.warning(
          'Bluetooth permissions required to connect to printer.',
          title: 'Permission Denied',
        );
        return false;
      }

      final btEnabled = await checkBluetoothState();
      if (!btEnabled) {
        AppSnackbar.warning(
          'Please turn ON Bluetooth before connecting.',
          title: 'Bluetooth Off',
        );
        return false;
      }

      // If already connected to another MAC, disconnect first
      if (isConnected.value && connectedPrinterMac.value != macAddress) {
        await disconnect(silent: true);
      }

      _logger.i('Connecting to thermal printer: $macAddress ($name)...');
      final bool status = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );

      if (status) {
        isConnected.value = true;
        connectedPrinterMac.value = macAddress;
        connectedPrinterName.value = name ?? 'Thermal Printer';

        // Persist default printer
        await _box.write(keyPrinterMac, macAddress);
        if (name != null) {
          await _box.write(keyPrinterName, name);
        }

        AppSnackbar.success(
          'Connected to ${connectedPrinterName.value}',
          title: 'Printer Connected',
        );
        return true;
      } else {
        isConnected.value = false;
        AppSnackbar.error(
          'Could not connect to $name ($macAddress). Please ensure printer is powered ON and in range.',
          title: 'Connection Failed',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Exception connecting to printer: $e');
      isConnected.value = false;
      AppSnackbar.error('Error connecting to printer: $e',
          title: 'Printer Error');
      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  /// Disconnect from the current printer
  Future<void> disconnect({bool silent = false}) async {
    if (!_isSupportedPlatform()) return;

    try {
      await PrintBluetoothThermal.disconnect;
      isConnected.value = false;
      if (!silent) {
        AppSnackbar.info('Printer disconnected.', title: 'Bluetooth');
      }
    } catch (e) {
      _logger.e('Failed to disconnect: $e');
    }
  }

  /// Forget the saved printer
  Future<void> forgetSavedPrinter() async {
    await disconnect(silent: true);
    await _box.remove(keyPrinterMac);
    await _box.remove(keyPrinterName);
    connectedPrinterMac.value = '';
    connectedPrinterName.value = '';
    AppSnackbar.info('Saved printer removed.', title: 'Printer Settings');
  }

  /// Set paper size ('80mm' or '58mm')
  Future<void> setPaperSize(String size) async {
    if (size == '80mm' || size == '58mm') {
      paperSize.value = size;
      await _box.write(keyPaperSize, size);
    }
  }

  /// Ensure we have an active connection to the printer
  Future<bool> ensureConnected() async {
    if (!_isSupportedPlatform()) return false;

    try {
      final currentStatus = await PrintBluetoothThermal.connectionStatus;
      if (currentStatus) {
        isConnected.value = true;
        return true;
      }

      // If disconnected but we have a saved printer MAC, attempt auto-reconnect
      final savedMac = connectedPrinterMac.value.isNotEmpty
          ? connectedPrinterMac.value
          : _box.read<String>(keyPrinterMac);

      if (savedMac != null && savedMac.isNotEmpty) {
        _logger.i('Attempting auto-reconnect to saved printer: $savedMac...');
        final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: savedMac,
        );
        isConnected.value = connected;
        return connected;
      }
    } catch (e) {
      _logger.e('ensureConnected check failed: $e');
    }

    isConnected.value = false;
    return false;
  }

  /// Send raw bytes to printer
  Future<bool> writeBytes(List<int> bytes) async {
    if (!_isSupportedPlatform()) {
      AppSnackbar.warning(
        'Bluetooth printing is not supported on this platform.',
        title: 'Platform Unsupported',
      );
      return false;
    }

    try {
      isPrinting.value = true;

      final ready = await ensureConnected();
      if (!ready) {
        AppSnackbar.warning(
          'No Bluetooth printer connected. Please connect your Posiflow printer first.',
          title: 'Printer Not Connected',
        );
        return false;
      }

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      _logger.e('Error writing bytes to printer: $e');
      AppSnackbar.error('Print failed: $e', title: 'Print Error');
      return false;
    } finally {
      isPrinting.value = false;
    }
  }

  /// Print a formatted POS receipt over Bluetooth
  Future<bool> printReceipt(
    Map<String, dynamic> saleData, {
    String? customPaperSize,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
    String? businessGstin,
  }) async {
    final size = customPaperSize ?? paperSize.value;

    try {
      isPrinting.value = true;

      final ready = await ensureConnected();
      if (!ready) {
        AppSnackbar.warning(
          'No Bluetooth printer connected. Please connect your printer first.',
          title: 'Printer Not Connected',
        );
        return false;
      }

      final bytes = await ThermalReceiptGenerator.generateReceipt(
        saleData,
        paperSize: size,
        businessName: businessName ?? 'POS ERP RETAIL',
        businessAddress: businessAddress,
        businessPhone: businessPhone,
        businessGstin: businessGstin,
      );

      final success = await PrintBluetoothThermal.writeBytes(bytes);
      if (success) {
        AppSnackbar.success(
          'Receipt sent to ${connectedPrinterName.value} successfully.',
          title: 'Print Successful',
        );
        return true;
      } else {
        AppSnackbar.error(
          'Failed to transmit print job to printer.',
          title: 'Print Failed',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Failed printing receipt: $e');
      AppSnackbar.error('Receipt print failed: $e', title: 'Print Error');
      return false;
    } finally {
      isPrinting.value = false;
    }
  }

  /// Print a test slip to verify connection and paper alignment
  Future<bool> printTestReceipt() async {
    try {
      isPrinting.value = true;

      final ready = await ensureConnected();
      if (!ready) {
        AppSnackbar.warning(
          'Printer is not connected. Please connect first.',
          title: 'Printer Offline',
        );
        return false;
      }

      final bytes = await ThermalReceiptGenerator.generateTestReceipt(
        paperSize: paperSize.value,
        printerName: connectedPrinterName.value.isNotEmpty
            ? connectedPrinterName.value
            : 'Posiflow Thermal Printer',
        macAddress: connectedPrinterMac.value,
      );

      final success = await PrintBluetoothThermal.writeBytes(bytes);
      if (success) {
        AppSnackbar.success(
          'Test print sent to ${connectedPrinterName.value} successfully.',
          title: 'Test Print Sent',
        );
        return true;
      } else {
        AppSnackbar.error(
          'Test print transmission failed.',
          title: 'Test Print Failed',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Failed to send test print: $e');
      AppSnackbar.error('Test print failed: $e', title: 'Print Error');
      return false;
    } finally {
      isPrinting.value = false;
    }
  }
}
