import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_sizes.dart';

class AuthLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool isRegister;

  const AuthLayoutWrapper({
    super.key,
    required this.child,
    this.isRegister = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= AppSizes.desktopBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mobile Top App Branding Tile
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: AppRadius.lg,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.info],
                      ).createShader(bounds),
                      child: const Text(
                        'POS ERP',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Next-Gen Point of Sale & ERP Engine',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 28),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Tablet/Desktop Dual Column Split View
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Branding Side Panel
          Positioned(
            left: isRegister ? null : 0,
            right: isRegister ? 0 : null,
            top: 0,
            bottom: 0,
            width: mediaQuery.size.width * 0.5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryHover,
                    AppColors.info,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'POS ERP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    text: const TextSpan(
                      text: 'Mobile-First Point of Sale\n',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: 'for retail & distribution',
                          style: TextStyle(color: AppColors.primarySoftLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Streamline sales, manage multi-channel stock, monitor financial ledgers, and automate tax compliance.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withAlpha(220),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _buildFeatureBadge('POS Terminal'),
                      const SizedBox(width: 10),
                      _buildFeatureBadge('Double-Entry'),
                      const SizedBox(width: 10),
                      _buildFeatureBadge('GST Reports'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Auth Form Side Panel
          Positioned(
            left: isRegister ? 0 : mediaQuery.size.width * 0.5,
            right: isRegister ? mediaQuery.size.width * 0.5 : 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: AppRadius.md,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
