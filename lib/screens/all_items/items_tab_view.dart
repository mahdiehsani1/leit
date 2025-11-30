// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_to_list_in_spreads, unused_import

import 'dart:convert';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/add_item/add_item.dart';
import 'item_card.dart';

class ItemsTabView extends StatefulWidget {
  final String type;
  const ItemsTabView({super.key, required this.type});

  @override
  State<ItemsTabView> createState() => _ItemsTabViewState();
}

class _ItemsTabViewState extends State<ItemsTabView> {
  List<ItemModel> allItems = [];
  List<ItemModel> filteredItems = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (allItems.isEmpty && mounted) setState(() => loading = true);

    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> data = await db.query(
      "items",
      where: "type = ?",
      whereArgs: [widget.type],
      orderBy: "createdAt DESC",
    );

    if (!mounted) return;

    allItems = data.map((e) {
      return ItemModel(
        id: e['id'] as int?,
        type: e['type'] as String,
        german: e['german'] as String,
        en: _decodeList(e['en']),
        fa: _decodeList(e['fa']),
        examples: _decodeList(e['examples']),
        article: e['article'] as String?,
        plural: e['plural'] as String?,
        prateritum: e['prateritum'] as String?,
        perfekt: e['perfekt'] as String?,
        partizip: e['partizip'] as String?,
        synonyms: _decodeListOrNull(e['synonyms']),
        antonyms: _decodeListOrNull(e['antonyms']),
        explanation: e['explanation'] as String?,
        level: e['level'] as String,
        tags: e['tags'] as String?,
        notes: e['notes'] as String?,
        createdAt: e['createdAt'] as int,
      );
    }).toList();

    filteredItems = List.from(allItems);
    if (_searchController.text.isNotEmpty) {
      _applySearch();
    }

    if (mounted) setState(() => loading = false);
  }

  // --- Delete and Manage Logic ---

  Future<void> _deleteItem(ItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    final db = await DBHelper.instance.database;
    await db.delete("items", where: "id = ?", whereArgs: [item.id]);
    _loadItems(); // Refresh list
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.msgItemDeleted,
          style: TextStyle(fontFamily: fontFamily),
        ),
      ),
    );
  }

  /// Main Option Menu (Three dots)
  void _showOptions(BuildContext context, ItemModel item) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                item.german,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                  fontFamily: 'Poppins', // Keep German title in Latin font
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // View Details Button
              _buildOptionButton(
                context,
                icon: HugeIcons.strokeRoundedView,
                label: l10n.optionViewDetails,
                color: theme.colorScheme.primary,
                fontFamily: fontFamily,
                isRtl: isRtl,
                onTap: () {
                  Navigator.pop(context);
                  _showDetailsBottomSheet(context, item);
                },
              ),

              const SizedBox(height: 12),

              // Edit Button
              _buildOptionButton(
                context,
                icon: HugeIcons.strokeRoundedEdit02,
                label: l10n.optionEditItem,
                color: theme.colorScheme.primary,
                fontFamily: fontFamily,
                isRtl: isRtl,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddItemScreen(itemToEdit: item),
                    ),
                  ).then((_) => _loadItems());
                },
              ),

              const SizedBox(height: 12),

              // Delete Button
              _buildOptionButton(
                context,
                icon: HugeIcons.strokeRoundedDelete02,
                label: l10n.optionDeleteItem,
                color: theme.colorScheme.primary,
                fontFamily: fontFamily,
                isRtl: isRtl,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, item);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Details Bottom Sheet
  void _showDetailsBottomSheet(BuildContext context, ItemModel item) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 10),

                /// Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onBackground.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                /// Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.detailsTitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.4,
                          ),
                          fontFamily: fontFamily,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    children: [
                      /// MAIN TITLE
                      Center(
                        child: Column(
                          children: [
                            Text(
                              item.german,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onBackground,
                                fontFamily: 'Poppins', // German title
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.07),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "${l10n.labelLevel} ${item.level}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// EN + FA
                      _sectionTile(
                        context,
                        icon: HugeIcons.strokeRoundedTranslate,
                        title: l10n.sectionTranslations,
                        fontFamily: fontFamily,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.en.isNotEmpty) ...[
                              _label(context, l10n.labelEnglish, fontFamily),
                              ...item.en.map(
                                (t) => _bullet(context, t, isPersian: false),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (item.fa.isNotEmpty) ...[
                              _label(context, l10n.labelPersian, fontFamily),
                              ...item.fa.map(
                                (t) => _bullet(context, t, isPersian: true),
                              ),
                            ],
                          ],
                        ),
                      ),

                      /// GRAMMAR
                      if (_hasGrammar(item))
                        _sectionTile(
                          context,
                          icon: HugeIcons.strokeRoundedBookOpen01,
                          title: l10n.sectionGrammar,
                          fontFamily: fontFamily,
                          child: Column(
                            children: [
                              if (item.article != null)
                                _infoRow(
                                  context,
                                  l10n.labelArticle,
                                  item.article!,
                                  fontFamily,
                                ),
                              if (item.plural != null &&
                                  item.plural!.trim().isNotEmpty)
                                _infoRow(
                                  context,
                                  l10n.labelPlural,
                                  item.plural!,
                                  fontFamily,
                                ),
                              if (item.prateritum != null)
                                _infoRow(
                                  context,
                                  l10n.labelPrateritum,
                                  item.prateritum!,
                                  fontFamily,
                                ),
                              if (item.perfekt != null)
                                _infoRow(
                                  context,
                                  l10n.labelPerfekt,
                                  item.perfekt!,
                                  fontFamily,
                                ),
                              if (item.partizip != null)
                                _infoRow(
                                  context,
                                  l10n.labelPartizip,
                                  item.partizip!,
                                  fontFamily,
                                ),
                            ],
                          ),
                        ),

                      /// EXAMPLES
                      if (item.examples.isNotEmpty)
                        _sectionTile(
                          context,
                          icon: HugeIcons.strokeRoundedQuoteUpSquare,
                          title: l10n.sectionExamples,
                          fontFamily: fontFamily,
                          child: Column(
                            children: item.examples
                                .map(
                                  (t) => Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      t,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontFamily:
                                                'Poppins', // Examples are German
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      /// EXPLANATION
                      if (item.explanation != null &&
                          item.explanation!.trim().isNotEmpty)
                        _sectionTile(
                          context,
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          title: l10n.sectionExplanation,
                          fontFamily: fontFamily,
                          child: Text(
                            item.explanation!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),

                      /// SYNONYMS & ANTONYMS
                      if ((item.synonyms != null &&
                              item.synonyms!.isNotEmpty) ||
                          (item.antonyms != null && item.antonyms!.isNotEmpty))
                        _sectionTile(
                          context,
                          icon: HugeIcons.strokeRoundedLink01,
                          title: l10n.sectionSynAnt,
                          fontFamily: fontFamily,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.synonyms != null &&
                                  item.synonyms!.isNotEmpty) ...[
                                _label(context, l10n.labelSynonyms, fontFamily),
                                Wrap(
                                  spacing: 6,
                                  children: item.synonyms!.map((s) {
                                    return _tag(context, s, 'Poppins');
                                  }).toList(),
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (item.antonyms != null &&
                                  item.antonyms!.isNotEmpty) ...[
                                _label(context, l10n.labelAntonyms, fontFamily),
                                Wrap(
                                  spacing: 6,
                                  children: item.antonyms!.map((s) {
                                    return _tag(context, s, 'Poppins');
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                      /// NOTES + TAGS
                      if ((item.tags != null && item.tags!.isNotEmpty) ||
                          (item.notes != null && item.notes!.isNotEmpty))
                        _sectionTile(
                          context,
                          icon: HugeIcons.strokeRoundedNote01,
                          title: l10n.sectionExtra,
                          fontFamily: fontFamily,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.tags != null &&
                                  item.tags!.trim().isNotEmpty)
                                _infoRow(
                                  context,
                                  l10n.labelTags,
                                  item.tags!,
                                  fontFamily,
                                ),
                              if (item.notes != null &&
                                  item.notes!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    bottom: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _label(
                                        context,
                                        l10n.labelNotes,
                                        fontFamily,
                                      ),
                                      Text(
                                        item.notes!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.7),
                                              fontFamily: fontFamily,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _sectionTile(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required Widget child,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: icon,
                size: 20,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onBackground,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text, String fontFamily) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.45),
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text, {bool isPersian = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: CircleAvatar(
              radius: 2,
              backgroundColor: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.3,
                fontFamily: isPersian ? "IRANSans" : "Poppins",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign
                  .end, // Align value to end (left in RTL, right in LTR)
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text, String fontFamily) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(fontFamily: fontFamily),
      ),
    );
  }

  bool _hasGrammar(ItemModel i) {
    return (i.article != null && i.article!.isNotEmpty) ||
        (i.plural != null && i.plural!.isNotEmpty) ||
        (i.prateritum != null && i.prateritum!.isNotEmpty) ||
        (i.perfekt != null && i.perfekt!.isNotEmpty) ||
        (i.partizip != null && i.partizip!.isNotEmpty);
  }

  void _showDeleteConfirmation(BuildContext context, ItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteItemDialogTitle,
          style: TextStyle(fontFamily: fontFamily),
        ),
        content: Text(
          l10n.deleteItemDialogMsg(item.german),
          style: TextStyle(fontFamily: fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.btnCancel,
              style: TextStyle(fontFamily: fontFamily),
            ),
          ),
          TextButton(
            onPressed: () => _deleteItem(item),
            child: Text(
              l10n.btnDelete,
              style: TextStyle(color: Colors.red, fontFamily: fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required String fontFamily,
    required bool isRtl,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 24, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
            ),
            const Spacer(),
            Transform.rotate(
              angle: isRtl ? 3.14159 : 0,
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

  // --- Utility Functions ---

  List<String> _decodeList(dynamic value) {
    if (value == null) return [];
    try {
      return List<String>.from(jsonDecode(value));
    } catch (e) {
      return [];
    }
  }

  List<String>? _decodeListOrNull(dynamic value) {
    if (value == null) return null;
    try {
      final list = List<String>.from(jsonDecode(value));
      return list.isEmpty ? null : list;
    } catch (e) {
      return null;
    }
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => filteredItems = List.from(allItems));
      return;
    }
    setState(() {
      filteredItems = allItems.where((item) {
        final germanMatch = item.german.toLowerCase().contains(q);
        final enMatch = item.en.any((t) => t.toLowerCase().contains(q));
        final faMatch = item.fa.any((t) => t.contains(q));
        return germanMatch || enMatch || faMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.onBackground.withOpacity(0.7),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(width: 4),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  size: 20,
                  color: Colors.grey,
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontFamily: fontFamily,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      filled: false,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                        fontFamily: fontFamily,
                      ),
                      fillColor: theme.colorScheme.onBackground.withOpacity(
                        0.05,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
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
          ),
        ),

        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmptyState(context, l10n, fontFamily)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, i) {
                    final item = filteredItems[i];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      key: ValueKey(item.id),
                      child: ItemCard(
                        item: item,
                        onTap: () => _showOptions(context, item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedInbox,
            size: 70,
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noItemsFound,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
