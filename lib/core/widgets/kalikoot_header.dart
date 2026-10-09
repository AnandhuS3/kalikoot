import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable top navigation header for KaliKoot.
class KaliKootHeader extends StatelessWidget {
  final String? title;
  final bool showBack;
  final bool showSettings;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final Widget? customTrailing;

  const KaliKootHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.showSettings = true,
    this.onBack,
    this.onSettings,
    this.customTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (showBack) ...[
              _buildCircularButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack ?? () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: title != null
                  ? Text(
                      title!,
                      style: AppTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : _buildBrandLogo(),
            ),
            if (customTrailing != null)
              customTrailing!
            else if (showSettings)
              _buildCircularButton(
                icon: Icons.settings_rounded,
                onTap: onSettings ??
                    () {
                      FeedbackService().playTap();
                      Navigator.of(context).pushNamed('/settings');
                    },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        FeedbackService().playTap();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryNavy, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryNavy,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 24),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colorful stylized title
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'KALI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.coral,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'KOOT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Geometric Kerala playful emblem
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryNavy, width: 2),
              ),
              child: const Text(
                '★',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'Small Games. Big Rivalries.',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}
