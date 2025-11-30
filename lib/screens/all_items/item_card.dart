// ignore_for_file: deprecated_member_use, unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/l10n/app_localizations.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Localization & Theme Instances
    // Note: We don't need l10n strings here directly, but we need directionality context
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final defaultFont = isRtl ? 'IRANSans' : 'Poppins';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeIcon(theme),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// German text (Always LTR, Latin font)
                  Text(
                    item.german,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onBackground,
                      fontFamily: 'Poppins', // German always needs Latin font
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// First English translation
                  if (item.en.isNotEmpty)
                    Text(
                      item.en.first,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontFamily: 'Poppins', // English needs Latin font
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  /// First Persian translation
                  if (item.fa.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.fa.first,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.6,
                          ),
                          fontSize: 12,
                          fontFamily: "IRANSans", // Persian font
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection
                            .rtl, // Force RTL for Persian text block
                      ),
                    ),

                  const SizedBox(height: 8),

                  /// Level Badge & Article
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.level,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            fontFamily: 'Poppins', // Level (A1, B2...) is Latin
                          ),
                        ),
                      ),

                      if (item.article != null && item.article!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.article!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary,
                              fontFamily:
                                  'Poppins', // Articles (der, die...) are Latin
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    List<List<dynamic>> icon;
    final t = item.type;

    if (t.contains("word")) {
      icon = HugeIcons.strokeRoundedAlpha;
    } else if (t.contains("verbNounPhrase")) {
      icon = HugeIcons.strokeRoundedLayersLogo;
    } else if (t.contains("adverb")) {
      icon = HugeIcons.strokeRoundedFastWind;
    } else if (t.contains("verb")) {
      icon = HugeIcons.strokeRoundedSun01;
    } else if (t.contains("adjective")) {
      icon = HugeIcons.strokeRoundedSparkles;
    } else if (t.contains("idiom")) {
      icon = HugeIcons.strokeRoundedBulb;
    } else if (t.contains("sentence")) {
      icon = HugeIcons.strokeRoundedParagraph;
    } else if (t.contains("nounPhrase")) {
      icon = HugeIcons.strokeRoundedNote01;
    } else {
      icon = HugeIcons.strokeRoundedInformationCircle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: HugeIcon(
        icon: icon,
        size: 24,
        color: theme.colorScheme.onBackground.withOpacity(0.85),
      ),
    );
  }
}
