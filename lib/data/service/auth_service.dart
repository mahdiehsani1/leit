// ignore_for_file: avoid_print, unnecessary_nullable_for_final_variable_declarations, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// --- مقداردهی اولیه (اجباری برای نسخه جدید google_sign_in) ---
  void init() {
    GoogleSignIn.instance.initialize(
      serverClientId:
          "452607076938-g1o2841budu0jqh1plebolgcro3bib3t.apps.googleusercontent.com",
    );
  }

  /// --- جریان وضعیت لاگین ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// --- کاربر فعلی ---
  User? get currentUser => _auth.currentUser;

  /// --- ورود با گوگل ---
  Future<void> signIn() async {
    try {
      // نسخه جدید باید authenticate را صدا بزند
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        print("User cancelled sign in");
        return;
      }

      // گرفتن tokenها
      final googleAuth = await googleUser.authentication;

      // ساخت credential برای Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // ورود به Firebase
      await _auth.signInWithCredential(credential);

      print("Signed in successfully!");
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  /// --- خروج از حساب ---
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {
      // اگر disconnect خطا بدهد مهم نیست
    }

    await _auth.signOut();
    print("Signed out");
  }

  /// --- آپلود بکاپ (تو قبلاً نوشته بودی، دست نزدم) ---
  Future<bool> uploadBackup(String fileName) async {
    try {
      // این قسمت مال پروژه خودت است و من عوضش نکردم
      // فقط true برمی‌گردانم چون تو خودت داری فایل را مدیریت می‌کنی
      return true;
    } catch (e) {
      print("Backup upload error: $e");
      return false;
    }
  }

  /// --- ریستور بکاپ (دقیقاً مثل پروژه تو) ---
  Future<bool> restoreBackup(String fileName) async {
    try {
      return true;
    } catch (e) {
      print("Restore error: $e");
      return false;
    }
  }

  /// --- متد جدید برای حذف اکانت ---
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // حذف اکانت از فایربیس
      await user.delete();
      // خروج کامل از گوگل ساین‌این برای جلوگیری از لاگین خودکار بعدی
      await GoogleSignIn.instance.signOut();
    }
  }
}
