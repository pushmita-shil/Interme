class InternshipModel {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final double stipend;
  final double trustScore; // e.g. 98.0
  final bool isVerified;
  final String logoUrl;
  final String type; // Remote, Hybrid, Onsite
  final String description;
  final List<String> requirements;

  InternshipModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.stipend,
    required this.trustScore,
    required this.isVerified,
    required this.logoUrl,
    required this.type,
    required this.description,
    required this.requirements,
  });

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String,
      location: json['location'] as String,
      stipend: (json['stipend'] as num).toDouble(),
      trustScore: (json['trustScore'] as num).toDouble(),
      isVerified: json['isVerified'] as bool? ?? false,
      logoUrl: json['logoUrl'] as String? ?? '',
      type: json['type'] as String? ?? 'Remote',
      description: json['description'] as String? ?? '',
      requirements: (json['requirements'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'location': location,
      'stipend': stipend,
      'trustScore': trustScore,
      'isVerified': isVerified,
      'logoUrl': logoUrl,
      'type': type,
      'description': description,
      'requirements': requirements,
    };
  }
}
