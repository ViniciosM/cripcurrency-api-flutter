import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {

  DB._();

  static final DB instance = DB._();

  static Database? _database;

  get database async {
    if(_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'cripto.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, version) async {
    await db.execute(_account);
    await db.execute(_wallet);
    await db.execute(_historic);
    await db.insert('account', {'balance': 0});
  }

  String get _account => '''
    CREATE TABLE account (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      balance REAL
    ); ''';

  String get _wallet => '''
  CREATE TABLE wallet (
    acronym TEXT PRIMARY KEY,
    currency TEXT,
    quantity TEXT
  ); ''';

  String get _historic => '''
  CREATE TABLE historic (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operationDate INT,
    operationType TEXT,
    currency TEXT,
    acronym TEXT,
    value REAL,
    quantity TEXT
  ); ''';


}