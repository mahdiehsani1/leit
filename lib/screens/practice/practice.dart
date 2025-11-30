// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/practice/leitner_screen.dart';
import 'package:sqflite/sqflite.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  bool _loading = true;
  int _totalCards = 0;
  int _weakCards = 0;
  int _todayDue = 0;
  List<Map<String, dynamic>> _boxes = [];
  List<double> _progressData = [];
  // We store weekdays (int) instead of strings to localize them in build
  List<int> _dayWeekdays = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DBHelper.instance.database;

    final totalRes = await db.rawQuery("SELECT COUNT(*) FROM leitner");
    final total = Sqflite.firstIntValue(totalRes) ?? 0;

    final weakRes = await db.rawQuery(
      "SELECT COUNT(*) FROM leitner WHERE box = 1",
    );
    final weak = Sqflite.firstIntValue(weakRes) ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final dueRes = await db.rawQuery(
      "SELECT COUNT(*) FROM leitner WHERE nextReview <= ? AND isSuspended = 0",
      [now],
    );
    final due = Sqflite.firstIntValue(dueRes) ?? 0;

    List<Map<String, dynamic>> loadedBoxes = [];
    for (int i = 1; i <= 6; i++) {
      final bRes = await db.rawQuery(
        "SELECT COUNT(*) FROM leitner WHERE box = ?",
        [i],
      );
      final count = Sqflite.firstIntValue(bRes) ?? 0;
      loadedBoxes.add({"box": i, "count": count});
    }

    List<double> loadedProgress = [];
    List<int> loadedWeekdays = [];
    final nowTime = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = nowTime.subtract(Duration(days: i));
      loadedWeekdays.add(day.weekday);

      final startOfDay = DateTime(
        day.year,
        day.month,
        day.day,
      ).millisecondsSinceEpoch;
      final endOfDay = DateTime(
        day.year,
        day.month,
        day.day,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;
      final pRes = await db.rawQuery(
        "SELECT COUNT(*) FROM leitner WHERE lastReview >= ? AND lastReview <= ?",
        [startOfDay, endOfDay],
      );
      loadedProgress.add((Sqflite.firstIntValue(pRes) ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _totalCards = total;
        _weakCards = weak;
        _todayDue = due;
        _boxes = loadedBoxes;
        _progressData = loadedProgress;
        _dayWeekdays = loadedWeekdays;
        _loading = false;
      });
    }
  }

  String _getWeekdayLetter(int weekday, String languageCode) {
    if (languageCode == 'fa') {
      // Persian mapping: Mon(1)=D, Tue(2)=S, Wed(3)=Ch, Thu(4)=P, Fri(5)=J, Sat(6)=Sh, Sun(7)=Y
      const days = {1: "د", 2: "س", 3: "چ", 4: "پ", 5: "ج", 6: "ش", 7: "ی"};
      return days[weekday] ?? "";
    } else if (languageCode == 'de') {
      // German mapping
      const days = {1: "M", 2: "D", 3: "M", 4: "D", 5: "F", 6: "S", 7: "S"};
      return days[weekday] ?? "";
    } else {
      // English/Default
      const days = {1: "M", 2: "T", 3: "W", 4: "T", 5: "F", 6: "S", 7: "S"};
      return days[weekday] ?? "";
    }
  }

  // --- Start Dialog ---
  void _showStartDialog(AppLocalizations l10n, String fontFamily, bool isRtl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseMode,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 20),
              _modeTile(
                l10n.modeNormal,
                l10n.modeNormalDesc,
                HugeIcons.strokeRoundedArrowRight01,
                PracticeMode.normal,
                fontFamily,
                isRtl,
                flipIcon: true, // Arrow Right needs flip
              ),
              _modeTile(
                l10n.modeReverse,
                l10n.modeReverseDesc,
                HugeIcons.strokeRoundedArrowLeft01,
                PracticeMode.reverse,
                fontFamily,
                isRtl,
                flipIcon: true, // Arrow Left needs flip
              ),
              _modeTile(
                l10n.modeMixed,
                l10n.modeMixedDesc,
                HugeIcons.strokeRoundedShuffle,
                PracticeMode.mixed,
                fontFamily,
                isRtl,
                flipIcon: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modeTile(
    String title,
    String subtitle,
    List<List<dynamic>> icon,
    PracticeMode mode,
    String fontFamily,
    bool isRtl, {
    bool flipIcon = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Transform.rotate(
          angle: (flipIcon && isRtl) ? 3.14159 : 0,
          child: HugeIcon(
            icon: icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontFamily),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: fontFamily)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LeitnerScreen(mode: mode)),
        ).then((_) => _loadData());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    // Generate localized labels dynamically
    final List<String> localizedLabels = _dayWeekdays
        .map((w) => _getWeekdayLetter(w, l10n.localeName))
        .toList();

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.practiceTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showStartDialog(l10n, fontFamily, isRtl),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: isRtl ? 3.14159 : 0,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPlay,
                          size: 24,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.startTrainingSession,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.overview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FadeInUp(
                    child: _summaryCard(
                      context,
                      icon: HugeIcons.strokeRoundedLayers01,
                      title: _totalCards.toString(),
                      label: l10n.totalCards,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FadeInUp(
                    child: _summaryCard(
                      context,
                      icon: HugeIcons.strokeRoundedBrokenBone,
                      title: _weakCards.toString(),
                      label: l10n.weakCards,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FadeInUp(
              child: _summaryCard(
                context,
                icon: HugeIcons.strokeRoundedClock02,
                title: _todayDue.toString(),
                label: l10n.dueToday,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.weeklyProgress,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            _barChart(context, _progressData, localizedLabels, fontFamily),
            const SizedBox(height: 24),
            _lineChart(context, _progressData, localizedLabels, fontFamily),
            const SizedBox(height: 40),
            Text(
              l10n.boxStatus,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ..._boxes.map(
              (b) => FadeInUp(
                child: _leitnerBoxCard(
                  context,
                  box: b["box"],
                  count: b["count"],
                  l10n: l10n,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _summaryCard(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required String label,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: icon,
            size: 28,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onBackground,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leitnerBoxCard(
    BuildContext context, {
    required int box,
    required int count,
    required AppLocalizations l10n,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "B$box",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                fontSize: 16,
                fontFamily: fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.leitnerBoxLabel(box),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.colorScheme.onBackground.withOpacity(0.1),
              ),
            ),
            child: Text(
              l10n.cardsCount(count),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart(
    BuildContext context,
    List<double> data,
    List<String> labels,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    double maxY = 5;
    if (data.isNotEmpty) {
      final maxVal = data.reduce((a, b) => a > b ? a : b);
      maxY = maxVal > 5 ? maxVal + 5 : 10;
    }
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.onBackground,
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  TextStyle(
                    color: theme.colorScheme.background,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < labels.length && value.toInt() >= 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[value.toInt()],
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.5,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: fontFamily,
                        ),
                      ),
                    );
                  }
                  return const Text("");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onBackground.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i],
                  width: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: theme.colorScheme.onBackground.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _lineChart(
    BuildContext context,
    List<double> data,
    List<String> labels,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    double maxY = 5;
    if (data.isNotEmpty) {
      final maxVal = data.reduce((a, b) => a > b ? a : b);
      maxY = maxVal > 5 ? maxVal + 5 : 10;
    }
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => theme.colorScheme.onBackground,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.round().toString(),
                    TextStyle(
                      color: theme.colorScheme.background,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onBackground.withOpacity(0.05),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    // Show only specific labels to avoid crowding
                    if (index == 0 || index == 3 || index == 6) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.5,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i]),
              ),
              isCurved: true,
              curveSmoothness: 0.35,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: false,
                color: theme.colorScheme.onBackground.withOpacity(0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.background,
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.onBackground,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
