// ignore_for_file: avoid_print

import 'dart:async';
import 'package:leit/data/model/leitnerModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:leit/data/model/item_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "leit.db");

    return await openDatabase(
      path,
      version: 4, // نسخه به 4 افزایش یافت
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        german TEXT NOT NULL,
        en TEXT NOT NULL, 
        fa TEXT NOT NULL,
        examples TEXT NOT NULL,
        examplesEn TEXT, -- ستون جدید
        examplesFa TEXT, -- ستون جدید
        article TEXT,
        plural TEXT,
        prateritum TEXT,
        perfekt TEXT,
        partizip TEXT,
        synonyms TEXT,
        antonyms TEXT,
        explanation TEXT,
        level TEXT NOT NULL,
        tags TEXT,
        notes TEXT,
        createdAt INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE leitner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER NOT NULL,
        box INTEGER NOT NULL,
        nextReview INTEGER NOT NULL,
        lastReview INTEGER NOT NULL,
        reviewCount INTEGER NOT NULL,
        wrongCount INTEGER NOT NULL,
        isSuspended INTEGER NOT NULL,
        easeFactor REAL DEFAULT 2.5,
        lastInterval INTEGER DEFAULT 0,

        FOREIGN KEY (itemId) REFERENCES items(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // مایگریشن نسخه ۱ به ۲
      await db.execute('''
        CREATE TABLE IF NOT EXISTS leitner (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemId INTEGER NOT NULL,
          box INTEGER NOT NULL,
          nextReview INTEGER NOT NULL,
          lastReview INTEGER NOT NULL,
          reviewCount INTEGER NOT NULL,
          wrongCount INTEGER NOT NULL,
          isSuspended INTEGER NOT NULL,
          FOREIGN KEY (itemId) REFERENCES items(id) ON DELETE CASCADE
        );
      ''');
    }

    if (oldVersion < 3) {
      // مایگریشن به نسخه ۳
      try {
        await db.execute(
          "ALTER TABLE leitner ADD COLUMN easeFactor REAL DEFAULT 2.5",
        );
        await db.execute(
          "ALTER TABLE leitner ADD COLUMN lastInterval INTEGER DEFAULT 0",
        );
      } catch (e) {
        print("Migration Error (Expected if dev): $e");
      }
    }

    if (oldVersion < 4) {
      // مایگریشن به نسخه ۴: اضافه کردن ستون‌های ترجمه مثال
      try {
        await db.execute("ALTER TABLE items ADD COLUMN examplesEn TEXT");
        await db.execute("ALTER TABLE items ADD COLUMN examplesFa TEXT");
      } catch (e) {
        print("Migration Error (v4): $e");
      }
    }
  }

  // --- CRUD Methods ---
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert("items", item.toMap());
  }

  Future<bool> itemExists(String germanWord) async {
    final db = await database;
    final result = await db.query(
      "items",
      where: "german = ?",
      whereArgs: [germanWord],
    );
    return result.isNotEmpty;
  }

  Future<int> insertLeitner(LeitnerModel item) async {
    final db = await database;
    return await db.insert("leitner", item.toMap());
  }

  Future<List<Map<String, dynamic>>> getLeitnerByItem(int itemId) async {
    final db = await database;
    return await db.query("leitner", where: "itemId = ?", whereArgs: [itemId]);
  }

  Future<int> updateLeitner(LeitnerModel m) async {
    final db = await database;
    return await db.update(
      "leitner",
      m.toMap(),
      where: "id = ?",
      whereArgs: [m.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete("items", where: "id = ?", whereArgs: [id]);
  }

  // --- Statistics Queries ---
  Future<Map<int, int>> getLeitnerBoxCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT box, COUNT(*) as count FROM leitner GROUP BY box
    ''');
    Map<int, int> stats = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (var row in result) {
      int box = row['box'] as int? ?? 0;
      int count = row['count'] as int? ?? 0;
      if (stats.containsKey(box)) stats[box] = count;
    }
    return stats;
  }

  Future<int> getReviewedTodayCount(int startOfDayTimestamp) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM leitner WHERE lastReview >= ?',
      [startOfDayTimestamp],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getLearnedTodayCount(int startOfDayTimestamp) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM leitner WHERE lastReview >= ? AND box > 1',
      [startOfDayTimestamp],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getReviewHistorySince(
    int timestamp,
  ) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT lastReview, reviewCount, wrongCount FROM leitner WHERE lastReview >= ? ORDER BY lastReview ASC',
      [timestamp],
    );
  }

  Future<List<Map<String, dynamic>>> getAccuracyByType() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT i.type, SUM(l.reviewCount) as total, SUM(l.wrongCount) as wrong
      FROM items i
      JOIN leitner l ON i.id = l.itemId
      GROUP BY i.type
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  Future<String> getDbPath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, "leit.db");
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete("leitner");
    await db.delete("items");
  }
}
