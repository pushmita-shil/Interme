import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  UserModel? get currentUser => _currentUser.value;

  final RxBool isLoggedIn = false.obs;

  // Storing signup details before OTP verification
  UserModel? _pendingUser;
  String? _generatedOtp;

  Future<AuthResult> login(String email, String password) async {
    try {
      // Firebase checks email + password
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return AuthResult.errorGeneric;
      }

      // Get user profile from Firestore
      final user = await _firestore.getUser(firebaseUser.uid);

      if (user == null) {
        return AuthResult.errorGeneric;
      }
      _currentUser.value = user;
      isLoggedIn.value = true;
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      print('Firebase Login Error: ${e.code}');

      if (e.code == 'user-not-found') {
        return AuthResult.errorUserNotFound;
      }

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return AuthResult.errorWrongPassword;
      }

      if (e.code == 'invalid-email') {
        return AuthResult.errorInvalidEmail;
      }

      return AuthResult.errorGeneric;
    } catch (e) {
      print('Login Error: $e');
      return AuthResult.errorGeneric;
    }
  }

  Future<AuthResult> register(
    String email,
    String name,
    String role,
    String password,
  ) async {
    try {
      // Create Firebase Authentication account
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return AuthResult.errorGeneric;
      }

      _pendingUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        isVerified: role == 'Student',
        trustPoints: 100,
      );

      // Mock OTP Generation
      _generatedOtp = '123456';
      return AuthResult.otpSent;
    } on FirebaseAuthException catch (e) {
      print('Firebase Registration Error: ${e.code}');

      if (e.code == 'email-already-in-use') {
        return AuthResult.errorEmailAlreadyExists;
      }

      if (e.code == 'invalid-email') {
        return AuthResult.errorInvalidEmail;
      }

      if (e.code == 'weak-password') {
        return AuthResult.errorWeakPassword;
      }

      return AuthResult.errorGeneric;
    } catch (e) {
      print('Registration Error: $e');
      return AuthResult.errorGeneric;
    }
  }

  Future<AuthResult> verifyOtp(String code) async {
    try {
      if (code == _generatedOtp && _pendingUser != null) {
        // Save user profile in Firestore
        await _firestore.saveUser(_pendingUser!);

        _currentUser.value = _pendingUser;
        isLoggedIn.value = true;

        _pendingUser = null;
        _generatedOtp = null;

        return AuthResult.success;
      }

      return AuthResult.errorInvalidOtp;
    } catch (e) {
      print('OTP Verification Error: $e');
      return AuthResult.errorGeneric;
    }
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

  Future<void> logout() async {
    await _auth.signOut();

    _currentUser.value = null;
    isLoggedIn.value = false;
  }
}

enum AuthResult {
  success,
  otpSent,
  errorInvalidOtp,
  errorUserNotFound,
  errorWrongPassword,
  errorInvalidEmail,
  errorEmailAlreadyExists,
  errorWeakPassword,
  errorGeneric,
}
