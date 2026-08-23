import 'package:get/get.dart';
import 'app_routes.dart';

// Splash imports
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/screens/splash_screen.dart';

// Onboarding imports
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/onboarding_carousel_screen.dart';

// Auth imports
import '../../features/authentication/bindings/auth_binding.dart';
import '../../features/authentication/screens/choose_role_screen.dart';
import '../../features/authentication/screens/sign_in_screen.dart';
import '../../features/authentication/screens/sign_up_screen.dart';
import '../../features/authentication/screens/otp_verification_screen.dart';
import '../../features/authentication/screens/password_recovery_screen.dart';
import '../../features/authentication/screens/verification_pending_screen.dart';
import '../../features/authentication/screens/onboarding_success_screen.dart';

// Student imports
import '../../features/student/bindings/student_binding.dart';
import '../../features/student/screens/student_profile_completion_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/marketplace_screen.dart';
import '../../features/student/screens/application_tracker_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingCarouselScreen(),
    ),
    GetPage(
      name: AppRoutes.chooseRole,
      page: () => const ChooseRoleScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => SignInScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.passwordRecovery,
      page: () => PasswordRecoveryScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verificationPending,
      page: () => const VerificationPendingScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingSuccess,
      page: () => const OnboardingSuccessScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.studentProfileCompletion,
      page: () => const StudentProfileCompletionScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDashboard,
      page: () => const StudentDashboardScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.marketplace,
      page: () => const MarketplaceScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.tracker,
      page: () => const ApplicationTrackerScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentProfile,
      page: () => const StudentProfileScreen(),
      binding: StudentBinding(),
    ),
  ];
}
