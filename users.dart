import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "UserDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'user_table';
  static final columnId = 'id';
  static final columnEmail = 'email';
  static final columnPassword = 'password';

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Open the database (and create it if it doesn't exist).
  _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnEmail TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database
  Future<int> signUp(String email, String password) async {
    Database db = await instance.database;
    return await db.insert(table, {columnEmail: email, columnPassword: password});
  }

  // Query the database for a user
  Future<List<Map<String, dynamic>>> signIn(String email, String password) async {
    Database db = await instance.database;
    return await db.query(table,
        where: '$columnEmail = ? AND $columnPassword = ?',
        whereArgs: [email, password]);
  }
}