import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_controller.dart';
import '../../../data/models/internship_model.dart';
import '../../../services/firebase/auth_service.dart';
import '../widgets/student_bottom_nav.dart';

class StudentDashboardScreen extends GetView<StudentController> {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'InternVerify',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () {
              Get.find<AuthService>().logout();
              Get.offAllNamed(AppRoutes.welcome);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Good Morning, ${user?.name ?? 'Student'} 👋',
                style: AppTextStyles.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to find your next verified opportunity?',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              
              // AI Insight Card & Statistics Bento Grid
              _buildBentoHeroSection(),
              const SizedBox(height: 32),
              
              // Quick Actions Grid
              Text(
                'Quick Actions',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(),
              const SizedBox(height: 32),
              
              // Recommended Internships Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for You',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.marketplace),
                    child: Text(
                      'View All',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Recommended Internships Carousel List
              SizedBox(
                height: 240,
                child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.filteredInternships.length,
                      itemBuilder: (context, index) {
                        final internship = controller.filteredInternships[index];
                        return _buildInternshipCard(internship);
                      },
                    )),
              ),
              const SizedBox(height: 32),
              
              // Latest Scam Alert Card
              _buildScamAlertCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
    );
  }

  Widget _buildBentoHeroSection() {
    return Column(
      children: [
        // AI Insight Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TODAY\'S AI INSIGHT',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"Only apply to internships posted by verified organizations."',
                style: AppTextStyles.bodyLg.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Get.toNamed(AppRoutes.marketplace),
                child: const Text('Verify Now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Bento Stats Grid (Horizontal cards list)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.verified,
                title: 'Verified Apps',
                value: '12',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.workspace_premium,
                title: 'Trust Points',
                value: '450',
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'label': 'AI Scanner', 'icon': Icons.center_focus_strong, 'color': AppColors.primary, 'route': AppRoutes.marketplace},
      {'label': 'Marketplace', 'icon': Icons.shopping_bag, 'color': AppColors.secondary, 'route': AppRoutes.marketplace},
      {'label': 'Reviews', 'icon': Icons.rate_review, 'color': AppColors.tertiary, 'route': AppRoutes.marketplace},
      {'label': 'Scam Alerts', 'icon': Icons.gpp_maybe, 'color': AppColors.error, 'route': AppRoutes.marketplace},
      {'label': 'Certificates', 'icon': Icons.badge, 'color': AppColors.primaryContainer, 'route': AppRoutes.marketplace},
      {'label': 'Roadmap', 'icon': Icons.map, 'color': AppColors.inverseSurface, 'route': AppRoutes.marketplace},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final act = actions[index];
        final iconColor = act['color'] as Color;
        return GestureDetector(
          onTap: () {
            final route = act['route'] as String;
            Get.toNamed(route);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(act['icon'] as IconData, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  act['label'] as String,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInternshipCard(InternshipModel internship) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: AppColors.secondary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
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
          const SizedBox(height: 12),
          Text(
            internship.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            '${internship.companyName} • ${internship.location}',
            style: AppTextStyles.bodySm,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                '₹${internship.stipend.toInt()}/mo',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Get.snackbar('Saved', 'Internship bookmarked successfully!',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => controller.applyForInternship(internship),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScamAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
              const SizedBox(width: 8),
              Text(
                'Latest Scam Alert',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Fake Internship - XYZ Tech',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Asking for "registration fees" via WhatsApp. Do not pay any amount.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.errorContainer),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups, color: AppColors.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Reported by 58 Students',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: AppColors.error,
                child: const Text(
                  'DANGER: HIGH',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
