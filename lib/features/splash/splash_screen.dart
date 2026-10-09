import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startLoading();
  }

  void _startLoading() async {
    await StorageService().init();

    const totalSteps = 40;
    int currentStep = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
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
    _pulseController.dispose();
    super.dispose();
  }

  String _getLoadingMessage(double progress) {
    if (progress < 0.28) {
      return 'Hanging festival pots...';
    } else if (progress < 0.58) {
      return 'Polishing glass marbles...';
    } else if (progress < 0.88) {
      return 'Gathering Kalari masters...';
    } else {
      return 'Welcome to KaliKoot!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Animated KaliKoot Hero Logo Artwork
              ScaleTransition(
                scale: _pulseAnimation,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320, maxHeight: 260),
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/image.png',
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline in rounded Fredoka typography
              const Text(
                'Small Games. Big Rivalries.',
                style: TextStyle(
                  fontFamily: AppTypography.fontBody,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 4),

              // Loading Status Message
              Text(
                _getLoadingMessage(_progress),
                style: const TextStyle(
                  fontFamily: AppTypography.fontBody,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Redesigned Chunky Arcade Loading Bar
              Container(
                width: 240,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryNavy, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryNavy,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Dynamic Colorful Fill Capsule
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.yellow,
                              AppColors.coral,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Centered percentage readout in LilitaOne arcade font
                    Center(
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontTitle,
                          fontSize: 13,
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
