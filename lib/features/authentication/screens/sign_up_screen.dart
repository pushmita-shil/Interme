import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends GetView<AuthController> {
  SignUpScreen({super.key});

  final RxBool _obscurePassword = true.obs;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'InternMe',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Welcome Text
              Text(
                'Create Account',
                style: AppTextStyles.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    'Register as a ${controller.selectedRole.value.isEmpty ? 'Student' : controller.selectedRole.value}',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  )),
              const SizedBox(height: 32),
              
              // Form Fields
              CustomTextField(
                label: 'Full Name',
                placeholder: 'e.g. John Doe',
                prefixIcon: Icons.person_outline,
                controller: controller.nameController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Address',
                placeholder: 'name@company.com',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: controller.emailController,
              ),
              const SizedBox(height: 20),
              Obx(() => CustomTextField(
                    label: 'Password',
                    placeholder: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword.value,
                    controller: controller.passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.outline,
                      ),
                      onPressed: () => _obscurePassword.toggle(),
                    ),
                  )),
              const SizedBox(height: 32),
              
              // Sign Up Button
              Obx(() => CustomButton(
                    text: 'Sign Up',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.signUp,
                  )),
              const SizedBox(height: 32),
              
              // Navigation to Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.signIn),
                    child: Text(
                      'Sign In',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
