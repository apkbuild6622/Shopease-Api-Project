import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('main');
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await _profileRef(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserProfile(
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          phone: data['phone'] as String? ?? '',
          address: data['address'] as String? ?? '',
          profileImageUrl: data['profileImageUrl'] as String?,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'email': profile.email.toLowerCase().trim(),
      'phone': profile.phone.trim(),
      'name': profile.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _profileRef(userId).set({
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'address': profile.address,
      'profileImageUrl': profile.profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearProfile(String userId) async {
    await _profileRef(userId).delete();
  }
}