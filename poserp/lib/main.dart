import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service/
  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);
  final storage = Get.find<StorageService>();

  final token = storage.getToken();
  log(token.toString());

  runApp(const PosErpApp());
}
