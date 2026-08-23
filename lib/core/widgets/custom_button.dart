import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;
  final bool isAlert;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
    this.isAlert = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: isOutline
          ? Colors.transparent
          : (isAlert ? AppColors.tertiary : AppColors.primary),
      foregroundColor: isOutline
          ? (isAlert ? AppColors.tertiary : AppColors.primary)
          : AppColors.onPrimary,
      side: isOutline
          ? BorderSide(color: isAlert ? AppColors.tertiary : AppColors.primary, width: 1.5)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      elevation: isOutline ? 0 : 2,
    );

    Widget childContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutline ? AppColors.primary : AppColors.onPrimary,
              ),
            ),
          )
        else
          Text(
            text,
            style: AppTextStyles.labelMd.copyWith(
              color: isOutline
                  ? (isAlert ? AppColors.tertiary : AppColors.primary)
                  : AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: childContent,
      ),
    );
  }
}
