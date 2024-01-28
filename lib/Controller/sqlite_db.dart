import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SQLiteDB {
  static const String _dbName = "Lab_db";

  Database? _db;

  SQLiteDB._();
  static final SQLiteDB _instance = SQLiteDB._();

  factory SQLiteDB() {
    return _instance;
  }

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    String path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(path, version: 1, onCreate: (createdDb, version) async {
      for (String tableSql in SQLiteDB.tableSQLStrings) {
        await createdDb.execute(tableSql);
      }
    });
    return _db!;
  }

  static List<String> tableSQLStrings = [
    '''
        CREATE TABLE IF NOT EXISTS expense (id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount DOUBLE,
            desc TEXT,
            dateTime DATETIME)
            ''',
  ];

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    Database db = await _instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }

  Future<int> update(String tableName, String idColumn, Map<String, dynamic> row) async {
    Database db = await _instance.database;
    dynamic id = row[idColumn];

    // Update locally
    int localUpdateResult = await db.update(tableName, row, where: '$idColumn = ?', whereArgs: [id]);

    // Update remotely
    await updateRemotely(tableName, idColumn, id, row);

    return localUpdateResult;
  }

  Future<int> delete(String tableName, String idColumn, dynamic idValue) async {
    Database db = await _instance.database;

    // Delete locally
    int localDeleteResult = await db.delete(tableName, where: '$idColumn = ?', whereArgs: [idValue]);

    // Delete remotely
    await deleteRemotely(tableName, idColumn, idValue);

    return localDeleteResult;
  }

  Future<void> updateRemotely(String tableName, String idColumn, dynamic idValue, Map<String, dynamic> row) async {
    // Replace the URL with your actual remote update API endpoint
    String remoteUpdateUrl = 'http://your_remote_api_url/update_expense';

    // Create a map containing the necessary data for the remote update
    Map<String, dynamic> remoteData = {
      'tableName': tableName,
      'idColumn': idColumn,
      'idValue': idValue,
      'row': row,
    };

    // Send a POST request to the remote API
    await http.post(
      Uri.parse(remoteUpdateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(remoteData),
    );
  }

  Future<void> deleteRemotely(String tableName, String idColumn, dynamic idValue) async {
    // Replace the URL with your actual remote delete API endpoint
    String remoteDeleteUrl = 'http://your_remote_api_url/delete_expense';

    // Create a map containing the necessary data for the remote delete
    Map<String, dynamic> remoteData = {
      'tableName': tableName,
      'idColumn': idColumn,
      'idValue': idValue,
    };

    // Send a POST request to the remote API
    await http.post(
      Uri.parse(remoteDeleteUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(remoteData),
    );
  }
}