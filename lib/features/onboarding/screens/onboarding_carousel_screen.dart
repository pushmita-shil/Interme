import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingCarouselScreen extends StatelessWidget {
  OnboardingCarouselScreen({super.key});

  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Detect Fake Internships Instantly',
      'subtitle': 'Upload descriptions, PDFs, or screenshots and receive an AI trust score.',
      'icon': 'search',
    },
    {
      'title': 'Apply with Confidence',
      'subtitle': 'Browse listings from verified companies and organizations.',
      'icon': 'verified',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.chooseRole),
            child: Text(
              'Skip',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => _currentPage.value = index,
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.marginMobile),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slide Icon / Graphic
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: (index == 0 ? AppColors.primary : AppColors.secondary).withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          index == 0 ? Icons.security : Icons.verified_user,
                          color: index == 0 ? AppColors.primary : AppColors.secondary,
                          size: 96,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Slide Title
                      Text(
                        slide['title']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Slide Subtitle
                      Text(
                        slide['subtitle']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dots & Button Section
          Container(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicators
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage.value == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage.value == index
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 32),
                // Button
                Obx(() {
                  final isLast = _currentPage.value == _slides.length - 1;
                  return CustomButton(
                    text: isLast ? 'Get Started' : 'Next',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      if (isLast) {
                        Get.offAllNamed(AppRoutes.chooseRole);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
