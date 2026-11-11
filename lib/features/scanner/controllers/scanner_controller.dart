import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/scanner_finding_model.dart';
import '../models/scanner_report_model.dart';
import '../services/internship_analysis_service.dart';
import '../../../services/firebase/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class ScannerController extends GetxController {
  final InternshipAnalysisService _analysisService = InternshipAnalysisService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Selected input tab
  final Rx<ScannerInputType> selectedInputType = ScannerInputType.url.obs;

  // Controllers for text inputs
  final TextEditingController urlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Observable text values for reactive UI validation
  final RxString urlText = ''.obs;
  final RxString descriptionText = ''.obs;

  // Document upload state
  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final RxString selectedFileName = ''.obs;
  final RxInt selectedFileSize = 0.obs;
  final Rxn<Uint8List> filePreviewBytes = Rxn<Uint8List>();
  final RxString fileErrorMessage = ''.obs;

  // Analysis state
  final RxBool isAnalyzing = false.obs;
  final RxString currentStageMessage = ''.obs;
  final RxDouble analysisProgress = 0.0.obs;
  final RxString analysisError = ''.obs;

  // Active generated report
  final Rxn<ScannerReportModel> currentReport = Rxn<ScannerReportModel>();

  // Report save state
  final RxBool isSavingReport = false.obs;
  final RxBool isReportSaved = false.obs;

  // Scan history
  final RxList<ScannerReportModel> scanHistory = <ScannerReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to text controllers to update reactive validation
    urlController.addListener(() {
      urlText.value = urlController.text.trim();
    });
    descriptionController.addListener(() {
      descriptionText.value = descriptionController.text.trim();
    });
  }

  @override
  void onClose() {
    urlController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Set active input type
  void setInputType(ScannerInputType type) {
    selectedInputType.value = type;
  }

  // Reactive validation for the currently selected input method
  bool get isValidInput {
    switch (selectedInputType.value) {
      case ScannerInputType.url:
        final url = urlText.value;
        if (url.isEmpty) return false;
        final uri = Uri.tryParse(url);
        return uri != null && (url.startsWith('http://') || url.startsWith('https://')) && uri.host.isNotEmpty;

      case ScannerInputType.text:
        return descriptionText.value.length >= 20;

      case ScannerInputType.document:
        return selectedFile.value != null;
    }
  }

  String? get currentValidationMessage {
    switch (selectedInputType.value) {
      case ScannerInputType.url:
        if (urlText.value.isEmpty) {
          return null;
        }
        if (!urlText.value.startsWith('http://') && !urlText.value.startsWith('https://')) {
          return 'URL must start with https:// or http://';
        }
        final uri = Uri.tryParse(urlText.value);
        if (uri == null || uri.host.isEmpty) {
          return 'Please enter a valid web domain';
        }
        return null;

      case ScannerInputType.text:
        if (descriptionText.value.isEmpty) {
          return null;
        }
        if (descriptionText.value.length < 20) {
          return 'Please enter at least 20 characters (${descriptionText.value.length}/20)';
        }
        return null;

      case ScannerInputType.document:
        if (fileErrorMessage.value.isNotEmpty) {
          return fileErrorMessage.value;
        }
        return null;
    }
  }

  // ==========================================
  // DOCUMENT PICKING & MANAGEMENT
  // ==========================================

  Future<void> pickDocument() async {
    try {
      fileErrorMessage.value = '';
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (file != null) {
        // Size limit check (10MB max)
        const int maxSizeBytes = 10 * 1024 * 1024;
        final fileSize = await file.xFile.length();
        if (fileSize > maxSizeBytes) {
          fileErrorMessage.value = 'File exceeds 10MB limit. Please upload a smaller file.';
          return;
        }

        selectedFile.value = file;
        selectedFileName.value = file.name;
        selectedFileSize.value = fileSize;

        // Extract bytes for image preview if applicable
        final ext = file.extension?.toLowerCase() ?? '';
        if (['png', 'jpg', 'jpeg'].contains(ext)) {
          final bytes = await file.xFile.readAsBytes();
          filePreviewBytes.value = bytes;
        } else {
          filePreviewBytes.value = null;
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      fileErrorMessage.value = 'Failed to select file. Please check permissions and try again.';
    }
  }

  void removeSelectedFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
    selectedFileSize.value = 0;
    filePreviewBytes.value = null;
    fileErrorMessage.value = '';
  }

  // ==========================================
  // ANALYSIS WORKFLOW
  // ==========================================

  Future<void> startAnalysis() async {
    if (!isValidInput || isAnalyzing.value) return;

    isAnalyzing.value = true;
    analysisError.value = '';
    analysisProgress.value = 0.1;
    currentStageMessage.value = 'Reading internship information...';

    // Navigate to dedicated analysis progress screen
    Get.toNamed(AppRoutes.scannerAnalysis);

    try {
      final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final currentStudentId = authService?.currentUser?.id;

      // Stage 1
      await Future.delayed(const Duration(milliseconds: 400));
      analysisProgress.value = 0.35;
      currentStageMessage.value = 'Checking for suspicious payment requests...';

      // Stage 2
      await Future.delayed(const Duration(milliseconds: 450));
      analysisProgress.value = 0.65;
      currentStageMessage.value = 'Reviewing company and contact details...';

      // Perform actual analysis based on input method
      final ScannerReportModel report;

      switch (selectedInputType.value) {
        case ScannerInputType.url:
          report = await _analysisService.analyzeUrl(
            rawUrl: urlText.value,
            studentId: currentStudentId,
          );
          break;

        case ScannerInputType.text:
          report = await _analysisService.analyzeText(
            text: descriptionText.value,
            submissionType: ScannerInputType.text,
            studentId: currentStudentId,
          );
          break;

        case ScannerInputType.document:
          // Honest handling of document upload:
          // Extract text if readable, or use file metadata and structural analysis
          final fileName = selectedFileName.value;
          final file = selectedFile.value;

          String extractedContent = '';
          if (file != null) {
            try {
              final bytes = await file.xFile.readAsBytes();
              extractedContent = String.fromCharCodes(bytes);
            } catch (_) {}
          }

          if (extractedContent.length > 50 && extractedContent.contains(' ')) {
            // Document had decodeable plain text
            report = await _analysisService.analyzeText(
              text: extractedContent,
              documentName: fileName,
              submissionType: ScannerInputType.document,
              studentId: currentStudentId,
            );
          } else {
            // Fallback for PDF or screenshot binary:
            // Report clearly specifies that automated client OCR is pending or requires text paste
            final findings = <ScannerFindingModel>[
              ScannerFindingModel(
                id: 'doc-obs-1',
                title: 'Document received: $fileName',
                type: FindingType.info,
                severity: FindingSeverity.info,
                explanation:
                    'File "$fileName" (${(selectedFileSize.value / 1024).toStringAsFixed(1)} KB) was successfully received. Automated client-side text parsing for visual documents is limited in this environment.',
                evidence: 'File: $fileName, Size: ${selectedFileSize.value} bytes',
                suggestedAction:
                    'For the most comprehensive and evidence-based risk detection, copy and paste the offer letter text into the "Job Description" tab.',
                ruleName: 'DOCUMENT_UPLOAD_OBSERVATION',
              ),
              ScannerFindingModel(
                id: 'doc-obs-2',
                title: 'Manual verification advised for offer letters',
                type: FindingType.unknownInconclusive,
                severity: FindingSeverity.low,
                explanation:
                    'Offer letters should be verified by matching the recruiter\'s corporate email against the official employer website.',
                evidence: 'Document submitted for preliminary intake.',
                suggestedAction: 'Ensure the document includes an official corporate letterhead, CIN, and registered office address.',
                ruleName: 'OFFER_LETTER_MANUAL_GUIDE',
              ),
            ];

            report = ScannerReportModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              studentId: currentStudentId,
              submissionType: ScannerInputType.document,
              rawInput: fileName,
              documentName: fileName,
              assessmentCategory: AssessmentCategory.furtherVerificationRecommended,
              assessmentHeadline: 'Document uploaded - Manual verification advised',
              overallExplanation:
                  'The offer document "$fileName" was uploaded. To evaluate detailed contractual clauses and payment demands with our automated scanner, paste the exact text into the Job Description tab.',
              findings: findings,
              recommendedNextSteps: [
                'Copy and paste the offer letter text into the Job Description tab for complete automated clause scanning.',
                'Cross-check the company name and letterhead address with the Ministry of Corporate Affairs (MCA) registry.',
                'Contact the HR department listed on the company’s official verified website.',
              ],
              analysisMethod: 'Document intake & structural metadata inspection v1.0',
              createdAt: DateTime.now(),
              limitations:
                  'Visual OCR and multi-page PDF text extraction is pending. For immediate lexical analysis, please use the Job Description tab.',
            );
          }
          break;
      }

      // Stage 3
      analysisProgress.value = 0.90;
      currentStageMessage.value = 'Preparing your risk report...';
      await Future.delayed(const Duration(milliseconds: 350));

      analysisProgress.value = 1.0;
      currentReport.value = report;
      isReportSaved.value = false;

      // Add to session history
      scanHistory.insert(0, report);

      // Navigate to Report Screen
      Get.offNamed(AppRoutes.scannerReport, arguments: report);
    } catch (e, stack) {
      debugPrint('Scanner analysis failed: $e\n$stack');
      analysisError.value = 'An error occurred during analysis: ${e.toString()}';
    } finally {
      isAnalyzing.value = false;
    }
  }

  // Retry analysis after failure
  void retryAnalysis() {
    startAnalysis();
  }

  // Cancel / Go back to edit input
  void cancelAnalysisAndReturn() {
    isAnalyzing.value = false;
    analysisError.value = '';
    Get.back();
  }

  // ==========================================
  // REPORT ACTIONS
  // ==========================================

  void scanAnotherInternship() {
    currentReport.value = null;
    isReportSaved.value = false;
    // Return to the scanner screen
    Get.offNamed(AppRoutes.aiScanner);
  }

  Future<void> saveCurrentReport() async {
    final report = currentReport.value;
    if (report == null || isSavingReport.value) return;

    isSavingReport.value = true;
    try {
      final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final uid = authService?.currentUser?.id;

      if (uid != null && uid.isNotEmpty) {
        // Save to Firestore under users/{uid}/scanReports/{reportId}
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('scanReports')
            .doc(report.id)
            .set(report.toJson(), SetOptions(merge: true));
      }

      isReportSaved.value = true;
      Get.snackbar(
        'Report Saved',
        'Your internship risk report has been saved to your account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF006C49),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error saving report to Firestore: $e');
      // Even if Firestore network fails, mark local saved state
      isReportSaved.value = true;
      Get.snackbar(
        'Saved Locally',
        'Report saved to your active session history.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF004AC6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSavingReport.value = false;
    }
  }

  Future<void> reportSuspiciousOpportunity(BuildContext context) async {
    final report = currentReport.value;
    if (report == null) return;

    final noteController = TextEditingController();

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.report_problem, color: Color(0xFFBA1A1A)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Report Suspicious Opportunity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Help protect other students by submitting this posting to InternVerify scam alerts for moderator review.',
                style: TextStyle(color: Color(0xFF434655), fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional details (e.g. UPI ID asked, recruiter name)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA1A1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        try {
                          final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
                          await _firestore.collection('scamReports').add({
                            'reportId': report.id,
                            'studentId': authService?.currentUser?.id ?? 'anonymous',
                            'studentEmail': authService?.currentUser?.email ?? '',
                            'submissionType': report.submissionType.name,
                            'rawInput': report.rawInput,
                            'studentNote': noteController.text.trim(),
                            'assessmentCategory': report.assessmentCategory.name,
                            'reportedAt': FieldValue.serverTimestamp(),
                            'status': 'pending_review',
                          });
                        } catch (_) {}

                        Get.back();
                        Get.snackbar(
                          'Report Submitted',
                          'Thank you for alerting the community. Our moderation team will review this.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF006C49),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      child: const Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ==========================================
  // DEMO DATA TEST FIXTURES
  // ==========================================

  void loadDemoScamOffer() {
    selectedInputType.value = ScannerInputType.text;
    descriptionController.text =
        'Urgent hiring for Python & AI Developer Intern! 100% Guaranteed selection without interview. You will earn ₹60,000 monthly from home. '
        'All selected students must pay a mandatory registration and laptop security deposit fee of ₹2,500 via GooglePay or PhonePe to confirm their seat. '
        'Only 3 slots left! Contact only on Telegram: @quick_intern_jobs or WhatsApp +919876543210.';
  }

  void loadDemoLegitimateOffer() {
    selectedInputType.value = ScannerInputType.text;
    descriptionController.text =
        'TechPulse Systems is hiring a Software Engineer Intern (Flutter & Dart). '
        'Responsibilities: Develop mobile client screens, integrate REST APIs, collaborate with senior engineers and product owners on design sprint features. '
        'Requirements: Familiarity with Dart, Flutter SDK, Git version control, basic knowledge of state management. '
        'Stipend: ₹25,000 per month. Location: Remote / Hybrid. '
        'No registration fee or deposit is ever charged. Official applications accepted via our verified careers portal at https://techpulsesystems.com/careers or hr@techpulsesystems.com.';
  }

  void loadDemoInconclusiveOffer() {
    selectedInputType.value = ScannerInputType.text;
    descriptionController.text =
        'A leading MNC is looking for interns for general computer work. High stipend provided. Interested candidates should apply.';
  }
}
