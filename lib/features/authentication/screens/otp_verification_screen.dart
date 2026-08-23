import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Lock/Shield Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_outlined,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              
              // Headline & Text
              Text(
                'Security Verification',
                style: AppTextStyles.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit verification code to your email address. Please enter it below to verify.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              
              // Simple OTP Input field
              CustomTextField(
                label: 'Verification Code',
                placeholder: 'Enter 123456',
                prefixIcon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                controller: controller.otpController,
              ),
              const SizedBox(height: 32),
              
              // Verify Button
              Obx(() => CustomButton(
                    text: 'Verify Code',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.verifyOtp,
                  )),
              const SizedBox(height: 24),
              
              // Resend Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        'OTP Resent',
                        'Verification code resent to your email address.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Text(
                      'Resend Code',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
