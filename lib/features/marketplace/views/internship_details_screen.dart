import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/internship_details_controller.dart';
import '../controllers/marketplace_controller.dart';

class InternshipDetailsScreen extends StatelessWidget {
  const InternshipDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller with tag or standard
    final controller = Get.put(InternshipDetailsController());
    final internship = controller.internship;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          internship.companyName,
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Bookmark save action
          if (Get.isRegistered<MarketplaceController>())
            Obx(() {
              final isSaved = controller.isSaved;
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColors.primary : AppColors.onSurface,
                ),
                onPressed: () => controller.toggleSave(),
              );
            }),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. Header Card
              _buildHeaderCard(internship),
              const SizedBox(height: 20),

              // Expiration Warning Banner if closing soon or expired
              if (internship.isExpired)
                _buildAlertBanner(
                  icon: Icons.error_outline,
                  color: AppColors.error,
                  bgColor: AppColors.errorContainer.withOpacity(0.3),
                  title: 'Applications Closed',
                  message:
                      'The deadline for this opportunity was ${DateFormat.yMMMd().format(internship.deadline)}.',
                )
              else if (internship.isClosingSoon)
                _buildAlertBanner(
                  icon: Icons.timer_outlined,
                  color: Colors.amber.shade900,
                  bgColor: Colors.amber.shade50,
                  title: 'Application Deadline Closing Soon',
                  message:
                      'Applications close in ${internship.daysRemaining} days (${DateFormat.yMMMd().format(internship.deadline)}).',
                ),

              if (internship.isExpired || internship.isClosingSoon)
                const SizedBox(height: 20),

              // B. About the Company
              _buildCompanySection(controller),
              const SizedBox(height: 20),

              // C. Internship Description
              _buildSectionCard(
                title: 'Internship Overview',
                icon: Icons.description_outlined,
                child: Text(
                  internship.description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // D. Key Responsibilities
              if (internship.responsibilities.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Key Responsibilities',
                  icon: Icons.assignment_outlined,
                  child: Column(
                    children: internship.responsibilities.map((resp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6, right: 10),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                resp,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // E. Required Skills
              if (internship.skills.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Required Skills & Tech Stack',
                  icon: Icons.code,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: internship.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.12),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // F. Eligibility Criteria
              if (internship.eligibility.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Eligibility Criteria',
                  icon: Icons.school_outlined,
                  child: Column(
                    children: internship.eligibility.map((crit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                crit,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // G. Stipend and Benefits
              _buildSectionCard(
                title: 'Stipend & Perks',
                icon: Icons.card_giftcard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                internship.stipend > 0
                                    ? '₹${internship.stipend.toInt()} / month'
                                    : 'Unpaid Opportunity',
                                style: AppTextStyles.headlineMd.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                internship.stipendType == 'Paid'
                                    ? 'Monthly guaranteed direct bank transfer'
                                    : 'Academic & experiential training',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (internship.benefits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...internship.benefits.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // H. Application Process
              _buildSectionCard(
                title: 'Application Process',
                icon: Icons.timeline,
                child: Text(
                  internship.applicationType == 'external'
                      ? 'This company accepts applications through their verified career portal. Tapping "Apply Now" will redirect you to the official form without third-party commission or charges.'
                      : 'Submit your profile directly through Interme. Your verified academic details and project links are securely transmitted to the employer\'s talent acquisition team.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // I. Trust & Verification Breakdown
              _buildTrustVerificationSection(controller),
              const SizedBox(height: 20),

              // J. Student Reviews Section
              _buildReviewsSection(),
              const SizedBox(height: 90), // Bottom bar padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(controller),
    );
  }

  Widget _buildHeaderCard(dynamic internship) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceContainerLow,
                  child: internship.logoUrl.isNotEmpty
                      ? Image.network(
                          internship.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackLogo(internship.companyName),
                        )
                      : _buildFallbackLogo(internship.companyName),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            internship.companyName,
                            style: AppTextStyles.headlineMd.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (internship.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${internship.location} • ${internship.workMode}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            internship.title,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          const SizedBox(height: 14),

          // Details Grid Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                label: 'Monthly Stipend',
                value: internship.stipend > 0
                    ? '₹${internship.stipend.toInt()}'
                    : 'Unpaid',
                icon: Icons.payments_outlined,
              ),
              _buildDetailItem(
                label: 'Duration',
                value: internship.duration,
                icon: Icons.calendar_today_outlined,
              ),
              _buildDetailItem(
                label: 'Deadline',
                value: DateFormat('dd MMM yyyy').format(internship.deadline),
                icon: Icons.timer_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySection(InternshipDetailsController controller) {
    return Obx(() {
      if (controller.isLoadingCompany.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final comp = controller.company.value;
      if (comp == null) {
        return const SizedBox.shrink();
      }

      return _buildSectionCard(
        title: 'About ${comp.companyName}',
        icon: Icons.business,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comp.description.isNotEmpty
                  ? comp.description
                  : 'Organization details verified on Interme.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _buildInfoNode(label: 'Industry', value: comp.industry),
                _buildInfoNode(label: 'Headquarters', value: comp.headquarters),
                _buildInfoNode(label: 'Company Size', value: comp.companySize),
              ],
            ),
            if (comp.website.isNotEmpty) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(comp.website);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      comp.website,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTrustVerificationSection(
    InternshipDetailsController controller,
  ) {
    return Obx(() {
      final eval = controller.trustEvaluation.value;
      if (eval == null) return const SizedBox.shrink();

      final isVerified = eval.isVerified;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isVerified
              ? AppColors.secondaryContainer.withOpacity(0.12)
              : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isVerified
                ? AppColors.secondary.withOpacity(0.4)
                : Colors.amber.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVerified ? Icons.verified_user : Icons.gpp_maybe,
                  color: isVerified
                      ? AppColors.secondary
                      : Colors.amber.shade900,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVerified
                            ? 'Interme Trust Vetted'
                            : 'Unverified Listing Warning',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isVerified
                              ? AppColors.secondary
                              : Colors.amber.shade900,
                        ),
                      ),
                      Text(
                        eval.statusSummary,
                        style: AppTextStyles.labelSm.copyWith(
                          color: isVerified
                              ? AppColors.onSecondaryContainer
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...eval.evidenceItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.isPassed
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: item.isPassed
                          ? AppColors.secondary
                          : Colors.amber.shade900,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            item.description,
                            style: AppTextStyles.bodySm.copyWith(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Text(
              eval.disclaimer,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReviewsSection() {
    return _buildSectionCard(
      title: 'Student Community Reviews',
      icon: Icons.rate_review_outlined,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                Icons.reviews_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                'No student reviews submitted yet.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reviews are posted exclusively by verified interns who complete their tenures through Interme.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoNode({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.outline,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAlertBanner({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: color.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(String companyName) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Text(
          companyName.isNotEmpty ? companyName[0].toUpperCase() : 'I',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(InternshipDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bookmark save button
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Obx(() {
                final isSaved = controller.isSaved;
                return Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColors.primary : AppColors.onSurface,
                );
              }),
              onPressed: () => controller.toggleSave(),
            ),
          ),
          const SizedBox(width: 12),

          // Apply Now Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: Obx(() {
                final hasApplied = controller.hasAlreadyApplied.value;
                final isExpired = controller.internship.isExpired;

                if (hasApplied) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'Application Submitted',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: null,
                  );
                }

                if (isExpired) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: null,
                    child: const Text(
                      'Deadline Passed',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => controller.applyNow(),
                  child: Text(
                    controller.internship.applicationType == 'external'
                        ? 'Apply on Company Site'
                        : 'Apply Now',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
