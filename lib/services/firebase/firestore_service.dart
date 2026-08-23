import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/models/internship_model.dart';
import '../../data/models/application_model.dart';

class FirestoreService extends GetxService {
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<InternshipModel> _internships = <InternshipModel>[].obs;
  final RxList<ApplicationModel> _applications = <ApplicationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _prepopulateInternships();
  }

  void _prepopulateInternships() {
    _internships.addAll([
      InternshipModel(
        id: '1',
        title: 'Flutter Developer',
        companyName: 'TechPulse Systems',
        location: 'Remote',
        stipend: 25000,
        trustScore: 98.0,
        isVerified: true,
        logoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB_-5bU4YYaNDEymVnJcrIwpG31mHPQcT8OV9AWFNY8Ixko-SmatjjT2-C40jvROWjykntNQ4vEE8xzcdWH_lRj-yZV6MnKxB4wLpnyJfV6ql4Pl-ACZv8PBYVwQwgCKtMmoyDtXkMjdTQWVTc6zaDEbG9xmI4Prkc-EAPo95Y8QJ3sCj3UJtRA2UM8jW8BgBjbpPuc4Q1WHKft8ydvK3I3Cfx4TbyiJIipiNJp7dPJRFUzyclSq2kVBkD69VGLlgcwD5XGAf3w77Wl',
        type: 'Remote',
        description: 'Join TechPulse Systems to build high performance cross-platform applications using Flutter and GetX. Work closely with product owners and backend engineers.',
        requirements: ['Flutter & Dart SDK', 'GetX State Management', 'Git version control', 'REST APIs integration'],
      ),
      InternshipModel(
        id: '2',
        title: 'UI UX Designer',
        companyName: 'Aura Design Studio',
        location: 'Bangalore',
        stipend: 18000,
        trustScore: 95.0,
        isVerified: true,
        logoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrfq266CoaqKgDSF4LkUripgTTc39nwhcB3kKsPzqTTIi3SuTeQBrRDvdDm1qgaR0xRNVWl8VmXiApv_1lnPADX6s_LP0E8CWLgm9KfWArEIHU1mEkxxGjvZo08OeNu1liugHWD2rXiYUl2JHuuPuNp_z_Sn2QMpN_npDPiGgOcV5natODipIixXS1pOafQX4uCxh-SxJPe_Jj8dUEiDBFXx51X3gXwLikiksm-xYQbHS1iOPXDMUIWS7fR2J78FkVpILvAp4qnN3I',
        type: 'Hybrid',
        description: 'Collaborate with developers and product managers to create modern, premium glassmorphism interfaces and mobile/web prototypes.',
        requirements: ['Figma expertise', 'Design systems knowledge', 'Wireframing & Prototyping', 'Fintech design patterns'],
      ),
      InternshipModel(
        id: '3',
        title: 'Security Analyst',
        companyName: 'SecureNet Hub',
        location: 'Hybrid',
        stipend: 30000,
        trustScore: 99.0,
        isVerified: true,
        logoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCy0mWpMK_4VjIQyN_AaA8mIqUszuCeVbhZhYufKmscliFX_RzRLkRP6J4099XwdhHFVzHct0DSN6E0Y2cIX_C5z6sOyw83hbLAEglb3Jqkqd88GowS7UnjAaG_VtSm0XUN6Fw9X9PDUF8tzFHu67MLMZPxAzU2xc3KHR92vb2m4gzzWA6rLDTdijO0j1iUi1gvucVWOly61WnGVIJKiz0t9ZUSOWRAcomGLX-sAtzwR2DAFVZZwVnGW69BcSOUtNLVv0XwH0SeKMxo',
        type: 'Hybrid',
        description: 'Vet security architectures, review codebases, audit network systems, and evaluate internship compliance metrics.',
        requirements: ['OWASP Top 10', 'Penetration Testing basics', 'Linux administration', 'Cryptography protocols'],
      ),
    ]);
  }

  // User Operations
  Future<UserModel?> getUser(String id) async {
    return _users.firstWhereOrNull((u) => u.id == id);
  }

  Future<void> saveUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  // Internship Operations
  List<InternshipModel> get internships => _internships;

  // Application Operations
  List<ApplicationModel> getApplications(String studentId) {
    return _applications.where((a) => a.studentId == studentId).toList();
  }

  Future<void> submitApplication(ApplicationModel application) async {
    _applications.add(application);
  }
}
