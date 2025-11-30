// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:leit/l10n/app_localizations.dart';

class PracticeProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const PracticeProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Localization & Theme Instances
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    // Prevent division by zero
    final double progress = total == 0 ? 0 : (current / total).clamp(0.0, 1.0);

    return Column(
      children: [
        // Counter Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progressLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
                fontFamily: fontFamily,
              ),
            ),
            Text(
              "$current / $total",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Bar
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          // Using Stack with AlignmentDirectional to support RTL fill direction
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
