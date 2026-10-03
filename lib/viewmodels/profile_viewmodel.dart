import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final AuthService _authService;

  ProfileViewModel({
    required ProfileRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get hasProfile => _profile != null && _profile!.isNotEmpty;

  String get displayName => _profile?.name ?? 'Guest User';
  String get displayEmail => _profile?.email ?? 'guest@shopease.com';
  String get displayPhone => _profile?.phone ?? '';
  String get displayAddress => _profile?.address ?? '';

  String get initials {
    if (_profile == null || _profile!.name.isEmpty) return '?';
    return _profile!.initials;
  }

  Future<void> loadProfile() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(userId);
    } catch (e) {
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final profile = UserProfile(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      address: address.trim(),
    );

    await _repository.saveProfile(profile, userId);
    _profile = profile;
    notifyListeners();
  }

  Future<void> clearProfile() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.clearProfile(userId);
    _profile = null;
    notifyListeners();
  }

  void clearLocalState() {
    _profile = null;
    notifyListeners();
  }
}