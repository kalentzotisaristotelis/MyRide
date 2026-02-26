class ServiceRecord {
  final String id;
  final String bikeId;
  final String userId;
  final String title;
  final DateTime date;
  final int mileage;
  final String notes;
  final double cost;

  ServiceRecord({
    required this.id,
    required this.bikeId,
    required this.userId,
    required this.title,
    required this.date,
    required this.mileage,
    required this.notes,
    required this.cost,
  });

  factory ServiceRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceRecord(
      id: documentId,
      bikeId: map['bikeId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      mileage: map['mileage']?.toInt() ?? 0,
      notes: map['notes'] ?? '',
      cost: map['cost']?.toDouble() ?? 0.0, // ΝΕΟ: Αν παλιό service δεν έχει, βάζει 0.0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bikeId': bikeId,
      'userId': userId,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'mileage': mileage,
      'notes': notes,
      'cost': cost, // ΝΕΟ
    };
  }
}