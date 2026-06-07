import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('electricity_bills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bill_records (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        month         TEXT    NOT NULL,
        units         REAL    NOT NULL,
        rebate_percent REAL   NOT NULL,
        total_charges REAL    NOT NULL,
        final_cost    REAL    NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(BillRecord record) async {
    final db = await database;
    return db.insert('bill_records', record.toMap());
  }

  Future<List<BillRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('bill_records', orderBy: 'id DESC');
    return maps.map(BillRecord.fromMap).toList();
  }

  Future<int> updateRecord(BillRecord record) async {
    final db = await database;
    return db.update(
      'bill_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete('bill_records', where: 'id = ?', whereArgs: [id]);
  }
}