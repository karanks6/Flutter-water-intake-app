import 'package:uuid/uuid.dart';

class IntakeEntry {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String note;

  IntakeEntry({
    String? id,
    required this.amount,
    required this.timestamp,
    this.note = '',
  }) : id = id ?? Uuid().v4();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'note': note,
    };
  }

  // Create from Map
  factory IntakeEntry.fromMap(Map<String, dynamic> map) {
    return IntakeEntry(
      id: map['id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      note: map['note'] ?? '',
    );
  }

  // Create copy with modifications
  IntakeEntry copyWith({
    String? id,
    double? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return IntakeEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'IntakeEntry(id: $id, amount: $amount, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntakeEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}