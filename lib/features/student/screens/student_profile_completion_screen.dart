import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../controllers/student_controller.dart';

class StudentProfileCompletionScreen extends GetView<StudentController> {
  const StudentProfileCompletionScreen({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Your Profile',
                style: AppTextStyles.headlineXL.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us match you with the perfect internship opportunities.',
                style: AppTextStyles.bodyLg.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 36),
              
              // Custom Stepper/Header Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepNode(step: '1', label: 'Education', active: true),
                  _buildStepNode(step: '2', label: 'Skills', active: true),
                  _buildStepNode(step: '3', label: 'Preferences', active: true),
                ],
              ),
              const Divider(height: 48, color: AppColors.outlineVariant),
              
              // Education Section
              _buildSectionHeader(icon: Icons.school, title: 'Academic Details'),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'College/University Name',
                placeholder: 'e.g. Stanford University',
                controller: controller.collegeController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Department',
                placeholder: 'e.g. Computer Science',
                controller: controller.departmentController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Passing Year',
                placeholder: 'e.g. 2026',
                keyboardType: TextInputType.number,
                controller: controller.passingYearController,
              ),
              
              const SizedBox(height: 36),
              
              // Skills & Links Section
              _buildSectionHeader(icon: Icons.psychology, title: 'Skills & Professional Presence'),
              const SizedBox(height: 16),
              Text(
                'Select your Top Skills',
                style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Skills chips Row
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      'JavaScript',
                      'Python',
                      'UI Design',
                      'Node.js',
                      'React',
                      'Data Analysis',
                      'Flutter',
                    ].map((skill) {
                      final isSelected = controller.selectedSkills.contains(skill);
                      return ChoiceChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (selected) => controller.toggleSkill(skill),
                        selectedColor: AppColors.primaryContainer.withOpacity(0.12),
                        checkmarkColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: AppTextStyles.labelMd.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'LinkedIn URL',
                placeholder: 'linkedin.com/in/username',
                prefixIcon: Icons.link,
                controller: controller.linkedinController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'GitHub/Portfolio URL',
                placeholder: 'github.com/username',
                prefixIcon: Icons.link,
                controller: controller.githubController,
              ),
              
              const SizedBox(height: 36),
              
              // Preferences Section
              _buildSectionHeader(icon: Icons.rocket_launch, title: 'Internship Preferences'),
              const SizedBox(height: 20),
              Text(
                'Preferred Type',
                style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                    children: ['Remote', 'Hybrid', 'Onsite'].map((type) {
                      final isSelected = controller.preferredType.value == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected ? AppColors.primaryContainer.withOpacity(0.08) : Colors.transparent,
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => controller.updatePreferredType(type),
                            child: Text(
                              type,
                              style: AppTextStyles.labelMd.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Preferred Location',
                placeholder: 'e.g. New York, Bangalore',
                prefixIcon: Icons.place_outlined,
                controller: controller.locationController,
              ),
              const SizedBox(height: 24),
              Text(
                'Expected Monthly Stipend',
                style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: controller.expectedStipend.value,
                          min: 0,
                          max: 5000,
                          divisions: 50,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.outlineVariant,
                          onChanged: (val) => controller.updateExpectedStipend(val),
                        ),
                      ),
                      Text(
                        '₹${controller.expectedStipend.value.toInt()}/mo',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 48),
              
              // Submit button
              Obx(() => CustomButton(
                    text: 'Complete Profile',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.completeProfile,
                  )),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepNode({required String step, required String label, required bool active}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : Colors.transparent,
            border: Border.all(color: active ? AppColors.primary : AppColors.outlineVariant, width: 2),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: active ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.headlineMd.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
