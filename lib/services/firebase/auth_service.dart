import 'package:flutter/foundation.dart';
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

      debugPrint('LOGIN 1: Starting Firebase login');
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('LOGIN 2: Firebase login successful');
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        debugPrint('LOGIN 3: Firebase user is NULL');
        return AuthResult.errorGeneric;
      }

      debugPrint('LOGIN 4: Firebase UID = ${firebaseUser.uid}');

      debugPrint('LOGIN 5: Getting user from Firestore');

      // Get user profile from Firestore
      UserModel? user = await _firestore.getUser(firebaseUser.uid);

      debugPrint('LOGIN 6: Firestore user = $user');

      if (user == null) {
        // Fallback profile if user exists in Firebase Auth but document is missing

        debugPrint('LOGIN 7: User document not found');
        final fallbackName =
            firebaseUser.displayName ??
            (email.trim().contains('@')
                ? email.trim().split('@')[0]
                : 'Student');
        user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email.trim(),
          name: fallbackName,
          role: 'Student',
          isVerified: true,
          trustPoints: 100,
        );

        debugPrint('LOGIN 8: Saving fallback user');
        await _firestore.saveUser(user);
        debugPrint('LOGIN 9: Fallback user saved');
      }

      _currentUser.value = user;
      isLoggedIn.value = true;
      debugPrint('LOGIN 10: Login completely successful');
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error: ${e.code}');
      debugPrint('FIREBASE LOGIN MESSAGE: ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          return AuthResult.errorUserNotFound;

        case 'wrong-password':
        case 'invalid-credential':
          return AuthResult.errorWrongPassword;

        case 'invalid-email':
          return AuthResult.errorInvalidEmail;

        case 'user-disabled':
          return AuthResult.errorGeneric;

        default:
          return AuthResult.errorGeneric;
      }
    } catch (e, stackTrace) {
      debugPrint('========== LOGIN ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

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
      debugPrint('Firebase Registration Error: ${e.code}');

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
      debugPrint('Registration Error: $e');
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
      debugPrint('OTP Verification Error: $e');
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
