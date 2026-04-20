class Bike {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final double cc;
  final int mileage;
  final String? imageUrl; // ΝΕΟ: Το URL της φωτογραφίας της μηχανής

  Bike({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.cc,
    this.mileage = 0,
    this.imageUrl, // Προσθήκη στον constructor
  });

  factory Bike.fromMap(Map<String, dynamic> map, String documentId) {
    return Bike(
      id: documentId,
      userId: map['userId'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year']?.toInt() ?? 0,
      cc: map['cc']?.toDouble() ?? 0.0,
      mileage: map['mileage']?.toInt() ?? 0,
      imageUrl: map['imageUrl'], // Διάβασμα από το Firebase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'cc': cc,
      'mileage': mileage,
      'imageUrl': imageUrl, // Αποθήκευση στο Firebase
    };
  }
}