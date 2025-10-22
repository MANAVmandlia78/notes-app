import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  // Private constructor
  DbHelper._();

  // Singleton instance
  static final DbHelper getInstance = DbHelper._();

  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  Future<Database> getDb() async {
    if (myDB != null) {
      return myDB!;
    } else {
      myDB = await openDb();
      return myDB!;
    }
  }

  // Example method
  Future<Database> openDb() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    String dbPath = join(appDir.path, "noteDB.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement,$COLUMN_NOTE_TITLE text ,$COLUMN_NOTE_DESC text)",
        );
      },
      version: 1,
    );
  }

  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDb();

    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });

    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDb();
    List<Map<String, dynamic>> mdata = await db.query(TABLE_NOTE);

    return mdata;
  }

  Future<bool> updateNote({
    required String mTitle,
    required String mDesc,
    required int sno,
  }) async {
    var db = await getDb();
    int rowsEffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    }, where: "$COLUMN_NOTE_SNO = $sno");

    return rowsEffected > 0;
  }

  Future<bool> deleteNote({required int sno}) async {
    var db = await getDb();
    int rowsEffected = await db.delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);

    return rowsEffected > 0;
  }
}
