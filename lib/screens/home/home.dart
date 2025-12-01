// ignore_for_file: deprecated_member_use, unused_import

import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/data/service/auth_service.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/add_item/add_item.dart';
import 'package:leit/screens/all_items/all_items_screen.dart';
import 'package:leit/tabs.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool loading = true;

  List<ItemModel> _allItems = [];
  List<ItemModel> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _rawTopCategories = [];
  List<ItemModel> recentItems = [];

  // --- متغیرهای بنر مناسبتی (آپدیت شده برای ۳ رنگ) ---
  bool _showHolidayBanner = false;
  String _bannerLottieUrl = "";
  String _bannerTextDe = "";
  String _bannerTextEn = "";
  String _bannerTextFa = "";
  Color _bannerColorStart = Colors.blue;
  Color _bannerColorMiddle = Colors.transparent; // رنگ وسط (جدید)
  Color _bannerColorEnd = Colors.purple;
  // ---------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _setupRemoteConfig();
    _searchController.addListener(_onSearchChanged);
  }

  /// دریافت تنظیمات از فایربیس
  Future<void> _setupRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // در زمان توسعه interval را کم می‌گذاریم تا سریع تغییرات را ببینیم
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );

      await remoteConfig.fetchAndActivate();

      if (mounted) {
        setState(() {
          _showHolidayBanner = remoteConfig.getBool('holiday_is_active');

          if (_showHolidayBanner) {
            _bannerLottieUrl = remoteConfig.getString('holiday_lottie_url');
            _bannerTextDe = remoteConfig.getString('holiday_text_de');
            _bannerTextEn = remoteConfig.getString('holiday_text_en');
            _bannerTextFa = remoteConfig.getString('holiday_text_fa');

            // دریافت رنگ‌ها
            String color1 = remoteConfig.getString('holiday_color_start');
            String color2 = remoteConfig.getString(
              'holiday_color_middle',
            ); // پارامتر جدید
            String color3 = remoteConfig.getString('holiday_color_end');

            _bannerColorStart = _hexToColor(color1, defaultColor: Colors.blue);

            // اگر رنگ وسط خالی بود یا تعریف نشده بود، شفاف در نظر می‌گیریم تا نادیده گرفته شود
            if (color2.isNotEmpty && color2 != "null") {
              _bannerColorMiddle = _hexToColor(
                color2,
                defaultColor: Colors.transparent,
              );
            } else {
              _bannerColorMiddle = Colors.transparent;
            }

            _bannerColorEnd = _hexToColor(color3, defaultColor: Colors.purple);
          }
        });
      }
    } catch (e) {
      debugPrint("Remote Config Error: $e");
    }
  }

  Color _hexToColor(String hexString, {required Color defaultColor}) {
    try {
      if (hexString.isEmpty) return defaultColor;
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allItems.where((item) {
          final german = item.german.toLowerCase();
          final en = item.en.any((t) => t.toLowerCase().contains(query));
          final fa = item.fa.any((t) => t.contains(query));
          return german.contains(query) || en || fa;
        }).toList();
      }
    });
  }

  Future<void> _loadHomeData() async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> recentRows = await db.query(
      "items",
      orderBy: "createdAt DESC",
      limit: 6,
    );
    final List<Map<String, dynamic>> typeCounts = await db.rawQuery(
      'SELECT type, COUNT(*) as count FROM items GROUP BY type ORDER BY count DESC',
    );
    final List<Map<String, dynamic>> allRows = await db.query("items");

    recentItems = recentRows.map((e) => ItemModel.fromDB(e)).toList();
    _allItems = allRows.map((e) => ItemModel.fromDB(e)).toList();

    _rawTopCategories = typeCounts.take(3).map((e) {
      final type = e['type'] as String;
      final count = e['count'] as int;
      return {"type": type, "count": count, "icon": _mapTypeToIcon(type)};
    }).toList();

    if (mounted) setState(() => loading = false);
  }

  String _mapTypeToTitle(String t, AppLocalizations l10n) {
    if (t.contains("word")) return l10n.catWords;
    if (t.contains("verbNounPhrase")) return l10n.catVerbNoun;
    if (t.contains("adverb")) return l10n.catAdv;
    if (t.contains("verb")) return l10n.catVerbs;
    if (t.contains("adjective")) return l10n.catAdj;
    if (t.contains("sentence")) return l10n.catSentences;
    if (t.contains("idiom")) return l10n.catIdioms;
    return l10n.catUnknown;
  }

  List<List<dynamic>> _mapTypeToIcon(String t) {
    if (t.contains("word")) return HugeIcons.strokeRoundedAlpha;
    if (t.contains("verbNounPhrase")) return HugeIcons.strokeRoundedLayersLogo;
    if (t.contains("adverb")) return HugeIcons.strokeRoundedFastWind;
    if (t.contains("verb")) return HugeIcons.strokeRoundedSun01;
    if (t.contains("adjective")) return HugeIcons.strokeRoundedSparkles;
    if (t.contains("sentence")) return HugeIcons.strokeRoundedParagraph;
    if (t.contains("idiom")) return HugeIcons.strokeRoundedBulb;
    return HugeIcons.strokeRoundedLayers01;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';
    final isSearching = _searchController.text.isNotEmpty;

    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          ).then((_) => _loadHomeData());
        },
        backgroundColor: theme.colorScheme.onBackground,
        foregroundColor: theme.colorScheme.background,
        shape: const CircleBorder(),
        child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 26),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: theme.colorScheme.onBackground,
                    fontFamily: fontFamily,
                  ),
                ),
                StreamBuilder<User?>(
                  stream: _authService.authStateChanges,
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    if (user != null && user.photoURL != null) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: NetworkImage(user.photoURL!),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
            const SizedBox(height: 26),
            _searchBar(context, l10n, fontFamily),
            const SizedBox(height: 25),

            // --- نمایش بنر مناسبتی (۳ رنگ) ---
            if (_showHolidayBanner && !isSearching) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: _buildHolidayBanner(context),
              ),
              const SizedBox(height: 30),
            ] else if (!isSearching) ...[
              const SizedBox(height: 10),
            ],

            // --------------------------------
            if (isSearching) ...[
              Text(
                "${l10n.searchResults} (${_searchResults.length})",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              if (_searchResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedFileEmpty01,
                          size: 48,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.noResults,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.5,
                            ),
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._searchResults.map((item) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 200),
                    child: _recentItem(
                      context,
                      word: item.german,
                      translation: item.en.isNotEmpty ? item.en.first : "",
                      icon: _mapTypeToIcon(item.type),
                      fontFamily: fontFamily,
                    ),
                  );
                }),
            ] else ...[
              if (_rawTopCategories.isNotEmpty) ...[
                Text(
                  l10n.yourCategories,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                ..._rawTopCategories.map((cat) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: _categoryCard(
                      context,
                      title: _mapTypeToTitle(cat["type"], l10n),
                      count: cat["count"],
                      icon: cat["icon"],
                      fontFamily: fontFamily,
                      isRtl: isRtl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllItemsScreen(initialType: cat["type"]),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllItemsScreen(),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.viewAllCategories,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.65,
                            ),
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Transform.rotate(
                          angle: isRtl ? pi : 0,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.noItemsYet,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              _actionCard(
                context,
                icon: HugeIcons.strokeRoundedBookOpen01,
                title: l10n.continueLearning,
                subtitle: l10n.startLeitnerSession,
                fontFamily: fontFamily,
                isRtl: isRtl,
                onTap: () {
                  TabsScreen.globalKey.currentState?.changeTab(1);
                },
              ),
              const SizedBox(height: 18),
              _actionCard(
                context,
                icon: HugeIcons.strokeRoundedAddCircle,
                title: l10n.addNewItemAction,
                subtitle: l10n.addItemSubtitle,
                fontFamily: fontFamily,
                isRtl: isRtl,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  ).then((_) => _loadHomeData());
                },
              ),
              const SizedBox(height: 32),
              if (recentItems.isNotEmpty) ...[
                Text(
                  l10n.recentlyAdded,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 14),
                ...recentItems.map((item) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: _recentItem(
                      context,
                      word: item.german,
                      translation: item.en.isNotEmpty ? item.en.first : "",
                      icon: _mapTypeToIcon(item.type),
                      fontFamily: fontFamily,
                    ),
                  );
                }),
              ],
            ],
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // --- ویجت بنر با پشتیبانی از ۳ رنگ ---
  Widget _buildHolidayBanner(BuildContext context) {
    final theme = Theme.of(context);

    // منطق ساخت لیست رنگ‌ها:
    // اگر رنگ وسط تعریف نشده باشد، فقط شروع و پایان را استفاده می‌کند.
    List<Color> gradientColors;
    if (_bannerColorMiddle == Colors.transparent) {
      gradientColors = [
        _bannerColorStart.withOpacity(0.25),
        _bannerColorEnd.withOpacity(0.25),
      ];
    } else {
      gradientColors = [
        _bannerColorStart.withOpacity(0.25),
        _bannerColorMiddle.withOpacity(0.25),
        _bannerColorEnd.withOpacity(0.25),
      ];
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // دایره تزئینی پس‌زمینه
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _bannerColorEnd.withOpacity(0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: _bannerLottieUrl.isNotEmpty
                        ? Lottie.network(
                            _bannerLottieUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.celebration,
                                  size: 40,
                                  color: Colors.amber,
                                ),
                          )
                        : const Icon(Icons.celebration, size: 40),
                  ),

                  const SizedBox(width: 16),

                  // متون
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_bannerTextDe.isNotEmpty)
                          Text(
                            _bannerTextDe,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                              fontFamily: 'Poppins',
                            ),
                          ),

                        const SizedBox(height: 6),

                        if (_bannerTextEn.isNotEmpty)
                          Text(
                            _bannerTextEn,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.8,
                              ),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),

                        const SizedBox(height: 4),

                        if (_bannerTextFa.isNotEmpty)
                          Text(
                            _bannerTextFa,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.7,
                              ),
                              fontFamily: 'IRANSans',
                              fontSize: 12,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... سایر ویجت‌ها مثل _searchBar و _categoryCard بدون تغییر هستند ...
  Widget _searchBar(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            size: 20,
            color: Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                  fontFamily: fontFamily,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedClean,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
    BuildContext context, {
    required String title,
    required int count,
    required List<List<dynamic>> icon,
    required VoidCallback onTap,
    required String fontFamily,
    required bool isRtl,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HugeIcon(
                  icon: icon,
                  size: 28,
                  color: theme.colorScheme.onBackground.withOpacity(0.85),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onBackground,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$count items",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: isRtl ? pi : 0,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 20,
                  color: theme.colorScheme.onBackground.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String fontFamily,
    required bool isRtl,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: HugeIcon(
                icon: icon,
                size: 28,
                color: theme.colorScheme.onBackground.withOpacity(0.85),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onBackground,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Transform.rotate(
              angle: isRtl ? pi : 0,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 20,
                color: theme.colorScheme.onBackground.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentItem(
    BuildContext context, {
    required String word,
    required String translation,
    required List<List<dynamic>> icon,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onBackground.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 22,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
