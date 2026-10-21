import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/scanner_controller.dart';
import '../widgets/scanner_input_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';

class AiScannerScreen extends GetView<ScannerController> {
  const AiScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'AI Internship Scanner',
          style: AppTextStyles.headlineMd.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.onSurfaceVariant),
            tooltip: 'Scan History',
            onPressed: () => _showHistorySheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Security Header Card
              _buildHeaderHero(),
              const SizedBox(height: 20),

              // Scanner Input Card
              ScannerInputCard(controller: controller),
              const SizedBox(height: 24),

              // Educational "How it Works" Bento Card
              _buildEducationalCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Internship Scanner',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check an internship for suspicious signs before you apply.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'How the Scanner Evaluates Risk',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPillarItem(
            icon: Icons.payments_outlined,
            title: 'Payment Demands',
            subtitle: 'Detects registration, training, or deposit fee requests from applicants.',
          ),
          const SizedBox(height: 10),
          _buildPillarItem(
            icon: Icons.business_outlined,
            title: 'Identity Verification',
            subtitle: 'Checks for vague company descriptions and non-corporate email domains.',
          ),
          const SizedBox(height: 10),
          _buildPillarItem(
            icon: Icons.timer_outlined,
            title: 'Pressure Tactics',
            subtitle: 'Identifies manufactured urgency and guaranteed selection claims.',
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHistorySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Scans',
                  style: AppTextStyles.headlineMd.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.scanHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 48, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No scans recorded in this session',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.scanHistory.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = controller.scanHistory[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: report.statusBackgroundColor,
                        child: Icon(report.statusIcon, color: report.statusColor, size: 20),
                      ),
                      title: Text(
                        report.categoryDisplayTitle,
                        style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${report.submissionType.name.toUpperCase()} • ${report.findings.length} findings',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Get.back();
                        controller.currentReport.value = report;
                        Get.toNamed(
                          '/scanner-report',
                          arguments: report,
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
