import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/internship_card.dart';
import '../widgets/marketplace_shimmer.dart';
import '../../student/widgets/student_bottom_nav.dart';
import 'saved_internships_screen.dart';

class MarketplaceScreen extends GetView<MarketplaceController> {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadAllSections(),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              // Search & Filter Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context),
                      const SizedBox(height: 16),
                      _buildCategoryChips(),
                      const SizedBox(height: 12),
                      _buildActiveFiltersRow(context),
                    ],
                  ),
                ),
              ),

              // Dynamic content based on search/filter or sectioned view
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                      child: MarketplaceShimmer(count: 4),
                    ),
                  );
                }

                if (controller.hasError.value) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(),
                  );
                }

                // If user has entered a search query or applied specific filters, show focused search results
                final hasActiveSearchOrFilter =
                    controller.filter.value.searchQuery.isNotEmpty ||
                    controller.filter.value.selectedCategory != 'All' ||
                    controller.filter.value.activeFiltersCount > 0;

                if (hasActiveSearchOrFilter) {
                  return _buildSearchResultsSection();
                }

                // Default Home Marketplace View with Sections (Featured, Recommended, Closing Soon, All)
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Internships
                      if (controller.featuredInternships.isNotEmpty) ...[
                        _buildSectionHeader(
                          title: 'Featured Opportunities',
                          subtitle: 'Admin-highlighted authentic programs',
                          icon: Icons.stars_rounded,
                          iconColor: Colors.amber.shade700,
                        ),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.marginMobile,
                            ),
                            itemCount: controller.featuredInternships.length,
                            itemBuilder: (context, index) {
                              final item = controller.featuredInternships[index];
                              return InternshipCard(
                                internship: item,
                                isHorizontalCompact: true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recommended for You
                      if (controller.recommendedInternships.isNotEmpty) ...[
                        _buildSectionHeader(
                          title: 'Recommended For You',
                          subtitle: 'Matched with your profile skills & preferences',
                          icon: Icons.psychology,
                          iconColor: AppColors.primary,
                        ),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.marginMobile,
                            ),
                            itemCount: controller.recommendedInternships.length,
                            itemBuilder: (context, index) {
                              final item = controller.recommendedInternships[index];
                              return InternshipCard(
                                internship: item,
                                isHorizontalCompact: true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Closing Soon
                      if (controller.closingSoonInternships.isNotEmpty) ...[
                        _buildSectionHeader(
                          title: 'Closing Soon',
                          subtitle: 'Deadlines approaching within 14 days',
                          icon: Icons.timer_outlined,
                          iconColor: Colors.amber.shade800,
                        ),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.marginMobile,
                            ),
                            itemCount: controller.closingSoonInternships.length,
                            itemBuilder: (context, index) {
                              final item = controller.closingSoonInternships[index];
                              return InternshipCard(
                                internship: item,
                                isHorizontalCompact: true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // All Internships Header
                      _buildSectionHeader(
                        title: 'All Opportunities',
                        subtitle: 'Verified and active internship listings',
                        icon: Icons.explore_outlined,
                        iconColor: AppColors.secondary,
                      ),

                      // All Internships Vertical List
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.marginMobile,
                        ),
                        child: Column(
                          children: [
                            ...controller.allInternships.map(
                              (item) => InternshipCard(internship: item),
                            ),
                            if (controller.isLoadingMore.value)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketplace',
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'Discover verified internship opportunities',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        // Saved Internships Shortcut
        IconButton(
          tooltip: 'Saved Internships',
          icon: const Icon(Icons.bookmark_outline, color: AppColors.onSurface),
          onPressed: () {
            Get.to(() => const SavedInternshipsScreen());
          },
        ),
        // My Applications Shortcut
        IconButton(
          tooltip: 'My Applications',
          icon: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.onSurface),
          onPressed: () {
            Get.toNamed(AppRoutes.tracker);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (val) => controller.searchQuery.value = val,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Search title, skills, company, location...',
                hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.outline, size: 20),
                      onPressed: () {
                        controller.searchTextController.clear();
                        controller.searchQuery.value = '';
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
        ),
        const SizedBox(width: 10),

        // Filter Button with Active Filter Count Badge
        Obx(() {
          final count = controller.filter.value.activeFiltersCount;
          return Stack(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: count > 0 ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: count > 0 ? AppColors.primary : AppColors.outlineVariant,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: count > 0 ? Colors.white : AppColors.onSurface,
                  ),
                  onPressed: () => _openFilterModal(context),
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          return Obx(() {
            final isSelected = controller.filter.value.selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  ),
                ),
                labelStyle: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                onSelected: (selected) {
                  if (selected) controller.selectCategory(cat);
                },
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersRow(BuildContext context) {
    return Obx(() {
      final f = controller.filter.value;
      if (f.activeFiltersCount == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Text(
              '${controller.allInternships.length} results matching:',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => controller.resetFilter(),
              child: Text(
                'Clear all filters',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.marginMobile,
        12,
        AppSizes.marginMobile,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
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
  }

  Widget _buildSearchResultsSection() {
    if (controller.allInternships.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
                    Icons.search_off_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No matching internships found',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search keywords, clearing filters, or exploring other categories.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => controller.resetFilter(),
                  child: const Text('Reset All Filters'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = controller.allInternships[index];
            return InternshipCard(internship: item);
          },
          childCount: controller.allInternships.length,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Could not load internships',
              style: AppTextStyles.headlineMd.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry'),
              onPressed: () => controller.loadAllSections(),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterModal(BuildContext context) {
    Get.bottomSheet(
      FilterBottomSheet(
        initialFilter: controller.filter.value,
        onApply: (newFilter) {
          controller.applyFilter(newFilter);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
