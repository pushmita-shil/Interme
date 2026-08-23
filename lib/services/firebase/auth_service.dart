import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  UserModel? get currentUser => _currentUser.value;
  
  final RxBool isLoggedIn = false.obs;
  
  // Storing signup details before OTP verification
  UserModel? _pendingUser;
  String? _generatedOtp;

  Future<AuthResult> login(String email, String password) async {
    // In our mock, any email/password works, but we look up if the user exists
    // otherwise we create a generic user for demo convenience.
    final mockId = 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
    var user = await _firestore.getUser(mockId);
    if (user == null) {
      // Default placeholder user (Student)
      user = UserModel(
        id: mockId,
        email: email,
        name: 'Pushmita',
        role: 'Student',
        isVerified: true,
        trustPoints: 450,
      );
      await _firestore.saveUser(user);
    }
    
    _currentUser.value = user;
    isLoggedIn.value = true;
    return AuthResult.success;
  }

  Future<AuthResult> register(String email, String name, String role) async {
    final mockId = 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
    
    _pendingUser = UserModel(
      id: mockId,
      email: email,
      name: name,
      role: role,
      isVerified: role == 'Student' ? true : false, // Students verified by default, others need review
      trustPoints: 100,
    );

    // Mock OTP Generation
    _generatedOtp = '123456';
    return AuthResult.otpSent;
  }

  Future<AuthResult> verifyOtp(String code) async {
    if (code == _generatedOtp && _pendingUser != null) {
      await _firestore.saveUser(_pendingUser!);
      _currentUser.value = _pendingUser;
      isLoggedIn.value = true;
      _pendingUser = null;
      _generatedOtp = null;
      return AuthResult.success;
    }
    return AuthResult.errorInvalidOtp;
  }

  Future<void> updateStudentProfile({
    required String college,
    required String degree,
    required String department,
    required int passingYear,
    required List<String> skills,
    required String linkedin,
    required String github,
    required String preferredType,
    required String preferredLocation,
    required double expectedStipend,
  }) async {
    if (currentUser != null) {
      final updated = currentUser!.copyWith(
        college: college,
        degree: degree,
        department: department,
        passingYear: passingYear,
        skills: skills,
        linkedin: linkedin,
        github: github,
        preferredType: preferredType,
        preferredLocation: preferredLocation,
        expectedStipend: expectedStipend,
      );
      await _firestore.saveUser(updated);
      _currentUser.value = updated;
    }
  }

  void logout() {
    _currentUser.value = null;
    isLoggedIn.value = false;
  }
}

enum AuthResult {
  success,
  otpSent,
  errorInvalidOtp,
  errorGeneric,
}
