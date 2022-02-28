

class DB {

  DB._();

  static final DB instance = DB._();

  static Database? database;

  get database async {
    if(_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() asyns {
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
    coin TEXT,
    quantity TEXT
  ); ''';

  String get _historic => '''
  CREATE TABLE historic (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operationDate INT,
    operationType TEXT,
    coin TEXT,
    acronym TEXT,
    value REAL,
    quantity TEXT
  ); ''';


}