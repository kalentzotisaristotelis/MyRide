class Ride {
  final String id;
  final String creatorId; // Το ID αυτού που τη διοργανώνει
  final String title; // π.χ. "Κυριακάτικη Βόλτα Σούνιο"
  final String description; // Λεπτομέρειες, ρυθμός, στάσεις
  final DateTime date; // Πότε θα γίνει
  final String meetingPoint; // Πού μαζευόμαστε
  // Λίστα από Maps για να αποθηκεύουμε {'uid': '...', 'bike': '...'}
  final List<Map<String, dynamic>> participants;

  Ride({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.date,
    required this.meetingPoint,
    required this.participants,
  });

  // Μετατροπή από Firebase σε Αντικείμενο
  factory Ride.fromMap(Map<String, dynamic> map, String documentId) {
    return Ride(
      id: documentId,
      creatorId: map['creatorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      meetingPoint: map['meetingPoint'] ?? '',

      // ΑΣΦΑΛΗΣ ΑΝΑΓΝΩΣΗ ΣΥΜΜΕΤΕΧΟΝΤΩΝ:
      // Ελέγχουμε αν κάθε στοιχείο είναι Map ή String (για αποφυγή σφαλμάτων τύπου)
      participants: (map['participants'] as List<dynamic>?)?.map((item) {
        if (item is Map) {
          // Αν είναι ήδη Map (νέο format), το παίρνουμε ως έχει
          return Map<String, dynamic>.from(item);
        } else {
          // Αν είναι String (παλιό format), το μετατρέπουμε σε Map δυναμικά
          return {
            'uid': item.toString(),
            'bike': 'Rider', // Default τιμή για παλιά δεδομένα
          };
        }
      }).toList() ?? [],
    );
  }

  // Μετατροπή από Αντικείμενο σε Firebase
  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'meetingPoint': meetingPoint,
      'participants': participants,
    };
  }

  // Helper method: Παίρνουμε μόνο τα IDs των συμμετεχόντων
  // Χρήση: if (ride.participantIds.contains(user.uid)) ...
  List<String> get participantIds =>
      participants.map((p) => p['uid'] as String).toList();
}