import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report_model.dart';

class ReportDBHelper {
  static final ReportDBHelper instance = ReportDBHelper._init();
  static Database? _database;

  ReportDBHelper._init();

  Future<void> init() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reports.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // bump version to include adminNotes
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT,
        imagePath TEXT,
        status TEXT NOT NULL,
        date TEXT,
        user TEXT,
        adminNotes TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE reports ADD COLUMN imagePath TEXT');
      await db.execute('ALTER TABLE reports ADD COLUMN user TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE reports ADD COLUMN adminNotes TEXT');
    }
  }

  Future<int> insertReport(ReportModel report) async {
    final db = await database;
    return await db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // ensures update works
    );
  }

  Future<List<ReportModel>> getAllReports() async {
    final db = await database;
    final result = await db.query('reports', orderBy: 'id DESC');
    return result.map((map) => ReportModel.fromMap(map)).toList();
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateReport(ReportModel report) async {
    final db = await database;
    return await db.update(
      'reports',
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> deleteAllReports() async {
    final db = await database;
    await db.delete('reports');
  }
}
