class Ride {
  final String id;
  final String creatorId; // Το ID αυτού που τη διοργανώνει
  final String title; // π.χ. "Κυριακάτικη Βόλτα Σούνιο"
  final String description; // Λεπτομέρειες, ρυθμός, στάσεις
  final DateTime date; // Πότε θα γίνει
  final String meetingPoint; // Πού μαζευόμαστε
  final List<String> participants; // Λίστα με τα IDs αυτών που πάτησαν "Θα πάω"

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
      // Διαβάζουμε τη λίστα των συμμετεχόντων με ασφάλεια
      participants: List<String>.from(map['participants'] ?? []),
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
}