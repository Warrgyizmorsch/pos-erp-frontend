import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_config.dart';
import '../core/theme/app_theme.dart';
import '../modules/authentication/controllers/auth_controller.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class PosErpApp extends StatelessWidget {
  const PosErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
      home: const AppInitializerScreen(),
    );
  }
}

class AppInitializerScreen extends GetView<AuthController> {
  const AppInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isInitializing.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.dashboard);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.login);
        });
      }

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}
