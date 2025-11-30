// ignore_for_file: deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/home/home.dart';
import 'package:leit/screens/practice/practice.dart';
import 'package:leit/screens/settings/settings.dart';
import 'package:leit/screens/statistics/statistics.dart';

class TabsScreen extends StatefulWidget {
  static final GlobalKey<TabsScreenState> globalKey =
      GlobalKey<TabsScreenState>();
  TabsScreen({Key? key}) : super(key: key ?? globalKey);

  @override
  State<TabsScreen> createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const Practice();
      case 2:
        return const StatisticsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!; // دسترسی به ترجمه

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildPage(),
      bottomNavigationBar: FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: FlashyTabBar(
          selectedIndex: _selectedIndex,
          iconSize: 26,
          animationCurve: Curves.ease,
          showElevation: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          items: [
            FlashyTabBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              activeColor: theme.colorScheme.onBackground,
              title: Text(
                l10n.tabHome,
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
            FlashyTabBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedAiMagic,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              activeColor: theme.colorScheme.onBackground,
              title: Text(
                l10n.tabPractice,
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
            FlashyTabBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedChartMedium,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              activeColor: theme.colorScheme.onBackground,
              title: Text(
                l10n.tabStatistics,
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
            FlashyTabBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              activeColor: theme.colorScheme.onBackground,
              title: Text(
                l10n.tabSettings,
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
