// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/l10n/app_localizations.dart';

class PracticeActionButtons extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback onHard;
  final VoidCallback onEasy;

  const PracticeActionButtons({
    super.key,
    required this.onAgain,
    required this.onHard,
    required this.onEasy,
  });

  @override
  Widget build(BuildContext context) {
    // Localization & Theme Instances
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            label: l10n.btnAgain,
            icon: HugeIcons.strokeRoundedRefresh,
            onTap: onAgain,
            fontFamily: fontFamily,
          ),
          _ActionButton(
            label: l10n.btnHard,
            icon: HugeIcons.strokeRoundedHelpCircle,
            onTap: onHard,
            fontFamily: fontFamily,
          ),
          _ActionButton(
            label: l10n.btnEasy,
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            onTap: onEasy,
            fontFamily: fontFamily,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final String fontFamily;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 95, // Fixed width for alignment
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onBackground.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: icon,
              size: 26,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
