import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    // Initialize storage service during splash
    await StorageService().init();

    const totalSteps = 40;
    int currentStep = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      currentStep++;
      setState(() {
        _progress = (currentStep / totalSteps).clamp(0.0, 1.0);
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Stylized Logo (Matching Reference Screenshot media_1791567357502.png)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Playful 4-color top indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLetter('K', AppColors.coral),
                      _buildLetter('A', AppColors.cyan),
                      _buildLetter('L', AppColors.green),
                      _buildLetter('I', AppColors.yellow),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Bold navy Title
                  const Text(
                    'KALIKOOT',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryNavy,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 4-Color Underline Bar
                  SizedBox(
                    width: 220,
                    height: 5,
                    child: Row(
                      children: [
                        Expanded(child: Container(color: AppColors.coral)),
                        Expanded(child: Container(color: AppColors.cyan)),
                        Expanded(child: Container(color: AppColors.green)),
                        Expanded(child: Container(color: AppColors.yellow)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Small Games. Big Rivalries.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 4),

            // Minimal Pill Progress Bar with percentage (matching reference)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryNavy, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _progress > 0.5 ? AppColors.white : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLetter(String letter, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
