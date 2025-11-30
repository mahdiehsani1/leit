// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// Leit – Onboarding / Intro Screen (Final Version)
/// Theme-aware (Light/Dark), responsive, minimal, uses white/black illustrations
/// ---------------------------------------------------------------------------
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _navigateToTabs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showIntro', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TabsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _index == 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip button (top-right/left based on RTL)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16, left: 16),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: GestureDetector(
                  onTap: () => _navigateToTabs(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onBackground.withOpacity(0.4),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      l10n.introSkip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                // Reverse page order for RTL if needed, but PageView usually handles direction
                // However, standard PageView in Flutter automatically adapts direction.
                children: [
                  _buildPage(
                    context,
                    image: isDark
                        ? "assets/intro/intro_white_1.png"
                        : "assets/intro/intro_black_1.png",
                    title: l10n.intro1Title,
                    text: l10n.intro1Text,
                    fontFamily: fontFamily,
                  ),
                  _buildPage(
                    context,
                    image: isDark
                        ? "assets/intro/intro_white_2.png"
                        : "assets/intro/intro_black_2.png",
                    title: l10n.intro2Title,
                    text: l10n.intro2Text,
                    fontFamily: fontFamily,
                  ),
                  _buildPage(
                    context,
                    image: isDark
                        ? "assets/intro/intro_white_3.png"
                        : "assets/intro/intro_black_3.png",
                    title: l10n.intro3Title,
                    text: l10n.intro3Text,
                    fontFamily: fontFamily,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// Indicators + Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Page indicators
                  Row(
                    children: List.generate(3, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.colorScheme.onBackground
                              : theme.colorScheme.onBackground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }),
                  ),

                  /// Next button (theme-aware)
                  ElevatedButton(
                    onPressed: () {
                      if (!isLastPage) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _navigateToTabs();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onBackground,
                      foregroundColor: theme.colorScheme.background,
                      shape: isLastPage
                          ? RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            )
                          : const CircleBorder(),
                      padding: isLastPage
                          ? const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            )
                          : const EdgeInsets.all(16),
                      elevation: 0,
                    ),
                    child: isLastPage
                        ? Text(
                            l10n.introNext,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.background,
                              fontWeight: FontWeight.w500,
                              fontFamily: fontFamily,
                            ),
                          )
                        : Transform.rotate(
                            angle: isRtl ? 3.14159 : 0,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              size: 22,
                            ),
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

  /// -----------------------------------------------------------------------
  /// A single intro page layout
  /// -----------------------------------------------------------------------
  Widget _buildPage(
    BuildContext context, {
    required String image,
    required String title,
    required String text,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.07),

            /// Illustration (responsive)
            Image.asset(
              image,
              width: size.width * 0.75,
              height: size.height * 0.35,
              fit: BoxFit.contain,
            ),

            SizedBox(height: size.height * 0.07),

            /// Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
            ),

            const SizedBox(height: 24),

            /// Body text
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                height: 1.5,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
