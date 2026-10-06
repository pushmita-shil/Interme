import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final selectedRole = ''.obs;
  final isLoading = false.obs;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void continueRole() {
    if (selectedRole.isNotEmpty) {
      Get.toNamed(AppRoutes.signUp);
    }
  }

  Future<void> signIn() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result == AuthResult.success) {
        Get.offAllNamed(AppRoutes.studentDashboard);
        Get.snackbar(
          'Welcome Back',
          'Signed in successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result == AuthResult.errorUserNotFound) {
        Get.snackbar(
          'Login Failed',
          'No account found with this email.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result == AuthResult.errorWrongPassword) {
        Get.snackbar(
          'Login Failed',
          'Incorrect password. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result == AuthResult.errorInvalidEmail) {
        Get.snackbar(
          'Login Failed',
          'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Login Failed',
          'Could not sign in. Please verify your credentials.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.register(
        emailController.text.trim(),
        nameController.text.trim(),
        selectedRole.value.isEmpty ? 'Student' : selectedRole.value,
        passwordController.text.trim(),
      );

      if (result == AuthResult.otpSent) {
        Get.toNamed(AppRoutes.otp);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.verifyOtp(otpController.text.trim());

      if (result == AuthResult.success) {
        Get.offAllNamed(AppRoutes.onboardingSuccess);
      } else {
        Get.snackbar(
          'Error',
          'Invalid OTP code. Use 123456.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Verification failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
