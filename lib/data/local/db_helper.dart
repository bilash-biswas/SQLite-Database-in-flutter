import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  final String tableNote = 'note';
  static final String columnNoteSNo = 's_no';
  static final String columnNoteTitle = 'title';
  static final String columnNoteDesc = 'desc';

  Database? _database;

  Future<Database> getdatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDB();
    return _database!;
  }

  Future<Database> _openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'noteDB.db');

    return await openDatabase(
        dbPath, version: 1, onCreate: (db, version) async {
      await db.execute(
          '''
        CREATE TABLE $tableNote (
          $columnNoteSNo INTEGER PRIMARY KEY AUTOINCREMENT, 
          $columnNoteTitle TEXT, 
          $columnNoteDesc TEXT
        )
        '''
      );
    });
  }

  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getdatabase();
    int result = await db.insert(tableNote, {
      columnNoteTitle: mTitle,
      columnNoteDesc : mDesc
    });

    return result > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async{
    var db = await getdatabase();

    List<Map<String, dynamic>> mData = await db.query(tableNote);

    return mData;
  }

  Future<bool> updateNote({required String title, required String description, required int serialNo}) async{
    var db = await getdatabase();

    int rowsEffected = await db.update(tableNote, {
      columnNoteTitle : title,
      columnNoteDesc : description
    }, where: '$columnNoteSNo = $serialNo');

    return rowsEffected > 0;
  }

  Future<bool> deleteNote({required int serialNo}) async{
    var db = await getdatabase();
    int rowsEffected = await db.delete(tableNote, where: '$columnNoteSNo = $serialNo');
    return rowsEffected>0;
  }

  Future<void> close() async {
    final db = await getdatabase();
    db.close();
  }
}
