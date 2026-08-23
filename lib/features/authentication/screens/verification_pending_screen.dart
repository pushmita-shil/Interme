import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions_outlined,
                  color: AppColors.tertiary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title & Subtitle
              Text(
                'Verification Pending',
                style: AppTextStyles.headlineLg.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Hello ${user?.name ?? 'User'}, your registration as a ${user?.role ?? 'Partner'} is being reviewed by our security team to ensure trust and authenticity on InternMe.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Estimated Time Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Estimated time: 24-48 hours. We will notify you via email once approved.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Logout Button
              CustomButton(
                text: 'Log Out',
                isOutline: true,
                onPressed: () {
                  authService.logout();
                  Get.offAllNamed(AppRoutes.welcome);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
