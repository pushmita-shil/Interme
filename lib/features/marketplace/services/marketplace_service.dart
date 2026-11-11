import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../data/models/internship_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/saved_internship_model.dart';
import '../../../data/models/application_model.dart';
import '../models/marketplace_filter_model.dart';

class PaginatedInternshipsResult {
  final List<InternshipModel> internships;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedInternshipsResult({
    required this.internships,
    this.lastDocument,
    required this.hasMore,
  });
}

class MarketplaceService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _internshipsCol =>
      _firestore.collection('internships');
  CollectionReference<Map<String, dynamic>> get _companiesCol =>
      _firestore.collection('companies');
  CollectionReference<Map<String, dynamic>> get _savedCol =>
      _firestore.collection('saved_internships');
  CollectionReference<Map<String, dynamic>> get _applicationsCol =>
      _firestore.collection('applications');

  @override
  void onInit() {
    super.onInit();
    // Auto-seed real Firestore documents if collection is unpopulated
    ensureSeedData();
  }

  /// Fetches internships with pagination and filter criteria
  Future<PaginatedInternshipsResult> fetchInternships({
    int pageSize = 10,
    DocumentSnapshot? startAfterDoc,
    MarketplaceFilterModel? filter,
  }) async {
    try {
      debugPrint('MarketplaceService: Querying Firestore internships collection...');
      
      Query<Map<String, dynamic>> query = _internshipsCol.where('status', isEqualTo: 'active');

      if (filter != null) {
        if (filter.selectedCategory != 'All') {
          query = query.where('category', isEqualTo: filter.selectedCategory);
        }
        if (filter.verifiedOnly) {
          query = query.where('isVerified', isEqualTo: true);
        }
      }

      // Order by createdAt descending for fresh listings
      query = query.orderBy('createdAt', descending: true);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      // Fetch a bit more to handle client-side multi-filter refinement safely
      final fetchLimit = pageSize * 2;
      query = query.limit(fetchLimit);

      final snapshot = await query.get();
      debugPrint('MarketplaceService: Fetched ${snapshot.docs.length} raw docs from Firestore');

      List<InternshipModel> items = snapshot.docs.map((doc) {
        return InternshipModel.fromJson(doc.data(), docId: doc.id);
      }).toList();

      // Apply in-memory refinement for composite query dimensions (stipend, workMode, search)
      if (filter != null) {
        items = _applyFilterInMemory(items, filter);
      }

      final hasMore = snapshot.docs.length >= fetchLimit;
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      // Slice to pageSize
      final pagedItems = items.take(pageSize).toList();

      return PaginatedInternshipsResult(
        internships: pagedItems,
        lastDocument: lastDoc,
        hasMore: hasMore,
      );
    } catch (e, stackTrace) {
      debugPrint('MarketplaceService fetchInternships error: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Fetches Featured Internships designated by admins in Firestore
  Future<List<InternshipModel>> fetchFeaturedInternships({int limit = 5}) async {
    try {
      final snapshot = await _internshipsCol
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return InternshipModel.fromJson(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('MarketplaceService fetchFeaturedInternships error: $e');
      return [];
    }
  }

  /// Fetches Closing Soon active internships
  Future<List<InternshipModel>> fetchClosingSoonInternships({int limit = 6}) async {
    try {
      final now = DateTime.now();
      final maxDate = now.add(const Duration(days: 14));

      final snapshot = await _internshipsCol
          .where('status', isEqualTo: 'active')
          .where('deadline', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(maxDate))
          .orderBy('deadline')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return InternshipModel.fromJson(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('MarketplaceService fetchClosingSoon error: $e');
      // Fallback query if composite index is pending
      final snapshot = await _internshipsCol
          .where('status', isEqualTo: 'active')
          .limit(20)
          .get();
      return snapshot.docs
          .map((doc) => InternshipModel.fromJson(doc.data(), docId: doc.id))
          .where((i) => i.isClosingSoon)
          .take(limit)
          .toList();
    }
  }

  /// Fetches recently added active internships
  Future<List<InternshipModel>> fetchRecentlyAdded({int limit = 6}) async {
    try {
      final snapshot = await _internshipsCol
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return InternshipModel.fromJson(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('MarketplaceService fetchRecentlyAdded error: $e');
      return [];
    }
  }

  /// Fetches specific company profile from `companies` collection
  Future<CompanyModel?> fetchCompany(String companyId) async {
    try {
      if (companyId.isEmpty) return null;
      final doc = await _companiesCol.doc(companyId).get();
      if (doc.exists && doc.data() != null) {
        return CompanyModel.fromJson(doc.data()!, docId: doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('MarketplaceService fetchCompany error: $e');
      return null;
    }
  }

  // -------------------------------------------------------------
  // SAVED INTERNSHIPS (BOOKMARKING)
  // -------------------------------------------------------------

  /// Stream of saved internship IDs for real-time reactivity in student UI
  Stream<List<SavedInternshipModel>> streamSavedInternships(String studentId) {
    if (studentId.isEmpty) return Stream.value([]);
    return _savedCol
        .where('studentId', isEqualTo: studentId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SavedInternshipModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  /// Toggles saving an internship in Firestore
  Future<bool> toggleSaveInternship({
    required String studentId,
    required InternshipModel internship,
  }) async {
    if (studentId.isEmpty) {
      throw Exception('Student must be authenticated to save opportunities.');
    }

    final docId = '${studentId}_${internship.id}';
    final docRef = _savedCol.doc(docId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      // Remove bookmark
      await docRef.delete();
      debugPrint('MarketplaceService: Bookmark removed for ${internship.id}');
      return false;
    } else {
      // Add bookmark
      final bookmark = SavedInternshipModel(
        id: docId,
        studentId: studentId,
        internshipId: internship.id,
        companyId: internship.companyId,
        savedAt: DateTime.now(),
        title: internship.title,
        companyName: internship.companyName,
        companyLogo: internship.logoUrl,
        stipend: internship.stipend,
        workMode: internship.workMode,
        location: internship.location,
        deadline: internship.deadline,
        isVerified: internship.isVerified,
        trustScore: internship.trustScore,
      );
      await docRef.set(bookmark.toJson());
      debugPrint('MarketplaceService: Bookmark added for ${internship.id}');
      return true;
    }
  }

  /// Removes a saved internship directly
  Future<void> removeSavedInternship(String studentId, String internshipId) async {
    final docId = '${studentId}_$internshipId';
    await _savedCol.doc(docId).delete();
  }

  // -------------------------------------------------------------
  // APPLICATION WORKFLOW
  // -------------------------------------------------------------

  /// Checks whether a student has already applied to an internship
  Future<bool> hasAlreadyApplied(String studentId, String internshipId) async {
    if (studentId.isEmpty || internshipId.isEmpty) return false;
    final query = await _applicationsCol
        .where('studentId', isEqualTo: studentId)
        .where('internshipId', isEqualTo: internshipId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Submits an application to Cloud Firestore
  Future<void> submitApplication(ApplicationModel application) async {
    if (application.studentId.isEmpty) {
      throw Exception('Authentication required. Please sign in as a student.');
    }

    // Atomic double-check
    final already = await hasAlreadyApplied(application.studentId, application.internshipId);
    if (already) {
      throw Exception('You have already submitted an application for this position.');
    }

    final docRef = _applicationsCol.doc(application.id);
    await docRef.set(application.toJson());
    debugPrint('MarketplaceService: Application submitted successfully: ${application.id}');
  }

  /// Stream of student's applications from Cloud Firestore
  Stream<List<ApplicationModel>> streamStudentApplications(String studentId) {
    if (studentId.isEmpty) return Stream.value([]);
    return _applicationsCol
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ApplicationModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  // -------------------------------------------------------------
  // CLIENT-SIDE MULTI-DIMENSIONAL FILTERING HELPER
  // -------------------------------------------------------------
  List<InternshipModel> _applyFilterInMemory(
    List<InternshipModel> items,
    MarketplaceFilterModel filter,
  ) {
    return items.where((i) {
      // Search text query
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase().trim();
        final matchTitle = i.title.toLowerCase().contains(query);
        final matchComp = i.companyName.toLowerCase().contains(query);
        final matchLoc = i.location.toLowerCase().contains(query);
        final matchMode = i.workMode.toLowerCase().contains(query);
        final matchSkill = i.skills.any((s) => s.toLowerCase().contains(query));
        if (!matchTitle && !matchComp && !matchLoc && !matchMode && !matchSkill) {
          return false;
        }
      }

      // Work Mode filter
      if (filter.selectedWorkModes.isNotEmpty) {
        final normalizedMode = i.workMode.toLowerCase();
        final matches = filter.selectedWorkModes.any((m) =>
            normalizedMode.contains(m.toLowerCase()) || m.toLowerCase().contains(normalizedMode));
        if (!matches) return false;
      }

      // Stipend type
      if (filter.stipendType == 'Paid' && (i.stipend <= 0 || i.stipendType == 'Unpaid')) {
        return false;
      }
      if (filter.stipendType == 'Unpaid' && (i.stipend > 0 && i.stipendType == 'Paid')) {
        return false;
      }

      // Stipend range
      if (i.stipend < filter.minStipend || i.stipend > filter.maxStipend) {
        return false;
      }

      // Duration filter
      if (filter.durationOption != 'All') {
        if (filter.durationOption == '1-3 months' && (i.durationMonths < 1 || i.durationMonths > 3)) {
          return false;
        }
        if (filter.durationOption == '3-6 months' && (i.durationMonths < 3 || i.durationMonths > 6)) {
          return false;
        }
        if (filter.durationOption == '6+ months' && i.durationMonths < 6) {
          return false;
        }
      }

      // Experience Level
      if (filter.experienceLevel != 'All') {
        if (i.experienceLevel.toLowerCase() != filter.experienceLevel.toLowerCase()) {
          return false;
        }
      }

      // Deadline filter
      if (filter.deadlineFilter == 'Closing Soon' && !i.isClosingSoon) {
        return false;
      }
      if (filter.deadlineFilter == 'Upcoming' && i.isExpired) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (filter.sortOption) {
          case MarketplaceSortOption.highestStipend:
            return b.stipend.compareTo(a.stipend);
          case MarketplaceSortOption.recentlyAdded:
            return b.createdAt.compareTo(a.createdAt);
          case MarketplaceSortOption.deadlineApproaching:
            return a.deadline.compareTo(b.deadline);
          case MarketplaceSortOption.mostRelevant:
            return 0;
        }
      });
  }

  // -------------------------------------------------------------
  // AUTOMATIC INITIAL FIRESTORE SYNC & SEEDING
  // -------------------------------------------------------------
  Future<void> ensureSeedData() async {
    try {
      final snap = await _internshipsCol.limit(1).get();
      if (snap.docs.isNotEmpty) {
        debugPrint('MarketplaceService: Firestore already has internship documents.');
        return;
      }

      debugPrint('MarketplaceService: Populating initial Firestore collections...');

      // 1. Seed companies
      final seedCompanies = [
        CompanyModel(
          id: 'company_techpulse',
          companyName: 'TechPulse Systems',
          logo: 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=150',
          description:
              'TechPulse Systems is a leading enterprise mobility and cloud engineering partner providing next-gen architectures and Flutter applications worldwide.',
          website: 'https://techpulsesystems.com',
          industry: 'Software Development & IT',
          headquarters: 'Bangalore, India',
          companySize: '250-500 employees',
          verificationStatus: 'verified',
          verifiedAt: DateTime.now().subtract(const Duration(days: 90)),
          verificationEvidence: 'MCA Legal Active (CIN: U72900KA2020PTC123456), GSTIN Verified, Domain Verified',
        ),
        CompanyModel(
          id: 'company_auradesign',
          companyName: 'Aura Design Studio',
          logo: 'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?w=150',
          description:
              'Aura Design Studio crafts accessible, intuitive user interfaces and human-centered design systems for global tech leaders and fintech apps.',
          website: 'https://auradesign.io',
          industry: 'Product Design & UI/UX',
          headquarters: 'Hyderabad, India',
          companySize: '50-100 employees',
          verificationStatus: 'verified',
          verifiedAt: DateTime.now().subtract(const Duration(days: 45)),
          verificationEvidence: 'MCA Certificate of Incorporation, Active GSTIN, Dribbble & Behance Certified',
        ),
        CompanyModel(
          id: 'company_securenet',
          companyName: 'SecureNet Hub',
          logo: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=150',
          description:
              'SecureNet Hub specializes in offensive security audits, compliance verification, and penetration testing for financial infrastructure.',
          website: 'https://securenethub.net',
          industry: 'Cybersecurity & Infrastructure',
          headquarters: 'Pune, India',
          companySize: '100-250 employees',
          verificationStatus: 'verified',
          verifiedAt: DateTime.now().subtract(const Duration(days: 60)),
          verificationEvidence: 'ISO 27001 Certified, MCA Verified, CERT-In Impanelled Partner',
        ),
        CompanyModel(
          id: 'company_dataminds',
          companyName: 'DataMinds Analytics',
          logo: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150',
          description:
              'DataMinds empowers enterprises with predictive machine learning models, natural language processing pipelines, and big data visualization.',
          website: 'https://dataminds.ai',
          industry: 'Artificial Intelligence & Big Data',
          headquarters: 'Mumbai, India',
          companySize: '150-300 employees',
          verificationStatus: 'verified',
          verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
          verificationEvidence: 'MCA Legal Active, IEEE Sponsor, Verified Corporate Recruiter',
        ),
        CompanyModel(
          id: 'company_growthhive',
          companyName: 'GrowthHive Agency',
          logo: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=150',
          description:
              'Performance marketing agency scaling brands through content marketing, search engine optimization, and data-driven customer acquisition.',
          website: 'https://growthhive.co',
          industry: 'Digital Marketing & Growth',
          headquarters: 'Delhi NCR, India',
          companySize: '20-50 employees',
          verificationStatus: 'unverified',
          verifiedAt: null,
          verificationEvidence: null,
        ),
      ];

      for (final c in seedCompanies) {
        await _companiesCol.doc(c.id).set(c.toJson());
      }

      // 2. Seed internships
      final seedInternships = [
        InternshipModel(
          id: 'internship_001',
          title: 'Flutter Developer Intern',
          companyId: 'company_techpulse',
          companyName: 'TechPulse Systems',
          logoUrl: 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=150',
          category: 'Software Development',
          description:
              'We are looking for an ambitious Flutter Developer Intern to build cross-platform mobile apps using Flutter and GetX. You will collaborate with experienced engineers, write clean modular Dart code, and participate in sprint planning.',
          responsibilities: [
            'Develop responsive, pixel-perfect user interfaces with Flutter',
            'Integrate REST APIs and Firebase Firestore authentication services',
            'Implement state management using GetX controllers and bindings',
            'Write clean Dart code with automated unit and widget tests',
          ],
          requirements: [
            'Proficiency in Dart programming and Flutter framework',
            'Familiarity with state management libraries (GetX/Bloc)',
            'Understanding of Git version control',
          ],
          skills: ['Flutter', 'Dart', 'Firebase', 'GetX', 'REST API'],
          location: 'Remote',
          workMode: 'Remote',
          stipend: 25000,
          stipendType: 'Paid',
          duration: '3 Months',
          durationMonths: 3,
          experienceLevel: 'Beginner',
          eligibility: [
            'B.Tech / B.E. / BCA / MCA in Computer Science or related fields',
            'Graduating between 2025 and 2027',
            'Available for a full-time 3-month remote commitment',
          ],
          benefits: [
            'Certificate of completion & Letter of Recommendation',
            'Flexible working hours with 1-on-1 mentorship',
            'Full-time PPO opportunity based on performance',
          ],
          applicationUrl: '',
          applicationType: 'in_app',
          deadline: DateTime.now().add(const Duration(days: 28)),
          isFeatured: true,
          isVerified: true,
          trustScore: 98.0,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          trustEvidence: {
            'mcaVerified': true,
            'officialDomain': true,
            'noFee': true,
          },
        ),
        InternshipModel(
          id: 'internship_002',
          title: 'Machine Learning Research Intern',
          companyId: 'company_dataminds',
          companyName: 'DataMinds Analytics',
          logoUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150',
          category: 'AI/ML',
          description:
              'Join DataMinds to work on computer vision, LLM prompt engineering, and deep learning pipelines. You will evaluate cutting-edge open-source transformer models and run benchmarking on proprietary datasets.',
          responsibilities: [
            'Assist in data preprocessing, feature engineering, and model evaluation',
            'Fine-tune open-source models using PyTorch and HuggingFace',
            'Document experiment metrics and present findings to data science leads',
          ],
          requirements: [
            'Strong foundation in Python and linear algebra',
            'Hands-on experience with PyTorch or TensorFlow',
            'Familiarity with Pandas and Scikit-Learn',
          ],
          skills: ['Python', 'PyTorch', 'Machine Learning', 'TensorFlow', 'Pandas'],
          location: 'Remote',
          workMode: 'Remote',
          stipend: 35000,
          stipendType: 'Paid',
          duration: '6 Months',
          durationMonths: 6,
          experienceLevel: 'Intermediate',
          eligibility: [
            'Degree in Computer Science, AI, Mathematics, or Data Science',
            'Minimum 7.5 CGPA or equivalent portfolio',
          ],
          benefits: [
            'Access to dedicated GPU compute clusters',
            'Co-authorship on research publications',
            'High-conversion PPO pathway',
          ],
          applicationUrl: '',
          applicationType: 'in_app',
          deadline: DateTime.now().add(const Duration(days: 10)), // Closing soon!
          isFeatured: true,
          isVerified: true,
          trustScore: 96.0,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          trustEvidence: {
            'mcaVerified': true,
            'officialDomain': true,
            'noFee': true,
          },
        ),
        InternshipModel(
          id: 'internship_003',
          title: 'UI/UX Product Design Intern',
          companyId: 'company_auradesign',
          companyName: 'Aura Design Studio',
          logoUrl: 'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?w=150',
          category: 'UI/UX',
          description:
              'Work closely with senior designers to build modern glassmorphism design systems, interactive prototypes, and usability testing workflows for top tech companies.',
          responsibilities: [
            'Create high-fidelity wireframes and interactive Figma prototypes',
            'Conduct user interviews and synthesize feedback into design iterations',
            'Maintain component libraries and design tokens',
          ],
          requirements: [
            'Strong portfolio showcasing UI/UX case studies',
            'Deep expertise in Figma, Auto Layout, and Component Variants',
          ],
          skills: ['Figma', 'UI Design', 'Prototyping', 'User Research', 'Design Systems'],
          location: 'Hyderabad',
          workMode: 'Hybrid',
          stipend: 20000,
          stipendType: 'Paid',
          duration: '3 Months',
          durationMonths: 3,
          experienceLevel: 'Beginner',
          eligibility: [
            'Design / Engineering students with an active portfolio',
            'Available for hybrid work in Hyderabad office 2 days/week',
          ],
          benefits: [
            'Mentorship from former lead designers at Fortune 500 tech companies',
            'Hardware allowance for design tools',
          ],
          applicationUrl: '',
          applicationType: 'in_app',
          deadline: DateTime.now().add(const Duration(days: 6)), // Closing soon!
          isFeatured: false,
          isVerified: true,
          trustScore: 94.0,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          trustEvidence: {
            'mcaVerified': true,
            'officialDomain': true,
            'noFee': true,
          },
        ),
        InternshipModel(
          id: 'internship_004',
          title: 'Cybersecurity Analyst Intern',
          companyId: 'company_securenet',
          companyName: 'SecureNet Hub',
          logoUrl: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=150',
          category: 'Cybersecurity',
          description:
              'Support vulnerability assessment teams in auditing web applications, running automated penetration testing scripts, and reporting security anomalies.',
          responsibilities: [
            'Perform web application vulnerability scans according to OWASP Top 10',
            'Draft remediation advisories and verify bug fixes',
            'Simulate phishing drills and monitor SIEM log telemetry',
          ],
          requirements: [
            'Understanding of TCP/IP, DNS, and HTTP/HTTPS network fundamentals',
            'Basic scripting in Python or Bash',
            'Interest in ethical hacking and penetration testing',
          ],
          skills: ['OWASP', 'Linux', 'Network Security', 'Python', 'Ethical Hacking'],
          location: 'Pune',
          workMode: 'On-site',
          stipend: 30000,
          stipendType: 'Paid',
          duration: '6 Months',
          durationMonths: 6,
          experienceLevel: 'Intermediate',
          eligibility: [
            'B.Tech / BCA in IT / Cyber Security or equivalent certifications (CEH/CompTIA)',
          ],
          benefits: [
            'Hands-on lab environments with industrial penetration tools',
            'Full certification sponsorship for top performers',
          ],
          applicationUrl: '',
          applicationType: 'in_app',
          deadline: DateTime.now().add(const Duration(days: 20)),
          isFeatured: true,
          isVerified: true,
          trustScore: 99.0,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          trustEvidence: {
            'mcaVerified': true,
            'officialDomain': true,
            'noFee': true,
          },
        ),
        InternshipModel(
          id: 'internship_005',
          title: 'Digital Marketing & Content Intern',
          companyId: 'company_growthhive',
          companyName: 'GrowthHive Agency',
          logoUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=150',
          category: 'Marketing',
          description:
              'Create engaging social media campaigns, write SEO-optimized blog posts, and assist in managing client email newsletters across social channels.',
          responsibilities: [
            'Draft blog posts and social content calendars',
            'Analyze audience engagement metrics using Google Analytics',
            'Support outreach campaigns for content partnerships',
          ],
          requirements: [
            'Strong English copywriting and communication skills',
            'Basic knowledge of SEO and social media algorithms',
          ],
          skills: ['Copywriting', 'SEO', 'Social Media', 'Content Strategy'],
          location: 'Remote',
          workMode: 'Remote',
          stipend: 12000,
          stipendType: 'Paid',
          duration: '3 Months',
          durationMonths: 3,
          experienceLevel: 'Beginner',
          eligibility: [
            'Open to all undergraduate disciplines with strong writing proficiency',
          ],
          benefits: [
            'Experience working directly on live client brands',
            'Flexible remote hours',
          ],
          applicationUrl: 'https://growthhive.co/careers/internship',
          applicationType: 'external',
          deadline: DateTime.now().add(const Duration(days: 15)),
          isFeatured: false,
          isVerified: false, // Unverified - demonstrates genuine verification distinction!
          trustScore: null, // Null trust score because it is unverified!
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      for (final i in seedInternships) {
        await _internshipsCol.doc(i.id).set(i.toJson());
      }

      debugPrint('MarketplaceService: Initial Firestore seeding completed with 5 listings & companies.');
    } catch (e) {
      debugPrint('MarketplaceService: Seed check completed: $e');
    }
  }
}
