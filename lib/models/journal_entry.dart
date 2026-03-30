class JournalEntry {
  final int? id;
  final DateTime date;
  final String accomplished;
  final String grateful;
  final String winTomorrow;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    this.id,
    required this.date,
    required this.accomplished,
    required this.grateful,
    required this.winTomorrow,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if entry can be edited (same day only)
  bool get canEdit {
    final now = DateTime.now();
    final entryDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return entryDate.isAtSameMomentAs(today);
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'accomplished': accomplished,
      'grateful': grateful,
      'winTomorrow': winTomorrow,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from database map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      accomplished: map['accomplished'] as String,
      grateful: map['grateful'] as String,
      winTomorrow: map['winTomorrow'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // Create a copy with updated fields
  JournalEntry copyWith({
    int? id,
    DateTime? date,
    String? accomplished,
    String? grateful,
    String? winTomorrow,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      accomplished: accomplished ?? this.accomplished,
      grateful: grateful ?? this.grateful,
      winTomorrow: winTomorrow ?? this.winTomorrow,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
