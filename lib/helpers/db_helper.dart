import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  //static const String favTableName = "favorite_products_table";
  static const String favTableName = "favourite_products"; //favourite_products
  static Future<void> insert(String table, Map<String, Object> data) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'app_config.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE user_info(id TEXT PRIMARY KEY, isLoggedIn TEXT, username TEXT, name TEXT, email TEXT, picture TEXT, locationName TEXT,  locationCityId TEXT, locationCityName TEXT, locationStateId TEXT, locationStateName TEXT, locationCityState TEXT, countryCode TEXT)');
      },
      version: 1,
    );

    await sqlDb.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('Log in DB: ${await sqlDb.query('user_info')}');
  }

  static Future<void> update(String table, Map<String, Object> data) async {
    print(data["countryCode"]);
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'app_config.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE user_info(id TEXT PRIMARY KEY, isLoggedIn TEXT, username TEXT, name TEXT, email TEXT, picture TEXT, locationName TEXT,  locationCityId TEXT, locationCityName TEXT, locationStateId TEXT, locationStateName TEXT, locationCityState TEXT, countryCode TEXT)');
      },
      version: 1,
    );

    var check = await sqlDb.query('user_info');
    if (check.isEmpty) {
      await insert(table, data);
    } else {
      await sqlDb.update(
        table,
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    }

    // int count = await sqlDb.update(table, data, where: 'id = ?', whereArgs: [data['id']]);
    // int count = await sqlDb.rawUpdate('UPDATE user_info SET locationName = ?, locationCityId = ?, locationCityName = ?, locationStateId = ?, locationStateName = ?, locationCityState = ? WHERE id = }', ['${data['locationName']}, ${data['locationCityId']}, ${data['locationCityName']}, ${data['locationStateId']}, ${data['locationStateName']}, ${data['locationCityState']}']);
    // var count = await sqlDb.update('user_info', {'locationName': 'namtranx'}, where: 'id = ?', whereArgs: ['${data['id']}']);
    // print('update count: $count, data[id]: ${data}');
    print('UPDATE DATABASE: ${await sqlDb.query('user_info')}');
  }

  static Future<void> delete(String table) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'app_config.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE user_info(id TEXT PRIMARY KEY, isLoggedIn TEXT, username TEXT, name TEXT, email TEXT, picture TEXT, locationName TEXT,  locationCityId TEXT, locationCityName TEXT, locationStateId TEXT, locationStateName TEXT, locationCityState TEXT, countryCode TEXT)');
      },
      version: 1,
    );

    await sqlDb.delete(table);
    print('Delete previous user from DB: ${await sqlDb.query('user_info')}');
  }

  static Future read(String table) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'app_config.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE user_info(id TEXT PRIMARY KEY, isLoggedIn TEXT, username TEXT, name TEXT, email TEXT, picture TEXT, locationName TEXT,  locationCityId TEXT, locationCityName TEXT, locationStateId TEXT, locationStateName TEXT, locationCityState TEXT, countryCode TEXT)');
      },
      version: 1,
    );
    return await sqlDb.query(table);
  }

  static Future<void> insertFavProduct(
      String table, Map<String, Object> data) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'fav_products.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE $favTableName(id TEXT PRIMARY KEY, prodId TEXT)');
      },
      version: 1,
    );

    await sqlDb.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('Favourite products from DB: ${await sqlDb.query('$favTableName')}');
  }

  static Future<void> deleteFavProduct(String table, String prodId) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'fav_products.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE $favTableName(id TEXT PRIMARY KEY, prodId TEXT)');
      },
      version: 1,
    );

    await sqlDb.delete(table, where: 'id = ?', whereArgs: [prodId]);
    print(
        'Delete favourite product: ${await sqlDb.query('favourite_products')}');
  }

  static Future queryFavProduct(String table, String prodId) async {
    // Getting the path where all the local data is stored
    final dbPath = await sql.getDatabasesPath();

    // Opening existing database, or creates new if there is no database
    // path.join() joins strings and creates a path to our specific db file
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'fav_products.db'),
      onCreate: (db, version) {
        // In the "execute()" method we pass the SQLite statement
        return db.execute(
            'CREATE TABLE $favTableName(id TEXT PRIMARY KEY, prodId TEXT)');
      },
      version: 1,
    );

    final List<Map<String, dynamic>> result = prodId.toUpperCase() == "NOT NULL"
        ? await sqlDb.query(table)
        : await sqlDb.query(table, where: 'id = ?', whereArgs: [prodId]);
    print("DB_HELPER queryFavProduct result: $result");
    return result;
  }
}
