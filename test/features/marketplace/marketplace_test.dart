import 'package:flutter_test/flutter_test.dart';
import 'package:internme/data/models/internship_model.dart';
import 'package:internme/data/models/company_model.dart';
import 'package:internme/data/models/application_model.dart';
import 'package:internme/data/models/saved_internship_model.dart';
import 'package:internme/features/marketplace/models/marketplace_filter_model.dart';
import 'package:internme/features/marketplace/services/trust_score_calculator.dart';

void main() {
  group('InternshipModel Tests', () {
    test('Model deserializes correctly from JSON and sets default values', () {
      final json = {
        'id': 'test_01',
        'title': 'Flutter Developer Intern',
        'companyName': 'TechPulse Systems',
        'location': 'Remote',
        'stipend': 25000,
        'trustScore': 98.0,
        'isVerified': true,
        'skills': ['Flutter', 'Dart', 'Firebase'],
        'deadline': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'status': 'active',
      };

      final model = InternshipModel.fromJson(json);

      expect(model.id, 'test_01');
      expect(model.title, 'Flutter Developer Intern');
      expect(model.companyName, 'TechPulse Systems');
      expect(model.stipend, 25000.0);
      expect(model.isVerified, true);
      expect(model.trustScore, 98.0);
      expect(model.skills, contains('Flutter'));
      expect(model.isExpired, false);
      expect(model.isClosingSoon, false);
    });

    test('isClosingSoon returns true when deadline is within 14 days', () {
      final model = InternshipModel(
        id: 'test_closing',
        title: 'Backend Intern',
        companyName: 'CloudCorp',
        location: 'Remote',
        stipend: 15000,
        description: 'Test',
        deadline: DateTime.now().add(const Duration(days: 5)),
      );

      expect(model.isExpired, false);
      expect(model.isClosingSoon, true);
      expect(model.daysRemaining, inInclusiveRange(4, 5));
    });

    test('isExpired returns true when deadline has passed', () {
      final model = InternshipModel(
        id: 'test_expired',
        title: 'Data Intern',
        companyName: 'DataCorp',
        location: 'Remote',
        stipend: 10000,
        description: 'Test',
        deadline: DateTime.now().subtract(const Duration(days: 2)),
      );

      expect(model.isExpired, true);
      expect(model.isClosingSoon, false);
    });
  });

  group('TrustScoreCalculator Tests', () {
    test('Returns null score and unverified status when listing is unverified', () {
      final unverifiedInternship = InternshipModel(
        id: 'unverified_01',
        title: 'Marketing Intern',
        companyName: 'Random Agency',
        location: 'Remote',
        stipend: 5000,
        description: 'Great role for marketing enthusiasts.',
        isVerified: false,
        trustScore: null,
      );

      final unverifiedCompany = CompanyModel(
        id: 'company_unverified',
        companyName: 'Random Agency',
        verificationStatus: 'unverified',
      );

      final result = TrustScoreCalculator.evaluate(
        internship: unverifiedInternship,
        company: unverifiedCompany,
      );

      expect(result.isVerified, false);
      expect(result.score, isNull);
      expect(result.statusSummary, 'Unverified Employer');
      expect(result.evidenceItems.any((e) => !e.isPassed), true);
    });

    test('Evaluates legitimate verified company with high trust score', () {
      final verifiedInternship = InternshipModel(
        id: 'verified_01',
        title: 'Security Intern',
        companyName: 'SecureNet Hub',
        location: 'Pune',
        stipend: 30000,
        description: 'Perform web application security tests.',
        responsibilities: ['Audit APIs', 'Verify OWASP rules'],
        isVerified: true,
        trustScore: 99.0,
      );

      final verifiedCompany = CompanyModel(
        id: 'company_securenet',
        companyName: 'SecureNet Hub',
        website: 'https://securenethub.net',
        verificationStatus: 'verified',
        verificationEvidence: 'MCA Legal Active, GSTIN Verified',
      );

      final result = TrustScoreCalculator.evaluate(
        internship: verifiedInternship,
        company: verifiedCompany,
      );

      expect(result.isVerified, true);
      expect(result.score, 99.0);
      expect(result.evidenceItems.length, greaterThanOrEqualTo(4));
      expect(result.evidenceItems.every((e) => e.isPassed), true);
    });
  });

  group('MarketplaceFilterModel Tests', () {
    test('Correctly calculates active filter count', () {
      final filter = MarketplaceFilterModel();
      expect(filter.activeFiltersCount, 0);

      filter.selectedCategory = 'AI/ML';
      expect(filter.activeFiltersCount, 1);

      filter.selectedWorkModes.add('Remote');
      expect(filter.activeFiltersCount, 2);

      filter.stipendType = 'Paid';
      expect(filter.activeFiltersCount, 3);

      filter.verifiedOnly = true;
      expect(filter.activeFiltersCount, 4);

      filter.reset();
      expect(filter.activeFiltersCount, 0);
      expect(filter.selectedCategory, 'All');
      expect(filter.selectedWorkModes, isEmpty);
      expect(filter.verifiedOnly, false);
    });
  });

  group('ApplicationModel & SavedInternshipModel Tests', () {
    test('ApplicationModel formats appliedDate and updates correctly', () {
      final app = ApplicationModel(
        id: 'app_001',
        internshipId: 'internship_001',
        studentId: 'student_123',
        internshipTitle: 'Flutter Developer',
        companyName: 'TechPulse Systems',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(app.appliedDate, 'Just now');
      expect(app.status, 'Applied');

      final updated = app.copyWith(status: 'Under Review');
      expect(updated.status, 'Under Review');
    });

    test('SavedInternshipModel checks expiration correctly', () {
      final saved = SavedInternshipModel(
        id: 'student1_intern1',
        studentId: 'student1',
        internshipId: 'intern1',
        companyId: 'company1',
        title: 'Flutter Developer',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(saved.isExpired, true);
    });
  });
}

