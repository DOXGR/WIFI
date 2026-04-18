import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bandwidth.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future _createDB(Database db, int version) async {
    const table = '''
      CREATE TABLE bandwidth_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        uploadKbps INTEGER NOT NULL,
        downloadKbps INTEGER NOT NULL
      )
    ''';
    await db.execute(table);
  }

  static Future<void> insertBandwidth(int uploadKbps, int downloadKbps) async {
    final db = await database;
    await db.insert('bandwidth_history', {
      'timestamp': DateTime.now().toIso8601String(),
      'uploadKbps': uploadKbps,
      'downloadKbps': downloadKbps,
    });
    
    // Auto-cleanup: Keep only last 100 entries to save space
    await db.rawDelete(
      'DELETE FROM bandwidth_history WHERE id NOT IN (SELECT id FROM bandwidth_history ORDER BY id DESC LIMIT 100)'
    );
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('bandwidth_history', orderBy: 'id ASC', limit: 100);
  }
}
