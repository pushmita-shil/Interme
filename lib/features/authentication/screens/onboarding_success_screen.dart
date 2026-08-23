import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';

class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key});

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
              // Checked Shield Graphic
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.secondary,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              
              // Headline
              Text(
                'Account Verified!',
                style: AppTextStyles.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to InternMe, ${user?.name ?? 'User'}. Your security verification is complete. You can now configure your profile.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 48),
              
              // Button
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  final role = user?.role ?? 'Student';
                  if (role == 'Student') {
                    Get.offAllNamed(AppRoutes.studentProfileCompletion);
                  } else {
                    Get.offAllNamed(AppRoutes.verificationPending);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
