import 'package:flutter/material.dart';
import 'scanner_finding_model.dart';

enum ScannerInputType {
  url,
  text,
  document,
}

enum AssessmentCategory {
  redFlagsDetected,
  furtherVerificationRecommended,
  noObviousWarningSigns,
  insufficientInformation,
}

class ScannerReportModel {
  final String id;
  final String? studentId;
  final ScannerInputType submissionType;
  final String rawInput;
  final String? documentName;
  final AssessmentCategory assessmentCategory;
  final String assessmentHeadline;
  final String overallExplanation;
  final List<ScannerFindingModel> findings;
  final List<String> recommendedNextSteps;
  final String analysisMethod;
  final DateTime createdAt;
  final bool isSaved;
  final String? limitations;

  const ScannerReportModel({
    required this.id,
    this.studentId,
    required this.submissionType,
    required this.rawInput,
    this.documentName,
    required this.assessmentCategory,
    required this.assessmentHeadline,
    required this.overallExplanation,
    required this.findings,
    required this.recommendedNextSteps,
    required this.analysisMethod,
    required this.createdAt,
    this.isSaved = false,
    this.limitations,
  });

  ScannerReportModel copyWith({
    String? id,
    String? studentId,
    ScannerInputType? submissionType,
    String? rawInput,
    String? documentName,
    AssessmentCategory? assessmentCategory,
    String? assessmentHeadline,
    String? overallExplanation,
    List<ScannerFindingModel>? findings,
    List<String>? recommendedNextSteps,
    String? analysisMethod,
    DateTime? createdAt,
    bool? isSaved,
    String? limitations,
  }) {
    return ScannerReportModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      submissionType: submissionType ?? this.submissionType,
      rawInput: rawInput ?? this.rawInput,
      documentName: documentName ?? this.documentName,
      assessmentCategory: assessmentCategory ?? this.assessmentCategory,
      assessmentHeadline: assessmentHeadline ?? this.assessmentHeadline,
      overallExplanation: overallExplanation ?? this.overallExplanation,
      findings: findings ?? this.findings,
      recommendedNextSteps: recommendedNextSteps ?? this.recommendedNextSteps,
      analysisMethod: analysisMethod ?? this.analysisMethod,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      limitations: limitations ?? this.limitations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'submissionType': submissionType.name,
      'rawInput': rawInput,
      'documentName': documentName,
      'assessmentCategory': assessmentCategory.name,
      'assessmentHeadline': assessmentHeadline,
      'overallExplanation': overallExplanation,
      'findings': findings.map((f) => f.toJson()).toList(),
      'recommendedNextSteps': recommendedNextSteps,
      'analysisMethod': analysisMethod,
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
      'limitations': limitations,
    };
  }

  factory ScannerReportModel.fromJson(Map<String, dynamic> json) {
    return ScannerReportModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String?,
      submissionType: ScannerInputType.values.firstWhere(
        (e) => e.name == json['submissionType'],
        orElse: () => ScannerInputType.text,
      ),
      rawInput: json['rawInput'] as String? ?? '',
      documentName: json['documentName'] as String?,
      assessmentCategory: AssessmentCategory.values.firstWhere(
        (e) => e.name == json['assessmentCategory'],
        orElse: () => AssessmentCategory.furtherVerificationRecommended,
      ),
      assessmentHeadline: json['assessmentHeadline'] as String? ?? '',
      overallExplanation: json['overallExplanation'] as String? ?? '',
      findings: (json['findings'] as List<dynamic>? ?? [])
          .map((f) => ScannerFindingModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      recommendedNextSteps: (json['recommendedNextSteps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      analysisMethod: json['analysisMethod'] as String? ??
          'Automated rule-based heuristic scanner v1.0',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isSaved: json['isSaved'] as bool? ?? false,
      limitations: json['limitations'] as String?,
    );
  }

  String get categoryDisplayTitle {
    switch (assessmentCategory) {
      case AssessmentCategory.redFlagsDetected:
        return 'Potential red flags detected';
      case AssessmentCategory.furtherVerificationRecommended:
        return 'Further verification recommended';
      case AssessmentCategory.noObviousWarningSigns:
        return 'No obvious warning signs detected';
      case AssessmentCategory.insufficientInformation:
        return 'Insufficient information to assess';
    }
  }

  Color get statusColor {
    switch (assessmentCategory) {
      case AssessmentCategory.redFlagsDetected:
        return const Color(0xFFBA1A1A); // Red
      case AssessmentCategory.furtherVerificationRecommended:
        return const Color(0xFFB45309); // Amber
      case AssessmentCategory.noObviousWarningSigns:
        return const Color(0xFF004AC6); // Brand Primary Blue (clean & honest, not green)
      case AssessmentCategory.insufficientInformation:
        return const Color(0xFF5B6078); // Slate grey
    }
  }

  Color get statusBackgroundColor {
    switch (assessmentCategory) {
      case AssessmentCategory.redFlagsDetected:
        return const Color(0xFFFFF1F0);
      case AssessmentCategory.furtherVerificationRecommended:
        return const Color(0xFFFFFBEB);
      case AssessmentCategory.noObviousWarningSigns:
        return const Color(0xFFEFF4FF);
      case AssessmentCategory.insufficientInformation:
        return const Color(0xFFF8FAFC);
    }
  }

  Color get statusBorderColor {
    switch (assessmentCategory) {
      case AssessmentCategory.redFlagsDetected:
        return const Color(0xFFFCA5A5);
      case AssessmentCategory.furtherVerificationRecommended:
        return const Color(0xFFFCD34D);
      case AssessmentCategory.noObviousWarningSigns:
        return const Color(0xFFBFDBFE);
      case AssessmentCategory.insufficientInformation:
        return const Color(0xFFCBD5E1);
    }
  }

  IconData get statusIcon {
    switch (assessmentCategory) {
      case AssessmentCategory.redFlagsDetected:
        return Icons.warning_amber_rounded;
      case AssessmentCategory.furtherVerificationRecommended:
        return Icons.search_rounded;
      case AssessmentCategory.noObviousWarningSigns:
        return Icons.shield_outlined;
      case AssessmentCategory.insufficientInformation:
        return Icons.help_outline_rounded;
    }
  }
}
