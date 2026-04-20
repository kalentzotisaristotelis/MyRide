class AppUser {
  final String id; // Το ίδιο ID με το Firebase Auth
  final String email;
  final String displayName; // Π.χ. "Γιώργος" ή "Άγριος Αναβάτης"
  final String bio; // Μια μικρή περιγραφή (προαιρετικό)

  // 1. ΝΕΟ: Η μεταβλητή για το URL της φωτογραφίας (μπορεί να είναι null)
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.bio = '',
    this.photoUrl, // 2. ΝΕΟ: Το βάζουμε στον constructor
  });

  // Από το Firebase στην εφαρμογή
  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Άγνωστος Αναβάτης',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'], // 3. ΝΕΟ: Το διαβάζουμε από τη βάση
    );
  }

  // Από την εφαρμογή στο Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl, // 4. ΝΕΟ: Το στέλνουμε στη βάση
    };
  }
}