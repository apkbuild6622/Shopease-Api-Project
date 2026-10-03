import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthViewState { idle, loading, success, error }

enum OtpState { idle, sending, sent, verifying, verified, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({required AuthService authService})
      : _authService = authService;

  AuthViewState _state = AuthViewState.idle;
  AuthViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OtpState _otpState = OtpState.idle;
  OtpState get otpState => _otpState;

  String? _verificationId;
  String? get verificationId => _verificationId;

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

  int? _resendToken;

  bool get isLoading => _state == AuthViewState.loading;
  bool get isLoggedIn => _authService.isLoggedIn;
  User? get currentUser => _authService.currentUser;
  String? get userEmail => _authService.currentUser?.email;
  String? get userId => _authService.currentUser?.uid;
  String? get userPhone => _authService.currentUser?.phoneNumber;

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    _setState(AuthViewState.loading);
    try {
      await _authService.signUp(email: email, password: password);

      if (name != null && name.isNotEmpty) {
        await _authService.updateDisplayName(name);
      }

      _state = AuthViewState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong.';
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setState(AuthViewState.loading);
    try {
      await _authService.signIn(email: email, password: password);
      _state = AuthViewState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong.';
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    _setState(AuthViewState.loading);
    try {
      final email = await _findEmailByPhone(phoneNumber);

      if (email == null) {
        _errorMessage = 'No account found with this phone number.';
        _state = AuthViewState.error;
        notifyListeners();
        return false;
      }

      await _authService.signIn(email: email, password: password);
      _state = AuthViewState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setState(AuthViewState.loading);
    try {
      await _authService.sendPasswordReset(email);
      _state = AuthViewState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong.';
      _state = AuthViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    return await _authService.isEmailRegistered(email);
  }

  Future<bool> isPhoneRegistered(String phoneNumber) async {
    return await _authService.isPhoneRegistered(phoneNumber);
  }

  Future<String?> findEmailByPhone(String phoneNumber) async {
    return await _findEmailByPhone(phoneNumber);
  }

  Future<void> sendOTP(String phoneNumber) async {
    _otpState = OtpState.sending;
    _phoneNumber = phoneNumber;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (credential) async {
          _otpState = OtpState.verified;
          notifyListeners();
          await _authService.signInWithOTP(
            verificationId: credential.verificationId ?? '',
            smsCode: credential.smsCode ?? '',
          );
          _state = AuthViewState.success;
          notifyListeners();
        },
        onVerificationFailed: (e) {
          _errorMessage = _authService.getErrorMessage(e.code);
          _otpState = OtpState.error;
          notifyListeners();
        },
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _otpState = OtpState.sent;
          notifyListeners();
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to send OTP.';
      _otpState = OtpState.error;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _errorMessage = 'Verification ID missing. Resend OTP.';
      notifyListeners();
      return false;
    }

    _otpState = OtpState.verifying;
    notifyListeners();

    try {
      await _authService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: smsCode.trim(),
      );
      _otpState = OtpState.verified;
      _state = AuthViewState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _otpState = OtpState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'OTP verification failed.';
      _otpState = OtpState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> resendOTP() async {
    if (_phoneNumber == null) return;
    await sendOTP(_phoneNumber!);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _state = AuthViewState.idle;
    _otpState = OtpState.idle;
    _verificationId = null;
    _phoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  void resetOtpState() {
    _otpState = OtpState.idle;
    _verificationId = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> _findEmailByPhone(String phoneNumber) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data()['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  void _setState(AuthViewState newState) {
    _state = newState;
    notifyListeners();
  }
}