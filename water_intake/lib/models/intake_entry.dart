class IntakeEntry {
  final DateTime date;
  final int amount;

  IntakeEntry({required this.date, required this.amount});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };

  factory IntakeEntry.fromJson(Map<String, dynamic> json) => IntakeEntry(
        date: DateTime.parse(json['date']),
        amount: json['amount'],
      );
}
