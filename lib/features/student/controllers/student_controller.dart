import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/firebase/auth_service.dart';
import '../../../services/firebase/firestore_service.dart';
import '../../../data/models/internship_model.dart';
import '../../../data/models/application_model.dart';

class StudentController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // Profile controllers
  final collegeController = TextEditingController();
  final degreeController = TextEditingController(text: 'Bachelor of Technology');
  final departmentController = TextEditingController();
  final passingYearController = TextEditingController();
  final linkedinController = TextEditingController();
  final githubController = TextEditingController();
  final locationController = TextEditingController();

  final selectedSkills = <String>['JavaScript', 'UI Design'].obs;
  final preferredType = 'Hybrid'.obs;
  final expectedStipend = 1500.0.obs;

  // Search & Filters in Marketplace
  final searchController = TextEditingController();
  final RxList<InternshipModel> filteredInternships = <InternshipModel>[].obs;

  // Application Tracking
  final RxList<ApplicationModel> studentApplications = <ApplicationModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-populate fields if user profile exists
    final user = _authService.currentUser;
    if (user != null) {
      collegeController.text = user.college ?? '';
      degreeController.text = user.degree ?? 'Bachelor of Technology';
      departmentController.text = user.department ?? '';
      passingYearController.text = user.passingYear?.toString() ?? '';
      linkedinController.text = user.linkedin ?? '';
      githubController.text = user.github ?? '';
      locationController.text = user.preferredLocation ?? '';
      preferredType.value = user.preferredType ?? 'Hybrid';
      expectedStipend.value = user.expectedStipend ?? 1500.0;
      if (user.skills != null) {
        selectedSkills.value = List.from(user.skills!);
      }
    }
    loadInternships();
    loadApplications();
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }

  void updatePreferredType(String type) {
    preferredType.value = type;
  }

  void updateExpectedStipend(double value) {
    expectedStipend.value = value;
  }

  Future<void> completeProfile() async {
    if (collegeController.text.isEmpty ||
        departmentController.text.isEmpty ||
        passingYearController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in college academic details',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      await _authService.updateStudentProfile(
        college: collegeController.text.trim(),
        degree: degreeController.text.trim(),
        department: departmentController.text.trim(),
        passingYear: int.tryParse(passingYearController.text.trim()) ?? 2026,
        skills: selectedSkills.toList(),
        linkedin: linkedinController.text.trim(),
        github: githubController.text.trim(),
        preferredType: preferredType.value,
        preferredLocation: locationController.text.trim(),
        expectedStipend: expectedStipend.value,
      );
      Get.offAllNamed(AppRoutes.studentDashboard);
      Get.snackbar('Success', 'Profile completed successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void loadInternships() {
    filteredInternships.value = List.from(_firestore.internships);
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      loadInternships();
    } else {
      filteredInternships.value = _firestore.internships
          .where((i) => i.title.toLowerCase().contains(query.toLowerCase()) ||
              i.companyName.toLowerCase().contains(query.toLowerCase()) ||
              i.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void loadApplications() {
    final studentId = _authService.currentUser?.id ?? '';
    studentApplications.value = _firestore.getApplications(studentId);
  }

  Future<void> applyForInternship(InternshipModel internship) async {
    final studentId = _authService.currentUser?.id ?? '';
    // Check if already applied
    final exists = studentApplications.any((a) => a.internshipId == internship.id);
    if (exists) {
      Get.snackbar('Alert', 'You have already applied for this internship.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final newApp = ApplicationModel(
      id: const Uuid().v4(),
      internshipId: internship.id,
      studentId: studentId,
      status: 'Applied',
      appliedDate: 'Just Now',
      notes: 'Applied through InternMe Trust Verification.',
    );

    try {
      isLoading.value = true;
      await _firestore.submitApplication(newApp);
      loadApplications();
      
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF006C49)),
              SizedBox(width: 8),
              Text('Applied Successfully!'),
            ],
          ),
          content: Text(
            'Your application for ${internship.title} at ${internship.companyName} has been submitted.\n\nOur AI-verification system vetted this listing with a trust rating of ${internship.trustScore.toInt()}%.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            )
          ],
        )
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    collegeController.dispose();
    degreeController.dispose();
    departmentController.dispose();
    passingYearController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    locationController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
