import 'package:cloud_firestore/cloud_firestore.dart';

class InternshipModel {
  final String id;
  final String title;
  final String companyId;
  final String companyName;
  final String logoUrl;
  final String category;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> skills;
  final String location;
  final String workMode; // Remote, Hybrid, Onsite
  final double stipend;
  final String stipendType; // Paid, Unpaid
  final String duration; // e.g. "3 Months"
  final int durationMonths;
  final String experienceLevel; // Beginner, Intermediate
  final List<String> eligibility;
  final List<String> benefits;
  final String applicationUrl;
  final String applicationType; // in_app, external
  final DateTime deadline;
  final bool isFeatured;
  final bool isVerified;
  final double? trustScore; // null if unverified / insufficient evidence
  final String status; // active, closed, expired
  final DateTime createdAt;
  final Map<String, dynamic>? trustEvidence;

  InternshipModel({
    required this.id,
    required this.title,
    this.companyId = '',
    required this.companyName,
    this.logoUrl = '',
    this.category = 'Software Development',
    this.description = '',
    this.responsibilities = const [],
    this.requirements = const [],
    this.skills = const [],
    required this.location,
    String? workMode,
    String? type,
    required this.stipend,
    this.stipendType = 'Paid',
    this.duration = '3 Months',
    this.durationMonths = 3,
    this.experienceLevel = 'Beginner',
    this.eligibility = const [],
    this.benefits = const [],
    this.applicationUrl = '',
    this.applicationType = 'in_app',
    DateTime? deadline,
    this.isFeatured = false,
    this.isVerified = false,
    this.trustScore,
    this.status = 'active',
    DateTime? createdAt,
    this.trustEvidence,
  })  : workMode = workMode ?? type ?? 'Remote',
        deadline = deadline ?? DateTime.now().add(const Duration(days: 30)),
        createdAt = createdAt ?? DateTime.now();

  /// Backward-compatibility alias for `workMode`
  String get type => workMode;

  /// Helper getters for expiration and closing soon
  bool get isExpired => DateTime.now().isAfter(deadline) || status == 'expired';

  bool get isClosingSoon {
    if (isExpired) return false;
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 14;
  }

  int get daysRemaining {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory InternshipModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Parse deadline safely from Timestamp, String, or num
    DateTime parsedDeadline = DateTime.now().add(const Duration(days: 30));
    final rawDeadline = json['deadline'];
    if (rawDeadline is Timestamp) {
      parsedDeadline = rawDeadline.toDate();
    } else if (rawDeadline is String && rawDeadline.isNotEmpty) {
      parsedDeadline = DateTime.tryParse(rawDeadline) ?? parsedDeadline;
    }

    // Parse createdAt safely
    DateTime parsedCreatedAt = DateTime.now();
    final rawCreatedAt = json['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? parsedCreatedAt;
    }

    // Skills & requirements
    final reqs = (json['requirements'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final skillsList = (json['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (reqs.isNotEmpty ? reqs : <String>[]);

    final resps = (json['responsibilities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final elig = (json['eligibility'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final benfs = (json['benefits'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Trust score: only if verified and non-null num
    double? parsedTrustScore;
    if (json['trustScore'] != null && json['trustScore'] is num) {
      final val = (json['trustScore'] as num).toDouble();
      if (val > 0) {
        parsedTrustScore = val;
      }
    }

    final cName = (json['companyName'] as String?) ?? 'Company';
    final fallbackCompId =
        cName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

    final mode = (json['workMode'] as String?) ??
        (json['type'] as String?) ??
        'Remote';

    return InternshipModel(
      id: docId ?? (json['id'] as String? ?? ''),
      title: json['title'] as String? ?? 'Internship Position',
      companyId: json['companyId'] as String? ?? fallbackCompId,
      companyName: cName,
      logoUrl: (json['companyLogo'] as String?) ??
          (json['logoUrl'] as String?) ??
          '',
      category: json['category'] as String? ?? 'Software Development',
      description: json['description'] as String? ?? '',
      responsibilities: resps,
      requirements: reqs,
      skills: skillsList,
      location: json['location'] as String? ?? 'Remote',
      workMode: mode,
      stipend: (json['stipend'] as num?)?.toDouble() ?? 0.0,
      stipendType: json['stipendType'] as String? ??
          ((json['stipend'] as num?)?.toDouble() == 0 ? 'Unpaid' : 'Paid'),
      duration: json['duration'] as String? ?? '3 Months',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 3,
      experienceLevel: json['experienceLevel'] as String? ?? 'Beginner',
      eligibility: elig,
      benefits: benfs,
      applicationUrl: json['applicationUrl'] as String? ?? '',
      applicationType: json['applicationType'] as String? ?? 'in_app',
      deadline: parsedDeadline,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      trustScore: parsedTrustScore,
      status: json['status'] as String? ?? 'active',
      createdAt: parsedCreatedAt,
      trustEvidence: json['trustEvidence'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': logoUrl,
      'logoUrl': logoUrl,
      'category': category,
      'description': description,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'skills': skills,
      'location': location,
      'workMode': workMode,
      'type': workMode,
      'stipend': stipend,
      'stipendType': stipendType,
      'duration': duration,
      'durationMonths': durationMonths,
      'experienceLevel': experienceLevel,
      'eligibility': eligibility,
      'benefits': benefits,
      'applicationUrl': applicationUrl,
      'applicationType': applicationType,
      'deadline': Timestamp.fromDate(deadline),
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'trustScore': trustScore,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'trustEvidence': trustEvidence,
    };
  }

  InternshipModel copyWith({
    String? id,
    String? title,
    String? companyId,
    String? companyName,
    String? logoUrl,
    String? category,
    String? description,
    List<String>? responsibilities,
    List<String>? requirements,
    List<String>? skills,
    String? location,
    String? workMode,
    double? stipend,
    String? stipendType,
    String? duration,
    int? durationMonths,
    String? experienceLevel,
    List<String>? eligibility,
    List<String>? benefits,
    String? applicationUrl,
    String? applicationType,
    DateTime? deadline,
    bool? isFeatured,
    bool? isVerified,
    double? trustScore,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? trustEvidence,
  }) {
    return InternshipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      stipend: stipend ?? this.stipend,
      stipendType: stipendType ?? this.stipendType,
      duration: duration ?? this.duration,
      durationMonths: durationMonths ?? this.durationMonths,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      eligibility: eligibility ?? this.eligibility,
      benefits: benefits ?? this.benefits,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      applicationType: applicationType ?? this.applicationType,
      deadline: deadline ?? this.deadline,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      trustScore: trustScore ?? this.trustScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      trustEvidence: trustEvidence ?? this.trustEvidence,
    );
  }
}
