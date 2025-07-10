class IntakeEntry {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String unit;
  final String? note;

  IntakeEntry({
    required this.id,
    required this.timestamp,
    required this.amount,
    this.unit = 'ml',
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'amount': amount,
      'unit': unit,
      'note': note,
    };
  }

  factory IntakeEntry.fromJson(Map<String, dynamic> json) {
    return IntakeEntry(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      amount: json['amount'].toDouble(),
      unit: json['unit'] ?? 'ml',
      note: json['note'],
    );
  }

  IntakeEntry copyWith({
    String? id,
    DateTime? timestamp,
    double? amount,
    String? unit,
    String? note,
  }) {
    return IntakeEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }
}