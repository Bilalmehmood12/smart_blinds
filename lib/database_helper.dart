import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model/item.dart';

class DatabaseHelper {

  static final _dbName = "myDatabase.db";
  static final _dbVersion = 1;
  static final _blindTable = "Table1";
  static final _scheduledBlindTable = "Table2";

  static final columnKey = "_id";
  static final columnName = "name";
  static final columnImg = "img";
  static final columnCLevel = "cLevel";
  static final columnTLevel = "tLevel";
  static final columnEnable = "enable";
  static final columnScheduled = "scheduled";
  static final columnTime = "time";
  static final columnWeekDays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];


  static final instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,_dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);

  }


  FutureOr<void> _onCreate(Database db, int version) async {
    final keyType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final intType = 'INTEGER NOT NULL';
    final doubleType = 'REAL NOT NULL';
    final stringType = 'TEXT NOT NULL';
    await db.execute(
      '''
      CREATE TABLE $_blindTable (
      $columnKey $keyType,
      $columnName $stringType,
      $columnImg $stringType,
      $columnCLevel $doubleType,
      $columnTLevel $doubleType,
      $columnEnable $intType,
      $columnScheduled $intType,
      $columnTime $stringType,
      ${columnWeekDays[0]} $intType,
      ${columnWeekDays[1]} $intType,
      ${columnWeekDays[2]} $intType,
      ${columnWeekDays[3]} $intType,
      ${columnWeekDays[4]} $intType,
      ${columnWeekDays[5]} $intType,
      ${columnWeekDays[6]} $intType
      )
      '''
    );
    await db.execute(
        '''
      CREATE TABLE $_scheduledBlindTable (
      $columnKey $keyType,
      $columnName $stringType,
      $columnImg $stringType,
      $columnCLevel $doubleType,
      $columnTLevel $doubleType,
      $columnEnable $intType,
      $columnScheduled $intType,
      $columnTime $stringType,
      ${columnWeekDays[0]} $intType,
      ${columnWeekDays[1]} $intType,
      ${columnWeekDays[2]} $intType,
      ${columnWeekDays[3]} $intType,
      ${columnWeekDays[4]} $intType,
      ${columnWeekDays[5]} $intType,
      ${columnWeekDays[6]} $intType
      )
      '''
    );
  }

  Future<int> insert(Item item) async {
    Database db = await instance.database;
    final id = await db.insert(_blindTable, item.toJson());
    return id;
  }
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(_blindTable, where: '$columnKey = ?', whereArgs: [id]);
  }
  Future<int> update(Item item) async {
    Database db = await instance.database;
    var id = item.id;
    return await db.update(_blindTable, item.toJson(), where: '$columnKey = ?', whereArgs: [id]);
  }
  Future<List<Item>> queryAll() async {
    Database db = await instance.database;
    final res = await db.query(_blindTable);
    if (res.isNotEmpty) {
      return res.map((item) => Item.fromJson(item)).toList();
    }
    return [];
  }


  Future<int> insertScheduled(Item item) async {
    Database db = await instance.database;
    final id = await db.insert(_scheduledBlindTable, item.toJson());
    return id;
  }
  Future<int> deleteScheduled(int id) async {
    Database db = await instance.database;
    return await db.delete(_scheduledBlindTable, where: '$columnKey = ?', whereArgs: [id]);
  }
  Future<int> deleteScheduledByName(String name) async {
    Database db = await instance.database;
    return await db.delete(_scheduledBlindTable, where: '$columnName = ?', whereArgs: [name]);
  }
  Future<int> updateScheduled(Item item) async {
    Database db = await instance.database;
    var id = item.id;
    return await db.update(_scheduledBlindTable, item.toJson(), where: '$columnKey = ?', whereArgs: [id]);
  }
  Future<List<Item>> queryAllScheduled() async {
    Database db = await instance.database;
    final res = await db.query(_scheduledBlindTable);
    if (res.isNotEmpty) {
      return res.map((item) => Item.fromJson(item)).toList();
    }
    return [];
  }

  Future close() async {
    Database db = await instance.database;
    db.close();
  }
}