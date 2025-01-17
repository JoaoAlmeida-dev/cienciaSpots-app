import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:sqflite/sqflite.dart';

import '../../timeline/topic.dart';
import '../database_helper.dart';

class DatabaseTopicTable {
  static const table = 'topicTable';

  static const columnId = '_id';
  static const columnTitle = 'title';

/*  static String initScript = '''
      CREATE TABLE topicTable(
      _id INTEGER PRIMARY KEY,
      title TEXT,
      link TEXT
      )
    ''';*/

  static Future onCreate(Database db) async {
    db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT UNIQUE
      )
    ''');
    LoggerService.instance.debug("Created $table");
  }

  static Future<int> getMaxId() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    String query = "SELECT MAX($columnId) AS max_id FROM $table";
    List<Map<String, Object?>> rawQuery = await db.rawQuery(query, null);
    rawQuery.first["max_id"];
    LoggerService.instance.debug(rawQuery.first["max_id"]);
    return rawQuery.first["max_id"] as int;
  }

  static Future<List<Topic>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows =
        await db.query(table, orderBy: columnTitle);
    List<Topic> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => Topic.fromJson(e)).toList()
        : [];
    return rowsList;
  }

  static Future<List<Topic>> getAllWithIds(List<int> idList) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      orderBy: columnTitle,
      where: '$columnId IN (${List.filled(idList.length, '?').join(',')})',
      whereArgs: idList,
    );
    List<Topic> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => Topic.fromJson(e)).toList()
        : [];
    return rowsList;
  }

  static Future<int> add(Topic entry) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int insertedID = await db.insert(
      table,
      entry.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    LoggerService.instance.debug("Inserted: $entry into $table");
    return insertedID;
  }

  static Future<void> addBatch(List<Topic> entries) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in entries) {
      batch.insert(
        table,
        entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    batch.commit();
    LoggerService.instance
        .debug("Inserted: $entries into $table as batch into $table");
  }

  static Future<List<Topic>> where(
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);

    List<Topic> contentList = contents.isNotEmpty
        ? contents.map((e) => Topic.fromJson(e)).toList()
        : [];
    return contentList;
  }

  static Future<int> remove(int id) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    LoggerService.instance.debug("Removing entry with id:$id from $table");
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> removeALL() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    LoggerService.instance.debug("Removing all entries from $table");
    return await db.delete(table);
  }

  static Future<void> drop(Database db) async {
    LoggerService.instance.debug("Dropping $table");
    return await db.execute('DROP TABLE IF EXISTS $table');
  }
}
