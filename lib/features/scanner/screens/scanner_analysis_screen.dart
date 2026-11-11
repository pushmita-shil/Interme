import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/scanner_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScannerAnalysisScreen extends GetView<ScannerController> {
  const ScannerAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.isAnalyzing.value,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // If analysis is in progress, cancel and return
          controller.cancelAnalysisAndReturn();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Obx(() => controller.isAnalyzing.value
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  tooltip: 'Cancel',
                  onPressed: () => controller.cancelAnalysisAndReturn(),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.onSurface),
                  onPressed: () => controller.cancelAnalysisAndReturn(),
                )),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Obx(() {
                if (controller.analysisError.value.isNotEmpty) {
                  return _buildErrorState();
                }
                return _buildAnalysisProgressState();
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisProgressState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Security radar / scanning animation avatar
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: controller.analysisProgress.value,
                  strokeWidth: 3.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              const Icon(
                Icons.center_focus_strong,
                color: AppColors.primary,
                size: 42,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          'Scanning Internship',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),

        // Dynamic stage message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            controller.currentStageMessage.value.isNotEmpty
                ? controller.currentStageMessage.value
                : 'Evaluating offer details...',
            key: ValueKey(controller.currentStageMessage.value),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Progress Linear Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 6,
            width: 220,
            child: LinearProgressIndicator(
              value: controller.analysisProgress.value,
              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Workflow Stage Indicators Checklist
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              _buildProgressStep(
                title: 'Reading internship information',
                isActive: controller.analysisProgress.value >= 0.1,
                isDone: controller.analysisProgress.value >= 0.35,
              ),
              const Divider(height: 16),
              _buildProgressStep(
                title: 'Checking for suspicious payment requests',
                isActive: controller.analysisProgress.value >= 0.35,
                isDone: controller.analysisProgress.value >= 0.65,
              ),
              const Divider(height: 16),
              _buildProgressStep(
                title: 'Reviewing company and contact details',
                isActive: controller.analysisProgress.value >= 0.65,
                isDone: controller.analysisProgress.value >= 0.90,
              ),
              const Divider(height: 16),
              _buildProgressStep(
                title: 'Preparing your risk report',
                isActive: controller.analysisProgress.value >= 0.90,
                isDone: controller.analysisProgress.value >= 1.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Disclaimer
        Text(
          'Preliminary automated heuristic analysis. Does not perform legal background verification.',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.outline,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    final Color iconColor;
    final IconData iconData;

    if (isDone) {
      iconColor = AppColors.secondary;
      iconData = Icons.check_circle_rounded;
    } else if (isActive) {
      iconColor = AppColors.primary;
      iconData = Icons.radio_button_checked;
    } else {
      iconColor = AppColors.outlineVariant;
      iconData = Icons.radio_button_unchecked;
    }

    return Row(
      children: [
        Icon(iconData, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.onSurface : AppColors.outline,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFFFDAD6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded, color: Color(0xFFBA1A1A), size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'Analysis Failed',
          style: AppTextStyles.headlineMd.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.analysisError.value,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.cancelAnalysisAndReturn(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => controller.retryAnalysis(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry Analysis'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
