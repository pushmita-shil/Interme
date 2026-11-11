import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/saved_internship_model.dart';
import '../../../services/firebase/auth_service.dart';
import '../services/marketplace_service.dart';
import '../views/internship_details_screen.dart';
import '../../../data/models/internship_model.dart';

class SavedInternshipsScreen extends StatelessWidget {
  const SavedInternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final marketplaceService = Get.find<MarketplaceService>();
    final uid = authService.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Saved Opportunities',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<SavedInternshipModel>>(
          stream: marketplaceService.streamSavedInternships(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final savedList = snapshot.data ?? [];

            if (savedList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No saved opportunities yet',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon on any internship listing to save it for review or application later.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              itemCount: savedList.length,
              itemBuilder: (context, index) {
                final item = savedList[index];
                return _buildSavedCard(context, item, marketplaceService, uid);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedCard(
    BuildContext context,
    SavedInternshipModel item,
    MarketplaceService service,
    String studentId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
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
            // Build minimal model to open details
            final model = InternshipModel(
              id: item.internshipId,
              title: item.title,
              companyId: item.companyId,
              companyName: item.companyName,
              logoUrl: item.companyLogo,
              stipend: item.stipend,
              workMode: item.workMode,
              location: item.location,
              deadline: item.deadline,
              isVerified: item.isVerified,
              trustScore: item.trustScore,
              description: 'View full details inside internship portal.',
            );
            Get.to(() => const InternshipDetailsScreen(), arguments: model);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceContainerLow,
                    child: Center(
                      child: Text(
                        item.companyName.isNotEmpty
                            ? item.companyName[0].toUpperCase()
                            : 'I',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.companyName,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: AppColors.secondary, size: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            item.stipend > 0
                                ? '₹${item.stipend.toInt()}/mo'
                                : 'Unpaid',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${item.workMode}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (item.isExpired) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Expired',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove, color: AppColors.error),
                  onPressed: () {
                    service.removeSavedInternship(studentId, item.internshipId);
                    Get.snackbar(
                      'Removed',
                      '${item.title} removed from saved list.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

