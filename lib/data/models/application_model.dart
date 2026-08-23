class ApplicationModel {
  final String id;
  final String internshipId;
  final String studentId;
  final String status; // Applied, In Review, Verified, Offered, Rejected
  final String appliedDate;
  final String notes;

  ApplicationModel({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.status,
    required this.appliedDate,
    required this.notes,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      internshipId: json['internshipId'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String? ?? 'Applied',
      appliedDate: json['appliedDate'] as String,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internshipId': internshipId,
      'studentId': studentId,
      'status': status,
      'appliedDate': appliedDate,
      'notes': notes,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? internshipId,
    String? studentId,
    String? status,
    String? appliedDate,
    String? notes,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      internshipId: internshipId ?? this.internshipId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      notes: notes ?? this.notes,
    );
  }
}
