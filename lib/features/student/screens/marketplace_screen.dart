import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../controllers/student_controller.dart';
import '../../../data/models/internship_model.dart';

class MarketplaceScreen extends GetView<StudentController> {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Internship Marketplace',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              child: TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.filterSearch(val),
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Search title, company, or location...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                  prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            
            // Listings Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        '${controller.filteredInternships.length} opportunities found',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                      )),
                  const Icon(Icons.filter_list, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Listings List
            Expanded(
              child: Obx(() {
                if (controller.filteredInternships.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 48, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Text('No internships match your search.', style: AppTextStyles.bodyMd),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                  itemCount: controller.filteredInternships.length,
                  itemBuilder: (context, index) {
                    final internship = controller.filteredInternships[index];
                    return _buildListCard(internship);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(InternshipModel internship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                internship.companyName,
                style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.secondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${internship.trustScore.toInt()}% Trust',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            internship.title,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  internship.type,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                internship.location,
                style: AppTextStyles.bodySm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            internship.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${internship.stipend.toInt()}/mo',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 18,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => controller.applyForInternship(internship),
                child: const Text('Apply Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
