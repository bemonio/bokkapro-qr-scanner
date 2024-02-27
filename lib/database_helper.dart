import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'brinks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE qr_data(
            id INTEGER PRIMARY KEY,
            device TEXT,
            datetime TEXT,
            latitude TEXT,
            longitude TEXT,
            qr_data TEXT,
            qr_type TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('qr_data', data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> results = await dbClient.query(
      'qr_data',
      orderBy: 'datetime DESC',
    );
    return results.isNotEmpty ? results : List<Map<String, dynamic>>.empty();
  }

  Future<void> resetDatabase() async {
    final dbClient = await db;
    await dbClient.close();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'brinks.db');
    await deleteDatabase(path);
    _db = null;
  }

  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'brinks.db');
  }
}
