import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class ChooseRoleScreen extends GetView<AuthController> {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Who are you?',
                        style: AppTextStyles.headlineXL.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your role to personalize your experience.',
                        style: AppTextStyles.bodyLg.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      
                      // Role Selection Grid/List
                      _buildRoleCard(
                        role: 'Student',
                        benefit: 'Find verified internships',
                        icon: Icons.school,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        role: 'Company',
                        benefit: 'Post authentic opportunities',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        role: 'Institute',
                        benefit: 'Manage student internships',
                        icon: Icons.account_balance,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        role: 'Admin',
                        benefit: 'Platform moderation',
                        icon: Icons.shield,
                      ),
                    ],
                  ),
                ),
              ),
              // Action Button at Bottom
              Obx(() {
                final isSelected = controller.selectedRole.value.isNotEmpty;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        text: 'Continue',
                        onPressed: isSelected ? controller.continueRole : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Step 1 of 4: Role Definition',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
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
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String benefit,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == role;
      return GestureDetector(
        onTap: () => controller.selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.5),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.secondary.withOpacity(0.04)
                    : Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary.withOpacity(0.12)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.secondary : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benefit,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.secondary,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    });
  }
}
