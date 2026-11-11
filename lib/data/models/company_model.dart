import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String companyName;
  final String logo;
  final String description;
  final String website;
  final String industry;
  final String headquarters;
  final String companySize;
  final String verificationStatus; // verified, pending, unverified
  final DateTime? verifiedAt;
  final String? verificationEvidence;
  final DateTime createdAt;

  CompanyModel({
    required this.id,
    required this.companyName,
    this.logo = '',
    this.description = '',
    this.website = '',
    this.industry = '',
    this.headquarters = '',
    this.companySize = '10-50 employees',
    this.verificationStatus = 'unverified',
    this.verifiedAt,
    this.verificationEvidence,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  factory CompanyModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime? vAt;
    final rawVAt = json['verifiedAt'];
    if (rawVAt is Timestamp) {
      vAt = rawVAt.toDate();
    } else if (rawVAt is String && rawVAt.isNotEmpty) {
      vAt = DateTime.tryParse(rawVAt);
    }

    DateTime cAt = DateTime.now();
    final rawCAt = json['createdAt'];
    if (rawCAt is Timestamp) {
      cAt = rawCAt.toDate();
    } else if (rawCAt is String && rawCAt.isNotEmpty) {
      cAt = DateTime.tryParse(rawCAt) ?? cAt;
    }

    return CompanyModel(
      id: docId ?? (json['id'] as String? ?? ''),
      companyName: json['companyName'] as String? ?? 'Organization',
      logo: json['logo'] as String? ?? '',
      description: json['description'] as String? ?? '',
      website: json['website'] as String? ?? '',
      industry: json['industry'] as String? ?? 'Technology',
      headquarters: json['headquarters'] as String? ?? 'India',
      companySize: json['companySize'] as String? ?? '50-200 employees',
      verificationStatus: json['verificationStatus'] as String? ?? 'unverified',
      verifiedAt: vAt,
      verificationEvidence: json['verificationEvidence'] as String?,
      createdAt: cAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'logo': logo,
      'description': description,
      'website': website,
      'industry': industry,
      'headquarters': headquarters,
      'companySize': companySize,
      'verificationStatus': verificationStatus,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationEvidence': verificationEvidence,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

