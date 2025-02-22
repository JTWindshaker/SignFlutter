import 'dart:io';
import 'package:sign/features/requests/domain/entities/request_entity.dart';
import 'package:path/path.dart';

// 📌 Importaciones según la plataforma
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart'; // Para Android/iOS
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Para Windows, macOS y Linux

class RequestLocalDatasource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'signs.db');

    // 📌 Solo en Windows/macOS/Linux se usa `sqflite_common_ffi`
    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      return await databaseFactoryFfi.openDatabase(path);
    }

    // 📌 En Android/iOS usamos `openDatabase` normal
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE request (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nameFile TEXT NOT NULL,
            isSign INTEGER NOT NULL,
            dateSign TEXT,
            urlFile TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveRequest(RequestEntity request) async {
    final db = await database;
    await db.insert('request', {
      'nameFile': request.nameFile,
      'isSign': request.isSign ? 1 : 0,
      'dateSign': request.dateSign?.toIso8601String(),
      'urlFile': request.urlFile,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RequestEntity>> getRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('request');

    return List.generate(maps.length, (i) {
      return RequestEntity(
        nameFile: maps[i]['nameFile'],
        isSign: maps[i]['isSign'] == 1,
        dateSign:
            maps[i]['dateSign'] != null
                ? DateTime.parse(maps[i]['dateSign'])
                : null,
        urlFile: maps[i]['urlFile'],
      );
    });
  }
}
