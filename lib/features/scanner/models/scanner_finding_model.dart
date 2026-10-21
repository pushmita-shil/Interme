import 'package:flutter/material.dart';

enum FindingType {
  warning,
  info,
  verifiedFact,
  unknownInconclusive,
}

enum FindingSeverity {
  high,
  medium,
  low,
  info,
}

class ScannerFindingModel {
  final String id;
  final String title;
  final FindingType type;
  final FindingSeverity severity;
  final String explanation;
  final String? evidence;
  final String suggestedAction;
  final String ruleName;

  const ScannerFindingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.severity,
    required this.explanation,
    this.evidence,
    required this.suggestedAction,
    required this.ruleName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'severity': severity.name,
      'explanation': explanation,
      'evidence': evidence,
      'suggestedAction': suggestedAction,
      'ruleName': ruleName,
    };
  }

  factory ScannerFindingModel.fromJson(Map<String, dynamic> json) {
    return ScannerFindingModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: FindingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FindingType.info,
      ),
      severity: FindingSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => FindingSeverity.info,
      ),
      explanation: json['explanation'] as String? ?? '',
      evidence: json['evidence'] as String?,
      suggestedAction: json['suggestedAction'] as String? ?? '',
      ruleName: json['ruleName'] as String? ?? '',
    );
  }

  IconData get icon {
    switch (type) {
      case FindingType.warning:
        return severity == FindingSeverity.high
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded;
      case FindingType.verifiedFact:
        return Icons.verified_user_rounded;
      case FindingType.info:
        return Icons.info_outline_rounded;
      case FindingType.unknownInconclusive:
        return Icons.help_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case FindingType.warning:
        return severity == FindingSeverity.high
            ? const Color(0xFFBA1A1A)
            : const Color(0xFFB45309);
      case FindingType.verifiedFact:
        return const Color(0xFF006C49);
      case FindingType.info:
        return const Color(0xFF004AC6);
      case FindingType.unknownInconclusive:
        return const Color(0xFF737686);
    }
  }

  Color get containerColor {
    switch (type) {
      case FindingType.warning:
        return severity == FindingSeverity.high
            ? const Color(0xFFFFDAD6)
            : const Color(0xFFFEF3C7);
      case FindingType.verifiedFact:
        return const Color(0xFFD1FAE5);
      case FindingType.info:
        return const Color(0xFFE5EEFF);
      case FindingType.unknownInconclusive:
        return const Color(0xFFF1F5F9);
    }
  }

  String get typeLabel {
    switch (type) {
      case FindingType.warning:
        return severity == FindingSeverity.high ? 'High Risk' : 'Warning';
      case FindingType.verifiedFact:
        return 'Verified Observation';
      case FindingType.info:
        return 'Information';
      case FindingType.unknownInconclusive:
        return 'Inconclusive';
    }
  }
}
