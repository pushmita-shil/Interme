import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../controllers/student_controller.dart';
import '../../../data/models/application_model.dart';
import '../../../services/firebase/firestore_service.dart';

class ApplicationTrackerScreen extends GetView<StudentController> {
  const ApplicationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application Tracker',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submitted Applications',
                style: AppTextStyles.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track the verification and review process in real-time.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: Obx(() {
                  if (controller.studentApplications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active applications yet.',
                            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Search and apply for internships in the marketplace.',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.studentApplications.length,
                    itemBuilder: (context, index) {
                      final app = controller.studentApplications[index];
                      return _buildTrackerCard(app);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard(ApplicationModel application) {
    final firestore = Get.find<FirestoreService>();
    // Fetch internship details
    final internship = firestore.internships.firstWhereOrNull((i) => i.id == application.internshipId);

    if (internship == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    internship.title,
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${internship.companyName} • ${internship.location}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  application.status,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.outlineVariant),
          
          // Timeline Steps
          Text(
            'Verification Pipeline',
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineStep(
            title: 'Application Submitted',
            subtitle: 'Sent to ${internship.companyName} recruitment portal.',
            date: 'Applied',
            isDone: true,
            isCurrent: false,
          ),
          _buildTimelineStep(
            title: 'AI Trust Score Vetted',
            subtitle: 'Verified compliant with trust rating of ${internship.trustScore.toInt()}%.',
            date: 'Approved',
            isDone: true,
            isCurrent: true,
          ),
          _buildTimelineStep(
            title: 'HR Review & Interviewing',
            subtitle: 'Waiting for representative contact.',
            date: 'Pending',
            isDone: false,
            isCurrent: false,
          ),
          _buildTimelineStep(
            title: 'Offer Letter Release',
            subtitle: 'Secure signature contract verified.',
            date: 'Locked',
            isDone: false,
            isCurrent: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String date,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic node column
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.secondary : Colors.white,
                  border: Border.all(
                    color: isDone
                        ? AppColors.secondary
                        : (isCurrent ? AppColors.primary : AppColors.outlineVariant),
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    width: 2,
                    thickness: 1.5,
                    color: isDone ? AppColors.secondary : AppColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isDone ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      fontWeight: (isDone || isCurrent) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Date right indicator
          Text(
            date,
            style: AppTextStyles.labelSm.copyWith(
              color: isDone ? AppColors.secondary : AppColors.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
