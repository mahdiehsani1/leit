// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/data/service/tts_service.dart';
import 'package:leit/l10n/app_localizations.dart';

class PracticeCard extends StatefulWidget {
  final ItemModel item;
  final bool isFront;

  const PracticeCard({super.key, required this.item, required this.isFront});

  @override
  State<PracticeCard> createState() => _PracticeCardState();
}

class _PracticeCardState extends State<PracticeCard> {
  // متغیر وضعیت برای سوییچ بین انگلیسی و فارسی در مثال‌ها
  bool _showPersianExample = false;

  @override
  Widget build(BuildContext context) {
    // Localization & Theme Instances
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, anim) {
        // 3D Rotation Animation
        final rotate = Tween(
          begin: pi,
          end: 0.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

        return AnimatedBuilder(
          animation: rotate,
          builder: (context, _) {
            final angle = rotate.value;
            // Determine side based on rotation angle (> 90 degrees)
            final isUnder = (angle > pi / 2);

            return Transform(
              transform: Matrix4.rotationY(angle),
              alignment: Alignment.center,
              child: isUnder ? const SizedBox() : child,
            );
          },
        );
      },
      // Switch between Front (Question) and Back (Answer)
      child: widget.isFront
          ? _front(context, theme: Theme.of(context), fontFamily: fontFamily)
          : _back(context, theme: Theme.of(context), fontFamily: fontFamily),
    );
  }

  // ---------------- FRONT (German) ------------------
  Widget _front(
    BuildContext context, {
    required ThemeData theme,
    required String fontFamily,
  }) {
    return _cardBase(
      context,
      keySuffix: "front",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedTranslate,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),

          const Spacer(),

          // German Text (Always Poppins/Latin)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.item.german,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'Poppins', // Force Latin font for German
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Article (if exists)
          if (widget.item.article != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.item.article!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'Poppins',
                ),
              ),
            ),

          const Spacer(),

          _ttsButton(context, text: widget.item.german, lang: "de-DE"),
        ],
      ),
    );
  }

  // ---------------- BACK (EN + FA + EXAMPLES) ------------------
  Widget _back(
    BuildContext context, {
    required ThemeData theme,
    required String fontFamily,
  }) {
    final item = widget.item;

    return _cardBase(
      context,
      keySuffix: "back",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // English Meaning
          if (item.en.isNotEmpty)
            Text(
              item.en.first,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
            ),

          const SizedBox(height: 12),

          // Persian Meaning (Always IRANSans + RTL)
          if (item.fa.isNotEmpty)
            Text(
              item.fa.first,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: "IRANSans",
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),

          // --- بخش مثال‌ها با قابلیت سوییچ ---
          if (item.examples.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.05),
                ),
              ),
              child: Column(
                children: [
                  // 1. جمله آلمانی (همیشه نمایش داده می‌شود)
                  Text(
                    item.examples.first,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  // بررسی وجود ترجمه برای نمایش خط جداکننده و دکمه سوییچ
                  if ((item.examplesEn.isNotEmpty &&
                          item.examplesEn.first.isNotEmpty) ||
                      (item.examplesFa.isNotEmpty &&
                          item.examplesFa.first.isNotEmpty)) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // دکمه سوییچ زبان
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showPersianExample = !_showPersianExample;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _showPersianExample ? "FA" : "EN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // متن ترجمه (تغییر با انیمیشن)
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _showPersianExample
                                  ? (item.examplesFa.isNotEmpty
                                        ? item.examplesFa.first
                                        : "---")
                                  : (item.examplesEn.isNotEmpty
                                        ? item.examplesEn.first
                                        : "---"),
                              key: ValueKey(_showPersianExample),
                              textAlign: TextAlign.center,
                              textDirection: _showPersianExample
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontFamily: _showPersianExample
                                    ? 'IRANSans'
                                    : 'Poppins',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          const Spacer(),

          // TTS Button (English)
          if (item.en.isNotEmpty)
            _ttsButton(context, text: item.en.first, lang: "en-US"),
        ],
      ),
    );
  }

  // ---------------- Base UI ------------------
  Widget _cardBase(
    BuildContext context, {
    required Widget child,
    required String keySuffix,
  }) {
    final theme = Theme.of(context);

    return Container(
      key: ValueKey("${widget.item.id}_$keySuffix"),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onBackground.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _ttsButton(
    BuildContext context, {
    required String text,
    required String lang,
  }) {
    final theme = Theme.of(context);
    return IconButton.filledTonal(
      onPressed: () {
        try {
          TTSService.speak(text, lang);
        } catch (e) {
          debugPrint("TTS Error: $e");
        }
      },
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.onBackground.withOpacity(0.05),
        foregroundColor: theme.colorScheme.onBackground,
        padding: const EdgeInsets.all(14),
      ),
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedVolumeHigh,
        size: 24,
        color: null,
      ),
    );
  }
}
