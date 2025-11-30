// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'items_tab_view.dart';

class AllItemsScreen extends StatelessWidget {
  // Optional parameter to set initial tab
  final String? initialType;
  const AllItemsScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    final tabs = [
      (label: l10n.catWords, type: "ContentType.word"),
      (label: l10n.catVerbs, type: "ContentType.verb"),
      (label: l10n.catAdj, type: "ContentType.adjective"),
      (label: l10n.catAdv, type: "ContentType.adverb"),
      (label: l10n.catVerbNoun, type: "ContentType.verbNounPhrase"),
      (label: l10n.catIdioms, type: "ContentType.idiom"),
      (label: l10n.catSentences, type: "ContentType.sentence"),
    ];

    // Find index of the initial tab
    int initialIndex = 0;
    if (initialType != null) {
      initialIndex = tabs.indexWhere((t) => t.type == initialType);
      if (initialIndex == -1) initialIndex = 0; // Default to first if not found
    }

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            l10n.allItemsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
              fontFamily: fontFamily,
            ),
          ),
          leading: IconButton(
            icon: Transform.rotate(
              angle: isRtl ? pi : 0,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 22,
                color: theme.colorScheme.onBackground,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              width: double.infinity,
              alignment:
                  AlignmentDirectional.centerStart, // RTL-aware alignment
              child: TabBar(
                isScrollable: true,
                // Align tabs to start (left in LTR, right in RTL)
                tabAlignment: TabAlignment.start,
                // Remove default divider line
                dividerColor: Colors.transparent,

                labelColor: theme.colorScheme.background,
                unselectedLabelColor: theme.colorScheme.onBackground,

                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: fontFamily,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: fontFamily,
                ),

                overlayColor: MaterialStateProperty.all(Colors.transparent),

                // Zero out padding to control it manually via child
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),

                indicator: RectangularIndicator(
                  color: theme.colorScheme.onBackground,
                  bottomLeftRadius: 100,
                  bottomRightRadius: 100,
                  topLeftRadius: 100,
                  topRightRadius: 100,
                  paintingStyle: PaintingStyle.fill,
                  horizontalPadding: 6,
                  verticalPadding: 6,
                ),

                tabs: tabs
                    .map(
                      (t) => Tab(
                        child: Padding(
                          // Internal padding for pill shape text
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(t.label),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: tabs.map((t) => ItemsTabView(type: t.type)).toList(),
        ),
      ),
    );
  }
}
