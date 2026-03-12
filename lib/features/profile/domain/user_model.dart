class AppUser {
  final String id; // Το ίδιο ID με το Firebase Auth
  final String email;
  final String displayName; // Π.χ. "Γιώργος" ή "Άγριος Αναβάτης"
  final String bio; // Μια μικρή περιγραφή (προαιρετικό)

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.bio = '',
  });

  // Από το Firebase στην εφαρμογή
  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Άγνωστος Αναβάτης',
      bio: map['bio'] ?? '',
    );
  }

  // Από την εφαρμογή στο Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
    };
  }
}