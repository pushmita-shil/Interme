import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/internship_model.dart';
import '../controllers/marketplace_controller.dart';
import '../views/internship_details_screen.dart';

class InternshipCard extends StatelessWidget {
  final InternshipModel internship;
  final bool isHorizontalCompact;

  const InternshipCard({
    super.key,
    required this.internship,
    this.isHorizontalCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final marketplaceController = Get.isRegistered<MarketplaceController>()
        ? Get.find<MarketplaceController>()
        : null;

    final width = isHorizontalCompact ? 300.0 : double.infinity;

    return Container(
      width: width,
      margin: EdgeInsets.only(
        right: isHorizontalCompact ? 16 : 0,
        bottom: isHorizontalCompact ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: internship.isClosingSoon
              ? Colors.amber.shade300
              : AppColors.outlineVariant.withOpacity(0.5),
          width: internship.isClosingSoon ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(
              () => const InternshipDetailsScreen(),
              arguments: internship,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Company Logo, Name, Verified Badge, and Bookmark Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo with fallback
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        color: AppColors.surfaceContainerLow,
                        child: internship.logoUrl.isNotEmpty
                            ? Image.network(
                                internship.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackLogo(),
                              )
                            : _buildFallbackLogo(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Company Name and Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  internship.companyName,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (internship.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.secondary,
                                  size: 15,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${internship.location} • ${internship.workMode}',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bookmark Save Button
                    if (marketplaceController != null)
                      Obx(() {
                        final isSaved = marketplaceController.isInternshipSaved(internship.id);
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? AppColors.primary : AppColors.outline,
                            size: 22,
                          ),
                          onPressed: () => marketplaceController.toggleSave(internship),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 12),

                // Internship Title
                Text(
                  internship.title,
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Tags Row: Stipend, Duration, Closing Soon
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPill(
                      icon: Icons.payments_outlined,
                      label: internship.stipend > 0
                          ? '₹${internship.stipend.toInt()}/mo'
                          : 'Unpaid',
                      color: AppColors.primary,
                      bgColor: AppColors.primary.withOpacity(0.08),
                    ),
                    _buildPill(
                      icon: Icons.schedule,
                      label: internship.duration,
                      color: AppColors.onSurfaceVariant,
                      bgColor: Colors.grey.shade100,
                    ),
                    if (internship.isClosingSoon)
                      _buildPill(
                        icon: Icons.timer_outlined,
                        label: '${internship.daysRemaining}d left',
                        color: Colors.amber.shade900,
                        bgColor: Colors.amber.shade50,
                      ),
                    if (internship.isExpired)
                      _buildPill(
                        icon: Icons.error_outline,
                        label: 'Expired',
                        color: AppColors.error,
                        bgColor: AppColors.errorContainer.withOpacity(0.3),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Skills Chips (Top 3)
                if (internship.skills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: internship.skills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF0F2F5)),
                const SizedBox(height: 10),

                // Bottom Row: Trust Score (if calculated) & View/Apply
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Verified Trust Score Pill (Only if verified and score exists!)
                    if (internship.isVerified && internship.trustScore != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: AppColors.secondary,
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${internship.trustScore!.toInt()}% Trust Score',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Review Pending',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                    // Quick arrow
                    Row(
                      children: [
                        Text(
                          'Details',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 11,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Text(
          internship.companyName.isNotEmpty
              ? internship.companyName[0].toUpperCase()
              : 'I',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
