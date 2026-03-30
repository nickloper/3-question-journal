import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        accomplished TEXT NOT NULL,
        grateful TEXT NOT NULL,
        winTomorrow TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  // Create or update entry
  Future<JournalEntry> saveEntry(JournalEntry entry) async {
    final db = await database;

    // Check if entry exists for this date
    final existing = await getEntryByDate(entry.date);

    if (existing != null) {
      // Update existing entry
      final updatedEntry = entry.copyWith(
        id: existing.id,
        updatedAt: DateTime.now(),
      );
      await db.update(
        'entries',
        updatedEntry.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return updatedEntry;
    } else {
      // Insert new entry
      final id = await db.insert('entries', entry.toMap());
      return entry.copyWith(id: id);
    }
  }

  // Get entry by date
  Future<JournalEntry?> getEntryByDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();

    final maps = await db.query(
      'entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return JournalEntry.fromMap(maps.first);
    }
    return null;
  }

  // Get all entries, sorted by date descending
  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query(
      'entries',
      orderBy: 'date DESC',
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  // Get current streak (consecutive days with entries)
  Future<int> getCurrentStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);

    // Check if there's an entry for today
    final todayEntry = await getEntryByDate(checkDate);
    if (todayEntry == null) {
      // If no entry today, start checking from yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Count consecutive days backwards
    for (var entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);

      if (entryDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(checkDate)) {
        // Found a gap in the streak
        break;
      }
    }

    return streak;
  }

  // Get total number of entries
  Future<int> getTotalEntries() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM entries');
    return result.first['count'] as int;
  }

  // Delete entry (if needed for future features)
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    await db.close();
  }
}
