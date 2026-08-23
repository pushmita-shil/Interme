import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class SignInScreen extends GetView<AuthController> {
  SignInScreen({super.key});

  final RxBool _obscurePassword = true.obs;
  final RxBool _rememberMe = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // App Logo
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
              const SizedBox(height: 48),
              
              // Welcome Text
              Text(
                'Welcome Back',
                style: AppTextStyles.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access your verified career portal',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              
              // Form Fields
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
              const SizedBox(height: 16),
              
              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: _rememberMe.value,
                            onChanged: (val) {
                              if (val != null) _rememberMe.value = val;
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                      Text(
                        'Remember Me',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.passwordRecovery),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Biometrics Mockup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Or authenticate using: ',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.face, color: AppColors.outline),
                    onPressed: () {
                      controller.emailController.text = 'pushmita@test.com';
                      controller.passwordController.text = 'password';
                      controller.signIn();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, color: AppColors.outline),
                    onPressed: () {
                      controller.emailController.text = 'pushmita@test.com';
                      controller.passwordController.text = 'password';
                      controller.signIn();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Sign In Button
              Obx(() => CustomButton(
                    text: 'Sign In',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.signIn,
                  )),
              const SizedBox(height: 36),
              
              // Social Login
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: Text('Google', style: AppTextStyles.labelMd),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.window, size: 20),
                      label: Text('Microsoft', style: AppTextStyles.labelMd),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              
              // Sign Up Route Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.chooseRole),
                    child: Text(
                      'Create Account',
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
