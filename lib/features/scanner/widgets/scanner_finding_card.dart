import 'package:flutter/material.dart';
import '../models/scanner_finding_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScannerFindingCard extends StatelessWidget {
  final ScannerFindingModel finding;

  const ScannerFindingCard({super.key, required this.finding});

  @override
  Widget build(BuildContext context) {
    final themeColor = finding.color;
    final containerColor = finding.containerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Severity Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(finding.icon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        finding.typeLabel.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Plain Language Explanation
          Text(
            finding.explanation,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),

          // Extracted Evidence Snippet (if available)
          if (finding.evidence != null && finding.evidence!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: themeColor, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUPPORTING EVIDENCE',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${finding.evidence!.trim()}"',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Suggested Action
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Suggested Action: ',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: finding.suggestedAction,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
