class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? profileImageUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImageUrl,
  });

  bool get isEmpty =>
      name.isEmpty && email.isEmpty && phone.isEmpty && address.isEmpty;

  bool get isNotEmpty => !isEmpty;

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}