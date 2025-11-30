// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CloudBackupService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تغییر نام فایل به v2 برای پشتیبانی از ساختار جدید (شامل آمار)
  String get _fileName => 'backup_v2.json.gz';

  /// 📤 آپلود بکاپ کامل (شامل کلمات + وضعیت جعبه‌ها)
  Future<void> uploadBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final db = await DBHelper.instance.database;

      // ۱. خواندن تمام آیتم‌ها (کلمات)
      final List<Map<String, dynamic>> itemsResult = await db.query('items');

      // ۲. خواندن تمام داده‌های لایتنر (آمار و وضعیت جعبه‌ها)
      final List<Map<String, dynamic>> leitnerResult = await db.query(
        'leitner',
      );

      // ۳. ساخت ساختار کلی بکاپ
      final Map<String, dynamic> backupData = {
        'version': 2,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'items': itemsResult, // ذخیره مستقیم مپ‌ها
        'leitner': leitnerResult, // ذخیره آمار
      };

      // ۴. تبدیل به JSON
      final String jsonString = jsonEncode(backupData);

      // ۵. فشرده‌سازی (GZip)
      final List<int> jsonBytes = utf8.encode(jsonString);
      final List<int> compressedBytes = GZipCodec().encode(jsonBytes);

      // ۶. ذخیره موقت و آپلود
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$_fileName');
      await tempFile.writeAsBytes(compressedBytes);

      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.putFile(tempFile);

      debugPrint(
        "✅ Full Backup uploaded successfully (Items: ${itemsResult.length}, Stats: ${leitnerResult.length})",
      );
    } catch (e) {
      debugPrint("❌ Backup Error: $e");
      rethrow;
    }
  }

  /// 📥 دانلود و بازگردانی بکاپ (هوشمند)
  Future<void> restoreBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');

      // ۱. دانلود فایل
      final Uint8List? compressedBytes = await ref.getData(
        10 * 1024 * 1024,
      ); // 10MB limit

      if (compressedBytes == null) {
        throw Exception("No backup found");
      }

      // ۲. استخراج فایل
      final List<int> jsonBytes = GZipCodec().decode(compressedBytes);
      final String jsonString = utf8.decode(jsonBytes);

      // ۳. پارس کردن داده‌ها
      final dynamic decoded = jsonDecode(jsonString);

      List<ItemModel> items = [];
      List<Map<String, dynamic>> leitnerList = [];

      // پشتیبانی از نسخه قدیمی (که فقط لیست بود) و نسخه جدید (که Map است)
      if (decoded is List) {
        // فرمت قدیمی v1 (فقط آیتم‌ها، بدون آمار)
        items = decoded.map((e) => ItemModel.fromDB(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        // فرمت جدید v2 (آیتم‌ها + آمار)
        if (decoded['items'] != null) {
          items = (decoded['items'] as List)
              .map((e) => ItemModel.fromDB(e))
              .toList();
        }
        if (decoded['leitner'] != null) {
          leitnerList = (decoded['leitner'] as List)
              .cast<Map<String, dynamic>>();
        }
      }

      // ۴. بازگردانی به دیتابیس (Merge)
      final db = await DBHelper.instance.database;

      await db.transaction((txn) async {
        // الف) بازگردانی آیتم‌ها
        for (var item in items) {
          // چک کنیم اگر آیتم وجود ندارد، اضافه کنیم (با حفظ ID)
          final exists = await txn.query(
            'items',
            where: 'id = ?',
            whereArgs: [item.id],
          );

          if (exists.isEmpty) {
            await txn.insert('items', item.toMap());
          }
        }

        // ب) بازگردانی آمار لایتنر
        for (var l in leitnerList) {
          final int itemId = l['itemId'];

          // ۱. مطمئن شویم آیتم مربوطه وجود دارد (اگر آیتم نباشد، آمار بی‌معنی است)
          final itemExists = await txn.query(
            'items',
            where: 'id = ?',
            whereArgs: [itemId],
          );
          if (itemExists.isEmpty) continue;

          // ۲. چک کنیم آیا برای این آیتم قبلاً آماری در دستگاه داریم؟
          // اگر کاربر روی دستگاه فعلی تمرین کرده باشد، نمی‌خواهیم آمارش با نسخه قدیمی بکاپ خراب شود.
          final statsExist = await txn.query(
            'leitner',
            where: 'itemId = ?',
            whereArgs: [itemId],
          );

          if (statsExist.isEmpty) {
            // کپی کردن Map برای تغییر آن (حذف ID برای جلوگیری از تداخل)
            final Map<String, dynamic> newStat = Map.from(l);
            newStat.remove(
              'id',
            ); // ID را حذف می‌کنیم تا خود دیتابیس ID جدید بدهد

            await txn.insert('leitner', newStat);
          }
        }
      });

      debugPrint(
        "✅ Restore complete. Items: ${items.length}, Stats processed.",
      );
    } catch (e) {
      debugPrint("❌ Restore Error: $e");
      rethrow;
    }
  }

  /// 🗑️ حذف بکاپ ابری
  Future<void> deleteBackup() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.delete();
      debugPrint("✅ Cloud backup deleted.");
    } catch (e) {
      debugPrint("⚠️ Failed to delete cloud backup: $e");
    }
  }

  Future<bool> hasBackup() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
