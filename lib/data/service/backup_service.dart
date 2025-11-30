// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  /// گرفتن خروجی از دیتابیس (Backup)
  static Future<bool> exportDatabase() async {
    try {
      final dbPath = await DBHelper.instance.getDbPath();
      final file = File(dbPath);

      if (!await file.exists()) {
        return false;
      }

      await Share.shareXFiles(
        [XFile(dbPath)],
        subject: 'Leit Backup',
        text: 'Here is my Leit backup file.',
      );

      return true;
    } catch (e) {
      print("Export Error: $e");
      return false;
    }
  }

  /// بازگردانی دیتابیس (Restore)
  static Future<bool> importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final selectedPath = result.files.single.path!;
        final selectedFile = File(selectedPath);

        if (await selectedFile.length() == 0) return false;

        // مهم: بستن کانکشن دیتابیس قبل از کپی کردن فایل جدید
        await DBHelper.instance.close();

        final dbPath = await DBHelper.instance.getDbPath();

        // کپی کردن فایل
        await selectedFile.copy(dbPath);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Import Error: $e");
      return false;
    }
  }
}
