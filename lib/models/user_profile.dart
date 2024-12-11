class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email Provided',
    );
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}