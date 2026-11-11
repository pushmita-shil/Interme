import 'package:cloud_firestore/cloud_firestore.dart';

class SavedInternshipModel {
  final String id;
  final String studentId;
  final String internshipId;
  final String companyId;
  final DateTime savedAt;
  final String title;
  final String companyName;
  final String companyLogo;
  final double stipend;
  final String workMode;
  final String location;
  final DateTime? deadline;
  final bool isVerified;
  final double? trustScore;

  SavedInternshipModel({
    required this.id,
    required this.studentId,
    required this.internshipId,
    required this.companyId,
    DateTime? savedAt,
    this.title = '',
    this.companyName = '',
    this.companyLogo = '',
    this.stipend = 0.0,
    this.workMode = 'Remote',
    this.location = 'Remote',
    this.deadline,
    this.isVerified = false,
    this.trustScore,
  }) : savedAt = savedAt ?? DateTime.now();

  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  factory SavedInternshipModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime sAt = DateTime.now();
    final rawSAt = json['savedAt'];
    if (rawSAt is Timestamp) {
      sAt = rawSAt.toDate();
    } else if (rawSAt is String && rawSAt.isNotEmpty) {
      sAt = DateTime.tryParse(rawSAt) ?? sAt;
    }

    DateTime? dAt;
    final rawDAt = json['deadline'];
    if (rawDAt is Timestamp) {
      dAt = rawDAt.toDate();
    } else if (rawDAt is String && rawDAt.isNotEmpty) {
      dAt = DateTime.tryParse(rawDAt);
    }

    return SavedInternshipModel(
      id: docId ?? (json['id'] as String? ?? ''),
      studentId: json['studentId'] as String? ?? '',
      internshipId: json['internshipId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      savedAt: sAt,
      title: json['title'] as String? ?? json['internshipTitle'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      companyLogo: json['companyLogo'] as String? ?? '',
      stipend: (json['stipend'] as num?)?.toDouble() ?? 0.0,
      workMode: json['workMode'] as String? ?? 'Remote',
      location: json['location'] as String? ?? 'Remote',
      deadline: dAt,
      isVerified: json['isVerified'] as bool? ?? false,
      trustScore: (json['trustScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'internshipId': internshipId,
      'companyId': companyId,
      'savedAt': Timestamp.fromDate(savedAt),
      'title': title,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'stipend': stipend,
      'workMode': workMode,
      'location': location,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isVerified': isVerified,
      'trustScore': trustScore,
    };
  }
}

