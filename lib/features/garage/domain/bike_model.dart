class Bike {
  final String id;
  final String userId; // Ποιανού χρήστη είναι η μηχανή
  final String make;   // Μάρκα (π.χ. Honda)
  final String model;  // Μοντέλο (π.χ. CBR)
  final int year;      // Χρονολογία
  final double cc;     // Κυβικά

  Bike({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.cc,
  });

  // Μετατροπή από δεδομένα Firebase -> σε Αντικείμενο Bike
  factory Bike.fromMap(Map<String, dynamic> map, String documentId) {
    return Bike(
      id: documentId,
      userId: map['userId'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year']?.toInt() ?? 0,
      cc: map['cc']?.toDouble() ?? 0.0,
    );
  }

  // Μετατροπή από Αντικείμενο Bike -> σε δεδομένα για Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'cc': cc,
    };
  }
}