import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/internship_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/application_model.dart';
import '../../../services/firebase/auth_service.dart';
import '../services/marketplace_service.dart';
import '../services/trust_score_calculator.dart';
import 'marketplace_controller.dart';

class InternshipDetailsController extends GetxController {
  final MarketplaceService _service = Get.find<MarketplaceService>();
  final AuthService _authService = Get.find<AuthService>();

  late InternshipModel internship;

  final Rxn<CompanyModel> company = Rxn<CompanyModel>();
  final RxBool isLoadingCompany = true.obs;
  final RxBool hasAlreadyApplied = false.obs;
  final RxBool isSubmittingApplication = false.obs;
  final Rxn<TrustEvaluationResult> trustEvaluation =
      Rxn<TrustEvaluationResult>();

  // Application inputs
  final TextEditingController coverLetterController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is InternshipModel) {
      internship = args;
    } else {
      // Fallback
      internship = InternshipModel(
        id: 'unknown',
        title: 'Opportunity',
        companyName: 'Company',
        description: 'Details unavailable',
        location: 'Remote',
        stipend: 0,
      );
    }

    _loadCompanyAndApplicationStatus();
  }

  Future<void> _loadCompanyAndApplicationStatus() async {
    try {
      isLoadingCompany.value = true;
      final comp = await _service.fetchCompany(internship.companyId);
      company.value = comp;

      // Evaluate trust score
      trustEvaluation.value = TrustScoreCalculator.evaluate(
        internship: internship,
        company: comp,
      );

      final uid = _authService.currentUser?.id ?? '';
      if (uid.isNotEmpty) {
        final applied = await _service.hasAlreadyApplied(uid, internship.id);
        hasAlreadyApplied.value = applied;
      }
    } catch (e) {
      debugPrint('InternshipDetailsController load error: $e');
    } finally {
      isLoadingCompany.value = false;
    }
  }

  bool get isSaved {
    if (Get.isRegistered<MarketplaceController>()) {
      return Get.find<MarketplaceController>().isInternshipSaved(internship.id);
    }
    return false;
  }

  void toggleSave() {
    if (Get.isRegistered<MarketplaceController>()) {
      Get.find<MarketplaceController>().toggleSave(internship);
    }
  }

  Future<void> applyNow() async {
    final user = _authService.currentUser;
    if (user == null) {
      Get.snackbar(
        'Sign In Required',
        'Please sign in to apply for internship opportunities.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (internship.isExpired) {
      Get.snackbar(
        'Application Closed',
        'This internship has passed its application deadline.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    if (hasAlreadyApplied.value) {
      Get.snackbar(
        'Already Applied',
        'You have already submitted an application for this position.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // If external application
    if (internship.applicationType == 'external' &&
        internship.applicationUrl.isNotEmpty) {
      final uri = Uri.tryParse(internship.applicationUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // Record external application action
      final app = ApplicationModel(
        id: const Uuid().v4(),
        internshipId: internship.id,
        studentId: user.id,
        studentName: user.name,
        internshipTitle: internship.title,
        companyId: internship.companyId,
        companyName: internship.companyName,
        companyLogo: internship.logoUrl,
        status: 'Applied',
        appliedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        applicationType: 'external',
        notes:
            'Redirected to external recruitment portal: ${internship.applicationUrl}',
        statusUpdates: [
          {
            'status': 'Applied',
            'timestamp': DateTime.now().toIso8601String(),
            'remarks': 'Student navigated to official application portal.',
          },
        ],
      );

      try {
        await _service.submitApplication(app);
        hasAlreadyApplied.value = true;
      } catch (e) {
        debugPrint('Error recording external application: $e');
      }
      return;
    }

    // In-app application confirmation sheet
    Get.bottomSheet(
      _buildApplicationModal(user),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildApplicationModal(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.send_rounded, color: Color(0xFF004AC6)),
                const SizedBox(width: 10),
                Text(
                  'Submit Application',
                  style: Get.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Applying for ${internship.title} at ${internship.companyName}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Profile Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF004AC6),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user.degree != null || user.college != null) ...[
                    const Divider(height: 20),
                    Text(
                      '${user.degree ?? 'Student'} • ${user.college ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cover Note Input
            TextField(
              controller: coverLetterController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Cover Note / Why are you a good fit? (Optional)',
                hintText: 'Briefly highlight relevant projects or skills...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSubmittingApplication.value
                      ? null
                      : _submitInApp,
                  child: isSubmittingApplication.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm & Submit Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _submitInApp() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      isSubmittingApplication.value = true;

      final application = ApplicationModel(
        id: const Uuid().v4(),
        internshipId: internship.id,
        studentId: user.id,
        studentName: user.name,
        internshipTitle: internship.title,
        companyId: internship.companyId,
        companyName: internship.companyName,
        companyLogo: internship.logoUrl,
        status: 'Applied',
        appliedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        applicationType: 'in_app',
        coverLetter: coverLetterController.text.trim(),
        notes: 'Submitted via Interme Trust Marketplace',
        statusUpdates: [
          {
            'status': 'Applied',
            'timestamp': DateTime.now().toIso8601String(),
            'remarks': 'Application submitted and queued for recruiter review.',
          },
        ],
      );

      await _service.submitApplication(application);
      hasAlreadyApplied.value = true;
      Get.back(); // Close modal

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF006C49), size: 28),
              SizedBox(width: 10),
              Text('Application Sent!'),
            ],
          ),
          content: Text(
            'Your application for ${internship.title} at ${internship.companyName} has been submitted.\n\nYou can monitor status updates in real-time under My Applications.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Application Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingApplication.value = false;
    }
  }

  @override
  void onClose() {
    coverLetterController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
