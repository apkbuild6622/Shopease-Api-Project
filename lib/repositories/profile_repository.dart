import '../models/user_profile.dart';

class ProfileRepository {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool get hasProfile => _profile != null && _profile!.isNotEmpty;

  void saveProfile(UserProfile profile) {
    _profile = profile;
  }

  void clear() {
    _profile = null;
  }
}