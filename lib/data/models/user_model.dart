class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // Student, Company, Institute, Admin
  final bool isVerified;
  final int trustPoints;

  // Student specific
  final String? college;
  final String? degree;
  final String? department;
  final int? passingYear;
  final List<String>? skills;
  final String? linkedin;
  final String? github;
  final String? preferredType;
  final String? preferredLocation;
  final double? expectedStipend;

  // Company specific
  final String? gstNumber;
  final String? industry;
  final String? website;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isVerified = false,
    this.trustPoints = 0,
    this.college,
    this.degree,
    this.department,
    this.passingYear,
    this.skills,
    this.linkedin,
    this.github,
    this.preferredType,
    this.preferredLocation,
    this.expectedStipend,
    this.gstNumber,
    this.industry,
    this.website,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      trustPoints: json['trustPoints'] as int? ?? 0,
      college: json['college'] as String?,
      degree: json['degree'] as String?,
      department: json['department'] as String?,
      passingYear: json['passingYear'] as int?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
      linkedin: json['linkedin'] as String?,
      github: json['github'] as String?,
      preferredType: json['preferredType'] as String?,
      preferredLocation: json['preferredLocation'] as String?,
      expectedStipend: (json['expectedStipend'] as num?)?.toDouble(),
      gstNumber: json['gstNumber'] as String?,
      industry: json['industry'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isVerified': isVerified,
      'trustPoints': trustPoints,
      'college': college,
      'degree': degree,
      'department': department,
      'passingYear': passingYear,
      'skills': skills,
      'linkedin': linkedin,
      'github': github,
      'preferredType': preferredType,
      'preferredLocation': preferredLocation,
      'expectedStipend': expectedStipend,
      'gstNumber': gstNumber,
      'industry': industry,
      'website': website,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isVerified,
    int? trustPoints,
    String? college,
    String? degree,
    String? department,
    int? passingYear,
    List<String>? skills,
    String? linkedin,
    String? github,
    String? preferredType,
    String? preferredLocation,
    double? expectedStipend,
    String? gstNumber,
    String? industry,
    String? website,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      trustPoints: trustPoints ?? this.trustPoints,
      college: college ?? this.college,
      degree: degree ?? this.degree,
      department: department ?? this.department,
      passingYear: passingYear ?? this.passingYear,
      skills: skills ?? this.skills,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      preferredType: preferredType ?? this.preferredType,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      expectedStipend: expectedStipend ?? this.expectedStipend,
      gstNumber: gstNumber ?? this.gstNumber,
      industry: industry ?? this.industry,
      website: website ?? this.website,
    );
  }
}
