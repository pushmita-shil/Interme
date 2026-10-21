import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScannerActionSteps extends StatelessWidget {
  final List<String> steps;

  const ScannerActionSteps({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.checklist_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              'Recommended Next Steps',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final step = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
