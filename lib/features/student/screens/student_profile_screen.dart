import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';
import '../controllers/student_controller.dart';

class StudentProfileScreen extends GetView<StudentController> {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Profile',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                ),
              ),
              
              // Profile Details Overlay
              Transform.translate(
                offset: const Offset(0, -50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.person, size: 56, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user?.name ?? 'Pushmita Roy',
                                          style: AppTextStyles.headlineMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.verified, color: AppColors.secondary, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Verified Student',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Trust Level: Gold (850 points)',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Stat counters
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              value: '${controller.studentApplications.length}',
                              label: 'Applications',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatItem(
                              value: '4',
                              label: 'Certificates',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatItem(
                              value: '98%',
                              label: 'Trust Score',
                              isSecondary: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Bio Section
                      _buildSectionCard(
                        title: 'Bio',
                        icon: Icons.person_pin,
                        content: Text(
                          'Aspiring Flutter developer passionate about building secure mobile ecosystems. Focused on creating user-centric designs with robust architectural patterns.',
                          style: AppTextStyles.bodyLg.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Academic details
                      _buildSectionCard(
                        title: 'Education',
                        icon: Icons.school,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.degree ?? 'Bachelor of Technology',
                              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${user?.college ?? 'Stanford University'} • ${user?.passingYear ?? 2026}',
                              style: AppTextStyles.bodySm,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Skills
                      _buildSectionCard(
                        title: 'Skills',
                        icon: Icons.psychology,
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (user?.skills ?? ['Flutter', 'Dart', 'Firebase', 'UI UX']).map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: AppColors.primaryContainer.withOpacity(0.08),
                              side: const BorderSide(color: Colors.transparent),
                              labelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Verified Documents
                      _buildSectionCard(
                        title: 'Verified Documents',
                        icon: Icons.article,
                        content: Column(
                          children: [
                            _buildDocTile(label: 'Resume.pdf', icon: Icons.picture_as_pdf, color: AppColors.error),
                            const SizedBox(height: 8),
                            _buildDocTile(label: 'GitHub Profile', icon: Icons.link, color: AppColors.primary),
                            const SizedBox(height: 8),
                            _buildDocTile(label: 'LinkedIn Profile', icon: Icons.link, color: AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Achievements
                      _buildSectionCard(
                        title: 'Achievements',
                        icon: Icons.workspace_premium,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBadgeNode(icon: Icons.security, label: 'Scam Hunter', color: AppColors.tertiary),
                            _buildBadgeNode(icon: Icons.stars, label: 'Top Contrib', color: AppColors.secondary),
                            _buildBadgeNode(icon: Icons.explore, label: 'Explorer', color: AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      
                      // Edit Profile & Logout
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => Get.toNamed(AppRoutes.studentProfileCompletion),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                authService.logout();
                                Get.offAllNamed(AppRoutes.welcome);
                              },
                              child: const Text('Logout'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              color: isSecondary ? AppColors.secondary : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildDocTile({required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
        ],
      ),
    );
  }

  Widget _buildBadgeNode({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
