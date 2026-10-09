import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A playful button with thick confident outlines and tactile press depth.
class ChunkyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final double borderWidth;
  final TextStyle? textStyle;

  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.yellow,
    this.textColor = AppColors.white,
    this.borderColor = AppColors.primaryNavy,
    this.icon,
    this.height = 56,
    this.width,
    this.borderRadius = 28,
    this.borderWidth = 3,
    this.textStyle,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final effectiveBg = enabled ? widget.backgroundColor : AppColors.trackInactive;
    final depth = _isPressed || !enabled ? 0.0 : 4.0;

    return GestureDetector(
      onTapDown: enabled
          ? (_) {
              setState(() => _isPressed = true);
              FeedbackService().playTap();
            }
          : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
            }
          : null,
      onTapCancel: enabled
          ? () {
              setState(() => _isPressed = false);
            }
          : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? depth : 0, bottom: _isPressed ? 0 : depth),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: depth > 0
              ? [
                  BoxShadow(
                    color: widget.borderColor,
                    offset: Offset(0, depth),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.textColor, size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: widget.textStyle ??
                  AppTypography.buttonLarge.copyWith(color: widget.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
