import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _handleInitialNavigation();
  }

  void _handleInitialNavigation() {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final authService = Get.find<AuthService>();
        final user = await authService.restoreSession();

        if (user != null) {
          debugPrint('SplashController: Restored session for ${user.name} (${user.role}). Navigating to dashboard.');
          switch (user.role) {
            case 'Company':
            case 'Institute':
            case 'Student':
            default:
              Get.offAllNamed(AppRoutes.studentDashboard);
              break;
          }
        } else {
          Get.offNamed(AppRoutes.welcome);
        }
      } catch (e) {
        debugPrint('SplashController navigation error: $e');
        Get.offNamed(AppRoutes.welcome);
      }
    });
  }
}
