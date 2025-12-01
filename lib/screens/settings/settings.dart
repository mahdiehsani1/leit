// ignore_for_file: use_build_context_synchronously, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/service/auth_service.dart';
import 'package:leit/data/service/cloud_backup_service.dart'; // سرویس جدید ابری
import 'package:leit/data/service/notification_service.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  bool _isReminderEnabled = false;
  int _reminderHour = 10;
  int _reminderMinute = 0;
  String _currentLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _authService.init();
  }

  Future<void> _loadSettings() async {
    final pref = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isReminderEnabled = pref.getBool("notif_enabled") ?? false;
        _reminderHour = pref.getInt("notif_hour") ?? 10;
        _reminderMinute = pref.getInt("notif_minute") ?? 0;
        _currentLanguageCode = pref.getString('language_code') ?? 'en';
      });
    }
  }

  // --- Language Methods ---
  String _getLanguageName(String code) {
    switch (code) {
      case 'de':
        return "Deutsch";
      case 'en':
      default:
        return "English";
    }
  }

  Future<void> _changeLanguage(String code) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('language_code', code);
    setState(() => _currentLanguageCode = code);

    if (!mounted) return;
    const fontFamily = 'Poppins';
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);
    _showSnack(l10n.msgLanguageChanged(_getLanguageName(code)), fontFamily);
  }

  void _showLanguageBottomSheet(String fontFamily) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguageDialog,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 20),
              _languageTile(
                title: "English",
                subtitle: "Default",
                code: "en",
                icon: HugeIcons.strokeRoundedLanguageCircle,
                fontFamily: fontFamily,
              ),
              _languageTile(
                title: "Deutsch",
                subtitle: "German",
                code: "de",
                icon: HugeIcons.strokeRoundedLanguageCircle,
                fontFamily: fontFamily,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile({
    required String title,
    required String subtitle,
    required String code,
    required List<List<dynamic>> icon,
    required String fontFamily,
  }) {
    final isSelected = _currentLanguageCode == code;
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.onBackground.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: HugeIcon(
          icon: icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onBackground,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onBackground,
          fontFamily: fontFamily,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: fontFamily)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () => _changeLanguage(code),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // --- Notification Methods ---
  String _formatTimeOfDay(TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  Future<void> _pickReminderTime(
    AppLocalizations l10n,
    String fontFamily,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.scaffoldBackgroundColor,
              dialHandColor: theme.colorScheme.primary,
              dialTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onBackground,
              ),
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : theme.colorScheme.onBackground.withOpacity(0.05),
              ),
              hourMinuteTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onBackground,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final pref = await SharedPreferences.getInstance();
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      await pref.setInt("notif_hour", picked.hour);
      await pref.setInt("notif_minute", picked.minute);

      if (_isReminderEnabled) {
        await NotificationService().cancelAll();
        _scheduleNotification(l10n, fontFamily);
      }
    }
  }

  Future<void> _toggleNotification(
    bool value,
    AppLocalizations l10n,
    String fontFamily,
  ) async {
    final pref = await SharedPreferences.getInstance();
    if (value) {
      bool granted = await NotificationService().requestPermissions();
      if (granted) {
        _scheduleNotification(l10n, fontFamily);
        setState(() => _isReminderEnabled = true);
        await pref.setBool("notif_enabled", true);
      } else {
        setState(() => _isReminderEnabled = false);
        await pref.setBool("notif_enabled", false);
        if (mounted)
          _showSnack(l10n.msgPermissionDenied, fontFamily, isError: true);
      }
    } else {
      await NotificationService().cancelAll();
      setState(() => _isReminderEnabled = false);
      await pref.setBool("notif_enabled", false);
    }
  }

  Future<void> _scheduleNotification(
    AppLocalizations l10n,
    String fontFamily,
  ) async {
    try {
      await NotificationService().scheduleDailyNotification(
        id: 0,
        title: l10n.dailyReminderTitle,
        body: l10n.continueLearning,
        hour: _reminderHour,
        minute: _reminderMinute,
      );
      if (mounted) {
        final timeStr = _formatTimeOfDay(
          TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
        );
        _showSnack(
          "${l10n.msgReminderSet.replaceAll("10:00 AM", "")} $timeStr",
          fontFamily,
        );
      }
    } catch (e) {
      setState(() => _isReminderEnabled = false);
      if (mounted) _showSnack("Error: $e", fontFamily, isError: true);
    }
  }

  // --- Cloud Data Methods (Updated) --- ☁️

  Future<void> _handleBackup(AppLocalizations l10n, String fontFamily) async {
    // بررسی لاگین بودن کاربر
    if (FirebaseAuth.instance.currentUser == null) {
      _showSnack(l10n.msgSignInRequired, fontFamily, isError: true);
      return;
    }

    _showLoadingDialog();
    try {
      // استفاده از سرویس بکاپ ابری جدید
      await CloudBackupService().uploadBackup();

      if (!mounted) return;
      Navigator.pop(context); // بستن لودینگ
      _showSnack(l10n.msgBackupSuccess, fontFamily);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(l10n.msgBackupFailed(e.toString()), fontFamily, isError: true);
    }
  }

  Future<void> _handleRestore(AppLocalizations l10n, String fontFamily) async {
    if (FirebaseAuth.instance.currentUser == null) {
      _showSnack(l10n.msgSignInRequired, fontFamily, isError: true);
      return;
    }

    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.restoreDialogTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            content: Text(
              l10n.restoreDialogMsg,
              style: TextStyle(height: 1.4, fontFamily: fontFamily),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.btnCancel,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.6),
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.btnRestore,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    _showLoadingDialog();
    try {
      // استفاده از سرویس رستور ابری جدید
      await CloudBackupService().restoreBackup();

      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(l10n.msgDataRestored, fontFamily);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(
        l10n.msgRestoreFailed(e.toString()),
        fontFamily,
        isError: true,
      );
    }
  }

  Future<void> _handleClearData(
    AppLocalizations l10n,
    String fontFamily,
  ) async {
    // Variable for checkbox state inside dialog
    bool deleteCloud = false;
    final user = FirebaseAuth.instance.currentUser;
    final canDeleteCloud = user != null;

    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    l10n.clearDialogTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.clearDialogMsg,
                        style: TextStyle(height: 1.4, fontFamily: fontFamily),
                      ),
                      if (canDeleteCloud) ...[
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: deleteCloud,
                          onChanged: (val) {
                            setState(() => deleteCloud = val ?? false);
                          },
                          title: Text(
                            l10n.clearDialogOptionCloud,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 14,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.redAccent,
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        l10n.btnCancel,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.6),
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        l10n.btnDeleteEverything,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    if (!confirm) return;

    _showLoadingDialog();
    try {
      // 1. Delete Local Data
      await DBHelper.instance.clearAllData();

      // 2. Delete Cloud Data (if selected)
      if (deleteCloud && canDeleteCloud) {
        await CloudBackupService().deleteBackup();
      }

      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(l10n.msgDataDeleted, fontFamily, isError: true);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack("Error: $e", fontFamily, isError: true);
    }
  }

  // --- Extra Methods ---
  Future<void> _openStore() async {
    const packageName = "com.mahdi.leit";
    final Uri url = Uri.parse("market://details?id=$packageName");
    final Uri webUrl = Uri.parse(
      "https://play.google.com/store/apps/details?id=$packageName",
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching store: $e");
    }
  }

  Future<void> _showAboutDialog(String fontFamily) async {
    // اضافه کردن این خط برای دسترسی به ترجمه‌ها
    final l10n = AppLocalizations.of(context)!;

    try {
      final String langSuffix = _currentLanguageCode == 'de' ? 'de' : 'en';
      final String assetPath = 'assets/text/about_$langSuffix.txt';
      String content = await rootBundle.loadString(assetPath);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          final theme = Theme.of(context);
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onBackground.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      l10n.aboutApp, // حالا این متغیر شناخته می‌شود
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onBackground.withOpacity(0.1),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontFamily: fontFamily,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      _showSnack("Error loading about file: $e", fontFamily, isError: true);
    }
  }

  // --- Helper UI Methods ---
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  void _showSnack(String message, String fontFamily, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: fontFamily)),
        backgroundColor: isError
            ? Colors.redAccent.shade200
            : Theme.of(context).colorScheme.onBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;
    const fontFamily = 'Poppins';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.tabSettings,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: user != null
                      ? _buildUserProfileCard(theme, user, fontFamily)
                      : _buildSignInCard(theme, l10n, fontFamily),
                ),
                const SizedBox(height: 30),

                // --- General Section ---
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, l10n.sectionGeneral, fontFamily),
                      _settingsGroup(context, [
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedGlobe02,
                          title: l10n.langTitle,
                          trailing: _getLanguageName(_currentLanguageCode),
                          fontFamily: fontFamily,
                          onTap: () => _showLanguageBottomSheet(fontFamily),
                        ),
                        _divider(theme),
                        _switchItem(
                          context,
                          icon: isDarkMode
                              ? HugeIcons.strokeRoundedMoon02
                              : HugeIcons.strokeRoundedSun02,
                          title: l10n.darkModeTitle,
                          value: isDarkMode,
                          fontFamily: fontFamily,
                          onChanged: (val) =>
                              themeController.setTheme(val ? "dark" : "light"),
                        ),
                        _divider(theme),
                        _switchItem(
                          context,
                          icon: HugeIcons.strokeRoundedNotification01,
                          title: l10n.dailyReminderTitle,
                          subtitle: _formatTimeOfDay(
                            TimeOfDay(
                              hour: _reminderHour,
                              minute: _reminderMinute,
                            ),
                          ),
                          value: _isReminderEnabled,
                          fontFamily: fontFamily,
                          onChanged: (val) =>
                              _toggleNotification(val, l10n, fontFamily),
                          onTap: () => _pickReminderTime(l10n, fontFamily),
                        ),
                      ]),
                    ],
                  ),
                ),

                // --- Cloud & Sync Section ---
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, l10n.sectionDataSync, fontFamily),
                      _settingsGroup(context, [
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedCloudUpload,
                          title: l10n.backupToCloud,
                          fontFamily: fontFamily,
                          onTap: () => _handleBackup(l10n, fontFamily),
                        ),
                        _divider(theme),
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedCloudDownload,
                          title: l10n.restoreFromCloud,
                          fontFamily: fontFamily,
                          onTap: () => _handleRestore(l10n, fontFamily),
                        ),
                        _divider(theme),
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedDelete02,
                          title: l10n.clearAllData,
                          isDestructive: true,
                          fontFamily: fontFamily,
                          onTap: () => _handleClearData(l10n, fontFamily),
                        ),
                      ]),
                    ],
                  ),
                ),

                // --- About Section ---
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, l10n.sectionAbout, fontFamily),
                      _settingsGroup(context, [
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedStar,
                          title: l10n.rateOnGooglePlay, // Changed
                          fontFamily: fontFamily,
                          onTap: _openStore,
                        ),
                        _divider(theme),
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedInformationSquare,
                          title: l10n.aboutApp, // Changed
                          fontFamily: fontFamily,
                          onTap: () => _showAboutDialog(fontFamily),
                        ),
                        _divider(theme),
                        _actionItem(
                          context,
                          icon: HugeIcons.strokeRoundedCpu,
                          title: l10n.version,
                          trailing: "1.0.0",
                          fontFamily: fontFamily,
                          onTap: () {},
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                if (user != null)
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _authService.signOut();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: theme.colorScheme.error.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: Text(
                          l10n.signOut,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.05,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${l10n.developedWith} ",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.6,
                              ),
                              fontFamily: fontFamily,
                            ),
                          ),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedFavourite,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          Text(
                            " ${l10n.byAuthor} ",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.6,
                              ),
                              fontFamily: fontFamily,
                            ),
                          ),
                          Text(
                            "Mahdi Ehsani",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.9,
                              ),
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Common Widgets ---
  Widget _sectionTitle(BuildContext context, String text, String fontFamily) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  Widget _settingsGroup(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: theme.colorScheme.onBackground.withOpacity(0.05),
    );
  }

  Widget _buildUserProfileCard(ThemeData theme, User user, String fontFamily) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.background,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    color: theme.colorScheme.onBackground,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? "User",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  user.email ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard(
    ThemeData theme,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    return InkWell(
      onTap: () => _authService.signIn(),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedGoogle,
              color: theme.colorScheme.background,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.signInSync,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.background,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    String? trailing,
    bool isDestructive = false,
    required String fontFamily,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onBackground;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: HugeIcon(icon: icon, size: 22, color: color.withOpacity(0.8)),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: fontFamily,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.4),
                fontFamily: fontFamily,
              ),
            )
          : HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
              color: theme.colorScheme.onBackground.withOpacity(0.2),
            ),
    );
  }

  Widget _switchItem(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    String? subtitle,
    required bool value,
    required String fontFamily,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: HugeIcon(
          icon: icon,
          size: 22,
          color: theme.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onBackground,
          fontFamily: fontFamily,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
                fontSize: 12,
                fontFamily: fontFamily,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.background,
        activeTrackColor: theme.colorScheme.onBackground,
        inactiveThumbColor: theme.colorScheme.onBackground.withOpacity(0.5),
        inactiveTrackColor: theme.colorScheme.onBackground.withOpacity(0.1),
      ),
    );
  }
}
