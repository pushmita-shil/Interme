import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/scanner_controller.dart';
import '../models/scanner_report_model.dart';
import '../widgets/scanner_risk_summary_card.dart';
import '../widgets/scanner_finding_card.dart';
import '../widgets/scanner_action_steps.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';

class ScannerReportScreen extends GetView<ScannerController> {
  const ScannerReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve report from Get.arguments or fallback to controller.currentReport
    final ScannerReportModel? passedReport = Get.arguments as ScannerReportModel?;
    final report = passedReport ?? controller.currentReport.value;

    if (report == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Internship Risk Report')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined, size: 54, color: AppColors.outline),
              const SizedBox(height: 16),
              const Text('No scan report found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.scanAnotherInternship(),
                child: const Text('Start New Scan'),
              ),
            ],
          ),
        ),
      );
    }

    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(report.createdAt);

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
          'Internship Risk Report',
          style: AppTextStyles.headlineMd.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant),
            tooltip: 'Copy Summary',
            onPressed: () => _copySummaryToClipboard(report),
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
              // Report Header Meta
              _buildReportHeaderMeta(formattedDate),
              const SizedBox(height: 16),

              // Risk Summary Bento Card
              ScannerRiskSummaryCard(report: report),
              const SizedBox(height: 24),

              // Findings Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Findings',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${report.findings.length} observed',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Individual Finding Cards
              if (report.findings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'No specific warning signs or indicators were detected.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                    ),
                  ),
                )
              else
                ...report.findings.map((f) => ScannerFindingCard(finding: f)),

              const SizedBox(height: 20),

              // Recommended Next Steps Section
              ScannerActionSteps(steps: report.recommendedNextSteps),
              const SizedBox(height: 28),

              // Primary Functional Actions
              _buildReportActions(context, report),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeaderMeta(String formattedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.outline),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
              ),
            ],
          ),
          Text(
            'Heuristic v1.0',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportActions(BuildContext context, ScannerReportModel report) {
    return Column(
      children: [
        // Action 1: Save Report
        Obx(() {
          final isSaved = controller.isReportSaved.value;
          final isSaving = controller.isSavingReport.value;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved ? AppColors.secondary : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isSaving ? null : () => controller.saveCurrentReport(),
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(isSaved ? Icons.bookmark_added : Icons.bookmark_border),
              label: Text(
                isSaved ? 'Report Saved' : 'Save Report to History',
                style: AppTextStyles.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Action 2: Report Suspicious Opportunity (if warning flags present)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFBA1A1A),
              side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => controller.reportSuspiciousOpportunity(context),
            icon: const Icon(Icons.report_problem_outlined, size: 18),
            label: Text(
              'Report Suspicious Opportunity',
              style: AppTextStyles.labelMd.copyWith(
                color: const Color(0xFFBA1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Action 3: Scan Another Internship
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => controller.scanAnotherInternship(),
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              'Scan Another Internship',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _copySummaryToClipboard(ScannerReportModel report) {
    final buffer = StringBuffer();
    buffer.writeln('=== InternVerify Internship Risk Report ===');
    buffer.writeln('Category: ${report.categoryDisplayTitle}');
    buffer.writeln('Headline: ${report.assessmentHeadline}');
    buffer.writeln('Explanation: ${report.overallExplanation}');
    buffer.writeln('\nFindings:');
    for (final f in report.findings) {
      buffer.writeln('- [${f.typeLabel}] ${f.title}: ${f.explanation}');
      if (f.evidence != null) buffer.writeln('  Evidence: "${f.evidence}"');
    }
    buffer.writeln('\nRecommended Next Steps:');
    for (int i = 0; i < report.recommendedNextSteps.length; i++) {
      buffer.writeln('${i + 1}. ${report.recommendedNextSteps[i]}');
    }
    buffer.writeln('\nGenerated via InternVerify AI Internship Scanner');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar(
      'Copied to Clipboard',
      'The internship risk assessment summary has been copied.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
