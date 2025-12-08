import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      profileImage TEXT
    )
  ''');

    // Default admin account
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@email.com',
      'password': '1234',
      'profileImage': null,
    });
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  Future<int> register(UserModel user) async {
    final db = await database;

    // Ensure non-null and trimmed strings
    final Map<String, dynamic> userMap = {
      'name': user.name.trim(),
      'email': user.email.trim().toLowerCase(),
      'password': user.password.trim(),
    };

    return await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.abort, // throws if duplicate
    );
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.toLowerCase(), password],
    );

    if (result.isNotEmpty) {
      try {
        return UserModel.fromMap(result.first);
      } catch (e) {
        print("Error parsing user from database: $e");
        return null;
      }
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');
    await deleteDatabase(path);
  }
}
