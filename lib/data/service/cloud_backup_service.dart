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

  // تغییر نام فایل به v3 برای پشتیبانی از ساختار جدید (ترجمه مثال‌ها)
  String get _fileName => 'backup_v3.json.gz';

  /// 📤 آپلود بکاپ کامل (شامل کلمات + ترجمه مثال‌ها + وضعیت جعبه‌ها)
  Future<void> uploadBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final db = await DBHelper.instance.database;

      // ۱. خواندن تمام آیتم‌ها (چون ساختار دیتابیس آپدیت شده، ستون‌های examplesEn و examplesFa هم خوانده می‌شوند)
      final List<Map<String, dynamic>> itemsResult = await db.query('items');

      // ۲. خواندن تمام داده‌های لایتنر
      final List<Map<String, dynamic>> leitnerResult = await db.query(
        'leitner',
      );

      // ۳. ساخت ساختار کلی بکاپ
      final Map<String, dynamic> backupData = {
        'version': 3, // نسخه ۳
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'items': itemsResult,
        'leitner': leitnerResult,
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
        "✅ Full Backup v3 uploaded successfully (Items: ${itemsResult.length})",
      );
    } catch (e) {
      debugPrint("❌ Backup Error: $e");
      rethrow;
    }
  }

  /// 📥 دانلود و بازگردانی بکاپ
  Future<void> restoreBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // ابتدا سعی می‌کنیم نسخه ۳ را بگیریم
      var ref = _storage.ref().child('users/${user.uid}/$_fileName');

      // چک کنیم اگر نسخه ۳ نبود، نسخه ۲ را امتحان کنیم (برای پشتیبانی از قبل)
      try {
        await ref.getMetadata();
      } catch (e) {
        // اگر v3 نبود، سراغ v2 می‌رویم
        ref = _storage.ref().child('users/${user.uid}/backup_v2.json.gz');
      }

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

      if (decoded is List) {
        // فرمت قدیمی v1
        items = decoded.map((e) => ItemModel.fromDB(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        // فرمت v2 و v3
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

      // ۴. بازگردانی به دیتابیس (Merge & Update)
      final db = await DBHelper.instance.database;

      await db.transaction((txn) async {
        // الف) بازگردانی آیتم‌ها
        for (var item in items) {
          final exists = await txn.query(
            'items',
            where: 'id = ?',
            whereArgs: [item.id],
          );

          if (exists.isEmpty) {
            // اگر آیتم نیست، اینسرت کن
            await txn.insert('items', item.toMap());
          } else {
            // [مهم] اگر آیتم هست، آپدیت کن!
            // این باعث می‌شود اگر فیلدهای جدید (ترجمه مثال‌ها) در بکاپ باشند ولی در گوشی نباشند، اضافه شوند.
            await txn.update(
              'items',
              item.toMap(),
              where: 'id = ?',
              whereArgs: [item.id],
            );
          }
        }

        // ب) بازگردانی آمار لایتنر
        for (var l in leitnerList) {
          final int itemId = l['itemId'];

          // ۱. مطمئن شویم آیتم مربوطه وجود دارد
          final itemExists = await txn.query(
            'items',
            where: 'id = ?',
            whereArgs: [itemId],
          );
          if (itemExists.isEmpty) continue;

          // ۲. اگر آمار وجود ندارد، اضافه کن (آمار موجود را دستکاری نمی‌کنیم تا پیشرفت جاری کاربر خراب نشود)
          final statsExist = await txn.query(
            'leitner',
            where: 'itemId = ?',
            whereArgs: [itemId],
          );

          if (statsExist.isEmpty) {
            final Map<String, dynamic> newStat = Map.from(l);
            newStat.remove('id'); // حذف ID برای جلوگیری از تداخل
            await txn.insert('leitner', newStat);
          }
        }
      });

      debugPrint("✅ Restore complete. Items processed: ${items.length}");
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
      // حذف هر دو نسخه احتمالی
      final refV3 = _storage.ref().child('users/${user.uid}/$_fileName');
      try {
        await refV3.delete();
      } catch (_) {}

      final refV2 = _storage.ref().child('users/${user.uid}/backup_v2.json.gz');
      try {
        await refV2.delete();
      } catch (_) {}

      debugPrint("✅ Cloud backup deleted.");
    } catch (e) {
      debugPrint("⚠️ Failed to delete cloud backup: $e");
    }
  }

  Future<bool> hasBackup() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      // چک کردن نسخه ۳
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.getMetadata();
      return true;
    } catch (e) {
      try {
        // چک کردن نسخه ۲
        final refOld = _storage.ref().child(
          'users/${user.uid}/backup_v2.json.gz',
        );
        await refOld.getMetadata();
        return true;
      } catch (e2) {
        return false;
      }
    }
  }
}
