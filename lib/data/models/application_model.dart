import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String internshipId;
  final String studentId;
  final String studentName;
  final String internshipTitle;
  final String companyId;
  final String companyName;
  final String companyLogo;
  final String status; // Applied, Under Review, Interview, Selected, Rejected, Withdrawn
  final DateTime appliedAt;
  final DateTime lastUpdatedAt;
  final String resumeUrl;
  final String coverLetter;
  final String applicationType; // in_app, external
  final String notes;
  final List<Map<String, dynamic>> statusUpdates;

  ApplicationModel({
    required this.id,
    required this.internshipId,
    required this.studentId,
    this.studentName = '',
    this.internshipTitle = 'Internship Opportunity',
    this.companyId = '',
    this.companyName = '',
    this.companyLogo = '',
    this.status = 'Applied',
    DateTime? appliedAt,
    DateTime? lastUpdatedAt,
    this.resumeUrl = '',
    this.coverLetter = '',
    this.applicationType = 'in_app',
    this.notes = '',
    this.statusUpdates = const [],
    String? appliedDate, // backward-compat parameter
  })  : appliedAt = appliedAt ?? DateTime.now(),
        lastUpdatedAt = lastUpdatedAt ?? appliedAt ?? DateTime.now();

  /// Backward-compatibility getter for older widgets
  String get appliedDate {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inMinutes < 60) {
      return 'Just now';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d ago';
    } else {
      return '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}';
    }
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime aAt = DateTime.now();
    final rawAAt = json['appliedAt'];
    if (rawAAt is Timestamp) {
      aAt = rawAAt.toDate();
    } else if (rawAAt is String && rawAAt.isNotEmpty) {
      aAt = DateTime.tryParse(rawAAt) ?? aAt;
    } else if (json['appliedDate'] is String && (json['appliedDate'] as String).isNotEmpty) {
      aAt = DateTime.tryParse(json['appliedDate']) ?? aAt;
    }

    DateTime uAt = aAt;
    final rawUAt = json['lastUpdatedAt'];
    if (rawUAt is Timestamp) {
      uAt = rawUAt.toDate();
    } else if (rawUAt is String && rawUAt.isNotEmpty) {
      uAt = DateTime.tryParse(rawUAt) ?? uAt;
    }

    final updates = (json['statusUpdates'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    return ApplicationModel(
      id: docId ?? (json['id'] as String? ?? ''),
      internshipId: json['internshipId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      internshipTitle: json['internshipTitle'] as String? ?? 'Internship',
      companyId: json['companyId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      companyLogo: json['companyLogo'] as String? ?? '',
      status: json['status'] as String? ?? 'Applied',
      appliedAt: aAt,
      lastUpdatedAt: uAt,
      resumeUrl: json['resumeUrl'] as String? ?? '',
      coverLetter: json['coverLetter'] as String? ?? '',
      applicationType: json['applicationType'] as String? ?? 'in_app',
      notes: json['notes'] as String? ?? '',
      statusUpdates: updates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internshipId': internshipId,
      'studentId': studentId,
      'studentName': studentName,
      'internshipTitle': internshipTitle,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'applicationType': applicationType,
      'notes': notes,
      'statusUpdates': statusUpdates,
      'appliedDate': appliedDate, // backward-compat
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? internshipId,
    String? studentId,
    String? studentName,
    String? internshipTitle,
    String? companyId,
    String? companyName,
    String? companyLogo,
    String? status,
    DateTime? appliedAt,
    DateTime? lastUpdatedAt,
    String? resumeUrl,
    String? coverLetter,
    String? applicationType,
    String? notes,
    List<Map<String, dynamic>>? statusUpdates,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      internshipId: internshipId ?? this.internshipId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      internshipTitle: internshipTitle ?? this.internshipTitle,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      applicationType: applicationType ?? this.applicationType,
      notes: notes ?? this.notes,
      statusUpdates: statusUpdates ?? this.statusUpdates,
    );
  }
}
