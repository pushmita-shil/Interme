import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield, color: AppColors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'InternMe',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Centered Illustration (High tech trust tech theme)
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing background circles
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.5),
                      ),
                    ),
                    // Central Shield icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: AppColors.secondary,
                        size: 64,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Headline & Tagline
              Text(
                'Your Trusted Internship Companion',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Protect yourself from fake internships using AI-powered verification. Secure your professional future with credentials you can trust.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Buttons
              CustomButton(
                text: 'Get Started',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Get.toNamed(AppRoutes.onboarding);
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Sign In',
                isOutline: true,
                onPressed: () {
                  Get.toNamed(AppRoutes.signIn);
                },
              ),
              const SizedBox(height: 48),
              
              // Bento-Style Feature Grid
              Text(
                'WHY INTERNME?',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildFeatureCard(
                    icon: Icons.auto_awesome,
                    title: 'AI Verification',
                    description: 'Real-time employer vetting to ensure legal compliance and legitimacy.',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    icon: Icons.gpp_good,
                    title: 'Data Protection',
                    description: 'Your personal credentials are encrypted and never sold to third parties.',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    icon: Icons.track_changes,
                    title: 'Smart Tracking',
                    description: 'Centralized dashboard for all your application statuses and documents.',
                    color: AppColors.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '© 2026 InternMe Inc. • ',
                    style: AppTextStyles.labelSm,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Privacy Policy',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySm.copyWith(
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
}
