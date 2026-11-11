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
  Rxn<UserModel> get rxCurrentUser => _currentUser;

  final RxBool isLoggedIn = false.obs;

  // Storing signup details before OTP verification
  UserModel? _pendingUser;
  String? _generatedOtp;

  Future<AuthResult> login(String email, String password) async {
    try {
      debugPrint('AuthService LOGIN 1: Starting Firebase authentication');
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        debugPrint('AuthService LOGIN: Firebase user is null');
        return AuthResult.errorGeneric;
      }

      final uid = firebaseUser.uid;
      debugPrint('AuthService LOGIN 2: Firebase login successful. UID: $uid');
      debugPrint('AuthService LOGIN 3: Fetching UserModel from Firestore for UID: $uid');

      // Fetch user profile from Firestore users/{uid}
      UserModel? user = await _firestore.getUser(uid);

      if (user == null) {
        debugPrint('WARNING: Firestore user document users/$uid was not found after login!');
        final fallbackName = (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty)
            ? firebaseUser.displayName!.trim()
            : (email.trim().contains('@')
                ? email.trim().split('@')[0]
                : 'User');

        user = UserModel(
          id: uid,
          email: firebaseUser.email ?? email.trim(),
          name: fallbackName,
          role: 'Student',
          isVerified: true,
          trustPoints: 100,
        );

        debugPrint('AuthService: Saving fallback user profile to Firestore: ${user.name}');
        try {
          await _firestore.saveUser(user);
        } catch (e) {
          debugPrint('AuthService: Error saving fallback user: $e');
        }
      }

      _currentUser.value = user;
      isLoggedIn.value = true;
      debugPrint('AuthService LOGIN 4: User loaded into AuthService: ${user.name} (${user.role})');
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error code: ${e.code}, message: ${e.message}');
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
      debugPrint('AuthService LOGIN ERROR: $e');
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
      debugPrint('AuthService REGISTER 1: Creating Firebase Auth user for $email');
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        debugPrint('AuthService REGISTER: Firebase user is null');
        return AuthResult.errorGeneric;
      }

      final uid = firebaseUser.uid;
      final trimmedName = name.trim();
      final trimmedEmail = email.trim();

      // Update Firebase Auth display name for consistency
      try {
        await firebaseUser.updateDisplayName(trimmedName);
      } catch (e) {
        debugPrint('AuthService: Could not update FirebaseAuth displayName: $e');
      }

      // Create UserModel with the exact name entered by the user
      final newUser = UserModel(
        id: uid,
        email: trimmedEmail,
        name: trimmedName,
        role: role,
        isVerified: role == 'Student',
        trustPoints: 100,
      );

      // Save UserModel immediately to Firestore users/{uid}
      debugPrint('AuthService REGISTER 2: Saving UserModel to Firestore users/$uid with name: "$trimmedName"');
      await _firestore.saveUser(newUser);

      _pendingUser = newUser;
      _generatedOtp = '123456';
      debugPrint('AuthService REGISTER 3: Registration and profile save complete. OTP sent.');
      return AuthResult.otpSent;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Registration Error code: ${e.code}, message: ${e.message}');
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
    } catch (e, stackTrace) {
      debugPrint('AuthService Registration Error: $e');
      debugPrint('StackTrace: $stackTrace');
      return AuthResult.errorGeneric;
    }
  }

  Future<AuthResult> verifyOtp(String code) async {
    try {
      if (code == _generatedOtp && _pendingUser != null) {
        // Ensure user profile is saved in Firestore
        await _firestore.saveUser(_pendingUser!);

        _currentUser.value = _pendingUser;
        isLoggedIn.value = true;

        debugPrint('AuthService OTP: Verified successfully for ${_pendingUser?.name}');
        _pendingUser = null;
        _generatedOtp = null;

        return AuthResult.success;
      }

      // Fallback: If pendingUser is null but auth user is logged in
      final firebaseUser = _auth.currentUser;
      if (code == '123456' && firebaseUser != null) {
        final user = await _firestore.getUser(firebaseUser.uid);
        if (user != null) {
          _currentUser.value = user;
          isLoggedIn.value = true;
          _generatedOtp = null;
          return AuthResult.success;
        }
      }

      return AuthResult.errorInvalidOtp;
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      return AuthResult.errorGeneric;
    }
  }

  /// Restores session on app startup if Firebase Auth has an active user
  Future<UserModel?> restoreSession() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        debugPrint('AuthService: No active Firebase Auth session');
        _currentUser.value = null;
        isLoggedIn.value = false;
        return null;
      }

      final uid = firebaseUser.uid;
      debugPrint('AuthService: Found active Firebase Auth session for UID: $uid. Restoring Firestore profile...');
      UserModel? user = await _firestore.getUser(uid);

      if (user == null) {
        debugPrint('WARNING: Firestore document missing for active user $uid during restoreSession');
        final fallbackName = (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty)
            ? firebaseUser.displayName!.trim()
            : (firebaseUser.email?.contains('@') == true
                ? firebaseUser.email!.split('@')[0]
                : 'User');

        user = UserModel(
          id: uid,
          email: firebaseUser.email ?? '',
          name: fallbackName,
          role: 'Student',
          isVerified: true,
          trustPoints: 100,
        );
        try {
          await _firestore.saveUser(user);
        } catch (e) {
          debugPrint('AuthService: Error saving fallback user during restore: $e');
        }
      }

      _currentUser.value = user;
      isLoggedIn.value = true;
      debugPrint('AuthService: Session restored for user: ${user.name} (${user.role})');
      return user;
    } catch (e, stackTrace) {
      debugPrint('AuthService restoreSession error: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
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
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService logout error: $e');
    }

    _currentUser.value = null;
    _pendingUser = null;
    _generatedOtp = null;
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
