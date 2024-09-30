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
    String dbPath = await _getDatabasePath('starlingcycles.db');
    bool dbExists = await databaseExists(dbPath);

    if (! dbExists) {
      await _copyDatabase(dbPath);
    }
    return await openDatabase(
      dbPath,
      onOpen: (db)async {
        print('Opened database $dbPath');
        await populate(db);
      }
    );
  }
  Future<String> _getDatabasePath(String dbName) async {
    return join(await getDatabasesPath(), dbName);
  }
  Future<bool> databaseExists(String path) async {
    return File(path).exists();
  }
  Future<void> _copyDatabase(String dbPath) async {
    ByteData data = await rootBundle.load('assets/starlingcycles.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes);
  }
  Future<void> populate(Database db) async{
    List<Map<String, dynamic>> data = [
      {
      'manufactureName': 'Mitre',
      'procedure': '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15',
    }
    ];
    /*for (var item in data) {
      final mitre = await db.query('Manufacture', where: 'manufactureName = ?', whereArgs: [item['manufactureName']]);
      if(!mitre.isNotEmpty) {
        await db.insert('Manufacture', item);
      }
    }*/
    List<Map<String, dynamic>> processes = [
      {
        "process_id": 1,
        "processName": "Set Up",
        "processType": "tick"
      },
      {
        "process_id": 2,
        "processName": "Tacking",
        "processType": "timer"
      },
      {
        "process_id": 3,
        "processName": "Braze",
        "processType": "timer"
      },
      {
        "process_id": 4,
        "processName": "Heat Tube Gussets",
        "processType": "timer"
      },
      {
        "process_id": 5,
        "processName": "clean up",
        "processType": "tick"
      },
      {
        "process_id": 6,
        "processName": "HT Ream",
        "processType": "timer"
      },
      {
        "process_id": 7,
        "processName": "MP Ream",
        "processType": "timer"
      },
      {
        "process_id": 8,
        "processName": "ST Ream",
        "processType": "timer"
      },
      {
        "process_id": 9,
        "processName": "Cable Guides",
        "processType": "timer"
      },
      {
        "process_id": 10,
        "processName": "ISCG",
        "processType": "timer"
      },
      {
        "process_id": 11,
        "processName": "ST Shim Bond",
        "processType": "timer"
      },
      {
        "process_id": 12,
        "processName": "ST Shim Ream",
        "processType": "timer"
      },
      {
        "process_id": 13,
        "processName": "HT Breather Holes",
        "processType": "timer"
      },
      {
        "process_id": 14,
        "processName": "BB Chase",
        "processType": "timer"
      },
      {
        "process_id": 15,
        "processName": "QC",
        "processType": "tick"
      }
    ];
    for (var item in processes) {
      final process = await db.query('Process', where: 'process_id = ?', whereArgs: [item['process_id']]);
      if(process.isEmpty) {
      await db.insert('Process', item);
      }
    }
  }
/*
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
*/
  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> insertManufacture(String table, Map<String, dynamic> data) async {
    final db = await database;
    final exist = await db.query(table, where: 'manufactureName = ?', whereArgs: [data['manufactureName']]);
    if (exist.isNotEmpty) {
      return 0;
    }
    else {
      print('Inserted into $table');
      return await db.insert(table, data);
    }
  }

  Future<List<Map<String, dynamic>>> queryBatches(String status) async {
    final db = await database;
    return await db.query('Batch', where: 'Status = ?', whereArgs: [status]);
  }

  Future<int> insertBatch(String table, Map<String, dynamic> data) async {
    final db = await database;
    final exist = await db.query(table, where: 'batchName = ?', whereArgs: [data['batchName']]);
    if (exist.isNotEmpty) {
      return 0;
    }
    else {
      print('Inserted into $table');
      return await db.insert(table, data);
    }
  }

  Future<int> insertProcess(String table, Map<String, dynamic> data) async {
    final db = await database;
    final exist = await db.query(table, where: 'processName = ?', whereArgs: [data['processName']]);
    if (exist.isNotEmpty) {
      return 0;
    }
    else {
      print('Inserted into $table');
      return await db.insert(table, data);
    }
  }

  Future<int> insertFrame(String table, Map<String, dynamic> data) async {
    final db = await database;
    final exist = await db.query(table, where: 'frameNumber = ?', whereArgs: [data['frameNumber']]);
    if (exist.isNotEmpty) {
      return 0;
    }
    else {
      print('Inserted into $table');
      return await db.insert(table, data);
    }
  }

  Future<List<Map<String, dynamic>>> getBatch(String table, String batch) async {
    final db = await database;
    return await db.query(table, where: 'batchName = ?', whereArgs: [batch]);
  }

  Future<List<Map<String, dynamic>>> getManufacture(String table, String manufacture) async {
    final db = await database;
    return await db.query(table, where: 'manufactureName = ?', whereArgs: [manufacture]);
  }

  Future<List<Map<String, dynamic>>> getProcess(String table, String processID) async {
    final db = await database; 
    return await db.query(table, where: 'process_id = ?', whereArgs: [processID]);
  }

  Future<List<Map<String, dynamic>>> getProcessID(String table, String processName) async {
    final db = await database;
    return await db.query(table, where: 'processName = ?', whereArgs: [processName]);
  }

  Future<List<Map<String, dynamic>>> getBatchFrame(String table, String batch) async {
    final db = await database;
    return await db.query(table, where: 'batchNumber = ?', whereArgs: [batch]);
  }

  Future<dynamic>addProcesses(String processName, String processType) async {
    final db = await database;
    List columns = await db.rawQuery('PRAGMA table_info(Frame)');
    print(columns);
    processName = processName.replaceAll(' ', '');
    for (var column in columns) {
      if (column['name'] == processName) {
        return 1;
      }
    }
    if (processType == 'timer' ){
      print('Added $processName $processType to Frames');
      return await db.execute(
        "ALTER TABLE Frame ADD COLUMN $processName TIME"
      );
    }
    else {
      print('Added $processName $processType to Frames');
      return await db.execute(
        "ALTER TABLE Frame ADD $processName BOOLEAN DEFAULT FALSE"
      );
    
    }
  }

  Future<dynamic> updateProcessTick(String frameNumber, String processName, bool value) async {
    final db = await database;
    return await db.update('Frame', {processName: value}, where: 'frameNumber = ?', whereArgs: [frameNumber]);
  }

  Future<dynamic> updateProcessTimer(String frameNumber, String processName, String value) async {
    print('Updating $processName to $value');
    final db = await database;
    return await db.update('Frame', {processName: value}, where: 'frameNumber = ?', whereArgs: [frameNumber]);
  } 

  Future<dynamic> deleteBatch(String table, String batch) async {
    final db = await database;
    return await db.delete(table, where: 'batchName = ?', whereArgs: [batch]);
  }

  Future<dynamic> deleteFrame(String table, String frame) async {
    final db = await database;
    return await db.delete(table, where: 'frameNumber = ?', whereArgs: [frame]);
  }

  Future<dynamic> updateStatus(String batch, String status) async {
    final db = await database;
    return await db.update('Batch', {'Status': status}, where: 'batchName = ?', whereArgs: [batch]);
  }
}
