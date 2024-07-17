import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance; 
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'starlingcycles.db');

    bool dbExists = await databaseExists(path);

    if (!dbExists){
      try {
        ByteData data = await rootBundle.load('assets/starlingcycles.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await Directory(dirname(path)).create(recursive: true);
      await File(path).writeAsBytes(bytes);
      }
      catch (e) {
        print(e);
      }
    }

    return await openDatabase(
      path, 
      //version: 1, 
      onOpen: (db) {
      print('Opened database {$path}');
    });
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> insertItem(String table, Map<String, dynamic> data) async {
    final db = await database;
    print('Inserted into $table');

    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getBatchFrame(String table, String batch) async {
    final db = await database;
    return await db.query(table, where: 'batchNumber = ?', whereArgs: [batch]);
  }
}
