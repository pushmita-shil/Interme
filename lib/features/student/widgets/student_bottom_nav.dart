import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex < 5 ? currentIndex : 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        onTap: (index) {
          if (index == currentIndex) return;
          switch (index) {
            case 0:
              Get.offAllNamed(AppRoutes.studentDashboard);
              break;
            case 1:
            case 2:
              Get.offNamed(AppRoutes.marketplace);
              break;
            case 3:
              Get.offNamed(AppRoutes.tracker);
              break;
            case 4:
              Get.offNamed(AppRoutes.studentProfile);
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.center_focus_strong, size: 16, color: Colors.white),
            ),
            label: 'Scan',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Apps'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
