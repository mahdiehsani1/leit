// ignore_for_file: deprecated_member_use, unused_import

import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Stores raw DB data, titles are resolved in build()
  List<Map<String, dynamic>> _rawTopCategories = [];
  List<ItemModel> recentItems = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _searchController.addListener(_onSearchChanged);
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

    // 1. Get last 6 items
    final List<Map<String, dynamic>> recentRows = await db.query(
      "items",
      orderBy: "createdAt DESC",
      limit: 6,
    );

    // 2. Get category counts
    final List<Map<String, dynamic>> typeCounts = await db.rawQuery(
      'SELECT type, COUNT(*) as count FROM items GROUP BY type ORDER BY count DESC',
    );

    // 3. Get all items for search
    final List<Map<String, dynamic>> allRows = await db.query("items");

    // Convert data
    recentItems = recentRows.map((e) => ItemModel.fromDB(e)).toList();
    _allItems = allRows.map((e) => ItemModel.fromDB(e)).toList();

    // Store raw category data
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

    // Localization & Theme Instances
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

            /// HEADER
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

            const SizedBox(height: 30),

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
                        Icon(
                          Icons.search_off_rounded,
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
                  // Index 1 is Practice
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
                        icon: const Icon(Icons.close),
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
                    fontFamily: 'Poppins', // Keep Latin font for German words
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontFamily: fontFamily, // Dynamic font for translation
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
