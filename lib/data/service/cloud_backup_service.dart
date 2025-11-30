import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:path_provider/path_provider.dart';

class CloudBackupService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // نام فایلی که در ابرها ذخیره می‌شود
  String get _fileName => 'backup_v1.json.gz';

  /// 📤 آپلود بکاپ (فشرده شده)
  Future<void> uploadBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // ۱. خواندن تمام آیتم‌ها از دیتابیس
      final db = await DBHelper.instance.database;
      final List<Map<String, dynamic>> result = await db.query('items');
      final List<ItemModel> items = result
          .map((e) => ItemModel.fromDB(e))
          .toList();

      // ۲. تبدیل به JSON
      final String jsonString = jsonEncode(
        items.map((e) => e.toMap()).toList(),
      );

      // ۳. فشرده‌سازی (GZip) - کاهش حجم تا ۹۰٪
      final List<int> jsonBytes = utf8.encode(jsonString);
      final List<int> compressedBytes = GZipCodec().encode(jsonBytes);

      // ۴. ذخیره موقت فایل فشرده
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$_fileName');
      await tempFile.writeAsBytes(compressedBytes);

      // ۵. آپلود به مسیر اختصاصی کاربر: users/{uid}/backup.json.gz
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.putFile(tempFile);

      debugPrint(
        "✅ Backup uploaded successfully. Size: ${compressedBytes.length / 1024} KB",
      );
    } catch (e) {
      debugPrint("❌ Backup Error: $e");
      rethrow; // خطا را به UI بفرست تا اسنک‌بار نمایش دهد
    }
  }

  /// 📥 دانلود و بازگردانی بکاپ
  Future<void> restoreBackup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');

      // ۱. دانلود فایل (محدودیت ۱۰ مگابایت برای امنیت)
      final Uint8List? compressedBytes = await ref.getData(10 * 1024 * 1024);

      if (compressedBytes == null) {
        throw Exception("No backup found");
      }

      // ۲. استخراج فایل (Unzip)
      final List<int> jsonBytes = GZipCodec().decode(compressedBytes);
      final String jsonString = utf8.decode(jsonBytes);

      // ۳. تبدیل به لیست آیتم‌ها
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<ItemModel> items = decodedList
          .map((e) => ItemModel.fromDB(e))
          .toList();

      // ۴. جایگزینی در دیتابیس (خطرناک‌ترین بخش!)
      // استراتژی: دیتابیس فعلی را پاک کن و این‌ها را بریز
      // یا: فقط آیتم‌هایی که نیستند را اضافه کن (Merge).
      // اینجا روش Merge امن را پیاده می‌کنیم:

      final db = await DBHelper.instance.database;
      for (var item in items) {
        // چک کن اگر آیتم وجود ندارد، اضافه کن
        final exists = await db.query(
          'items',
          where: 'id = ?',
          whereArgs: [item.id],
        );

        if (exists.isEmpty) {
          await db.insert('items', item.toMap());
        }
      }

      debugPrint("✅ Restore complete. ${items.length} items processed.");
    } catch (e) {
      debugPrint("❌ Restore Error: $e");
      rethrow;
    }
  }

  /// چک کردن اینکه آیا کاربر بکاپ دارد یا نه (برای نمایش دکمه)
  Future<bool> hasBackup() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final ref = _storage.ref().child('users/${user.uid}/$_fileName');
      await ref.getMetadata(); // اگر فایل نباشد ارور می‌دهد
      return true;
    } catch (e) {
      return false;
    }
  }
}
