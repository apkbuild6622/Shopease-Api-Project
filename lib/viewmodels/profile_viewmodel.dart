import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({required ProfileRepository repository})
      : _repository = repository;

  UserProfile? get profile => _repository.profile;

  bool get hasProfile => _repository.hasProfile;

  String get displayName => _repository.profile?.name ?? 'Guest User';

  String get displayEmail =>
      _repository.profile?.email ?? 'guest@shopease.com';

  String get displayPhone => _repository.profile?.phone ?? '';

  String get displayAddress => _repository.profile?.address ?? '';

  String get initials {
    final p = _repository.profile;
    if (p == null || p.name.isEmpty) return '?';
    return p.initials;
  }

  void saveProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    _repository.saveProfile(
      UserProfile(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
      ),
    );
    notifyListeners();
  }

  void clearProfile() {
    _repository.clear();
    notifyListeners();
  }
}