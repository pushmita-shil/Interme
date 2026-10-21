import 'package:flutter_test/flutter_test.dart';
import 'package:internme/features/scanner/services/internship_analysis_service.dart';
import 'package:internme/features/scanner/models/scanner_report_model.dart';
import 'package:internme/features/scanner/models/scanner_finding_model.dart';

void main() {
  late InternshipAnalysisService service;

  setUp(() {
    service = InternshipAnalysisService();
  });

  group('InternshipAnalysisService Text Analysis Tests', () {
    test('Short input triggers insufficient information category', () async {
      final report = await service.analyzeText(text: 'Looking for an intern');

      expect(report.assessmentCategory, equals(AssessmentCategory.insufficientInformation));
      expect(report.findings.length, equals(1));
      expect(report.findings.first.ruleName, equals('MINIMUM_LENGTH_CHECK'));
    });

    test('Upfront registration fee triggers high severity red flag', () async {
      const text =
          'Exciting internship opportunity! All selected candidates must deposit a registration fee of ₹1500 to secure their training kit. Contact us immediately.';

      final report = await service.analyzeText(text: text);

      expect(report.assessmentCategory, equals(AssessmentCategory.redFlagsDetected));
      final feeFinding = report.findings.firstWhere((f) => f.ruleName == 'UPFRONT_PAYMENT_DETECTION');
      expect(feeFinding.severity, equals(FindingSeverity.high));
      expect(feeFinding.type, equals(FindingType.warning));
      expect(feeFinding.evidence, isNotNull);
      expect(feeFinding.evidence!.toLowerCase(), contains('fee'));
    });

    test('Negative fee mention ("no registration fee") does not trigger upfront fee warning', () async {
      const text =
          'TechPulse Systems is hiring Flutter interns. We have no registration fee or deposit. Stipend: ₹25,000/month. Responsibilities include building UI components and testing.';

      final report = await service.analyzeText(text: text);

      final hasFeeWarning = report.findings.any((f) => f.ruleName == 'UPFRONT_PAYMENT_DETECTION');
      expect(hasFeeWarning, isFalse);
      expect(report.assessmentCategory, isNot(equals(AssessmentCategory.redFlagsDetected)));
    });

    test('Telegram-only recruitment and guaranteed selection trigger warnings', () async {
      const text =
          '100% Guaranteed selection without interview! Work from home. DM on telegram @quick_intern_offers for direct onboarding letter.';

      final report = await service.analyzeText(text: text);

      expect(
        report.findings.any((f) => f.ruleName == 'MESSAGING_APP_ONLY_DETECTION'),
        isTrue,
      );
      expect(
        report.findings.any((f) => f.ruleName == 'UNREALISTIC_PROMISES_DETECTION'),
        isTrue,
      );
    });

    test('Legitimate offer with clear duties triggers no obvious warning signs', () async {
      const text =
          'TechPulse Systems is seeking a Software Engineer Intern. '
          'Responsibilities include developing frontend screens in Flutter, collaborating with UI designers, and participating in agile sprints. '
          'Requirements: Basic Dart knowledge, Git, and computer science background. '
          'Stipend: ₹25,000 monthly. Applications via verified company careers portal.';

      final report = await service.analyzeText(text: text);

      expect(report.assessmentCategory, equals(AssessmentCategory.noObviousWarningSigns));
      expect(
        report.findings.any((f) => f.ruleName == 'JOB_DESCRIPTION_AVAILABLE'),
        isTrue,
      );
    });
  });

  group('InternshipAnalysisService URL Analysis Tests', () {
    test('Malformed URL returns invalid format finding', () async {
      final report = await service.analyzeUrl(rawUrl: 'not_a_valid_url');

      expect(report.assessmentCategory, equals(AssessmentCategory.insufficientInformation));
      expect(report.findings.first.ruleName, equals('URL_SYNTAX_VALIDATOR'));
    });

    test('HTTP link triggers unencrypted protocol warning', () async {
      final report = await service.analyzeUrl(rawUrl: 'http://unsecure-portal.com/apply');

      expect(
        report.findings.any((f) => f.ruleName == 'URL_HTTPS_CHECK' && f.type == FindingType.warning),
        isTrue,
      );
    });

    test('Suspicious TLD like .xyz triggers domain warning', () async {
      final report = await service.analyzeUrl(rawUrl: 'https://internships-apply-fast.xyz/hiring');

      expect(
        report.findings.any((f) => f.ruleName == 'SUSPICIOUS_TLD_CHECK'),
        isTrue,
      );
    });

    test('Shortened URL triggers masked URL warning', () async {
      final report = await service.analyzeUrl(rawUrl: 'https://bit.ly/internship-offer-2026');

      expect(
        report.findings.any((f) => f.ruleName == 'URL_SHORTENER_CHECK'),
        isTrue,
      );
    });
  });
}
