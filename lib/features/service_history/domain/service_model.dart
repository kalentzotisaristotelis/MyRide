class ServiceRecord {
  final String id;
  final String bikeId; // Σε ποια μηχανή ανήκει αυτό το service
  final String title;  // π.χ. "Αλλαγή Λαδιών", "Αλλαγή Ελαστικών"
  final DateTime date; // Πότε έγινε
  final int mileage;   // Σε πόσα χιλιόμετρα έγινε
  final String notes;  // Έξτρα σημειώσεις (π.χ. "Έβαλα Motul 10W-40")

  ServiceRecord({
    required this.id,
    required this.bikeId,
    required this.title,
    required this.date,
    required this.mileage,
    required this.notes,
  });

  // Από Firebase σε Αντικείμενο
  factory ServiceRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceRecord(
      id: documentId,
      bikeId: map['bikeId'] ?? '',
      title: map['title'] ?? '',
      // Το Firebase αποθηκεύει την ημερομηνία σε χιλιοστά του δευτερολέπτου (milliseconds)
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      mileage: map['mileage']?.toInt() ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  // Από Αντικείμενο σε Firebase
  Map<String, dynamic> toMap() {
    return {
      'bikeId': bikeId,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'mileage': mileage,
      'notes': notes,
    };
  }
}