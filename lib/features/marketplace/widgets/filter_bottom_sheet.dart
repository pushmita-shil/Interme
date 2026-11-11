import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/marketplace_filter_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final MarketplaceFilterModel initialFilter;
  final Function(MarketplaceFilterModel) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MarketplaceFilterModel filter;

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter.clone();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter & Sort',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (filter.activeFiltersCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filter.activeFiltersCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      filter.reset();
                    });
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // 1. Sort By
                _buildSectionTitle('Sort By'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip('Most Relevant', MarketplaceSortOption.mostRelevant),
                    _buildSortChip('Recently Added', MarketplaceSortOption.recentlyAdded),
                    _buildSortChip('Highest Stipend', MarketplaceSortOption.highestStipend),
                    _buildSortChip('Deadline Approaching', MarketplaceSortOption.deadlineApproaching),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Verification Status
                _buildSectionTitle('Trust & Verification'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Verified Organizations Only',
                        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Only display listings audited against registration & fee scams',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: filter.verifiedOnly,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (val) {
                    setState(() {
                      filter.verifiedOnly = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 3. Work Mode
                _buildSectionTitle('Location / Work Mode'),
                Wrap(
                  spacing: 8,
                  children: ['Remote', 'Hybrid', 'On-site'].map((mode) {
                    final isSelected = filter.selectedWorkModes.contains(mode);
                    return FilterChip(
                      label: Text(mode),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer.withOpacity(0.16),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            filter.selectedWorkModes.add(mode);
                          } else {
                            filter.selectedWorkModes.remove(mode);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 4. Stipend
                _buildSectionTitle('Stipend Compensation'),
                Row(
                  children: ['All', 'Paid', 'Unpaid'].map((type) {
                    final isSelected = filter.stipendType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer.withOpacity(0.16),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              filter.stipendType = type;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Range: ₹${filter.minStipend.toInt()} - ₹${filter.maxStipend.toInt()}',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(filter.minStipend, filter.maxStipend),
                  min: 0,
                  max: 100000,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  labels: RangeLabels(
                    '₹${filter.minStipend.toInt()}',
                    '₹${filter.maxStipend.toInt()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      filter.minStipend = values.start;
                      filter.maxStipend = values.end;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 5. Duration
                _buildSectionTitle('Duration'),
                Wrap(
                  spacing: 8,
                  children: ['All', '1-3 months', '3-6 months', '6+ months'].map((dur) {
                    final isSelected = filter.durationOption == dur;
                    return ChoiceChip(
                      label: Text(dur),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer.withOpacity(0.16),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            filter.durationOption = dur;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 6. Experience Level
                _buildSectionTitle('Experience Level'),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Beginner', 'Intermediate'].map((lvl) {
                    final isSelected = filter.experienceLevel == lvl;
                    return ChoiceChip(
                      label: Text(lvl),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer.withOpacity(0.16),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            filter.experienceLevel = lvl;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 7. Application Deadline
                _buildSectionTitle('Application Deadline'),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Closing Soon', 'Upcoming'].map((dl) {
                    final isSelected = filter.deadlineFilter == dl;
                    return ChoiceChip(
                      label: Text(dl),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer.withOpacity(0.16),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            filter.deadlineFilter = dl;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  widget.onApply(filter);
                  Get.back();
                },
                child: Text(
                  'Apply Filters (${filter.activeFiltersCount})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.labelMd.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, MarketplaceSortOption option) {
    final isSelected = filter.sortOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer.withOpacity(0.16),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            filter.sortOption = option;
          });
        }
      },
    );
  }
}

