// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/tabs.dart';
import 'package:shimmer/shimmer.dart';
import 'package:leit/data/service/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _service = StatisticsService();
  late Future<StatisticsData> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<StatisticsData>(
          future: _statsFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading(context);
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.errorLoadingStats,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            final bool hasTrendData = data.reviewTrend.any((e) => e.count > 0);

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
              physics: const BouncingScrollPhysics(),
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.statsPageTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 44),

                // 1. Daily Summary Header
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _buildDailyHeader(context, data, l10n, fontFamily),
                ),

                const SizedBox(height: 32),

                // 2. Review Trend Chart
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSectionTitle(
                    context,
                    l10n.reviewTrendTitle,
                    fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: hasTrendData
                      ? _buildLineChart(context, data.reviewTrend, fontFamily)
                      : _buildEmptyState(
                          context,
                          l10n.noReviewActivity,
                          fontFamily,
                        ),
                ),

                const SizedBox(height: 32),

                // 3. Accuracy Chart
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildSectionTitle(
                    context,
                    l10n.accuracyChartTitle,
                    fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: hasTrendData
                      ? _buildBarChart(context, data.reviewTrend, fontFamily)
                      : _buildEmptyState(
                          context,
                          l10n.noAccuracyData,
                          fontFamily,
                        ),
                ),

                const SizedBox(height: 32),

                // 4. Leitner Overview
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildSectionTitle(
                    context,
                    l10n.leitnerDistribution,
                    fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: _buildLeitnerCard(
                    context,
                    data.boxCounts,
                    l10n,
                    fontFamily,
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Smart Insights
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _buildSmartInsights(
                    context,
                    data.boxCounts,
                    l10n,
                    fontFamily,
                  ),
                ),

                const SizedBox(height: 32),

                // 6. Strong & Weak Areas
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: _buildStrengthsAndWeaknesses(
                    context,
                    data,
                    l10n,
                    fontFamily,
                  ),
                ),

                const SizedBox(height: 32),

                // 7. Goals & Streak
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: _buildGoalsAndStreak(context, data, l10n, fontFamily),
                ),

                const SizedBox(height: 40),

                // 8. CTA Button
                FadeInUp(
                  delay: const Duration(milliseconds: 1100),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Change to Practice tab (Index 1)
                        TabsScreen.globalKey.currentState?.changeTab(1);
                      },
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
                      child: Text(
                        l10n.btnContinuePractice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Shimmer Loading Method ---
  Widget _buildShimmerLoading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 3 Cards
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 100,
                  // Use Directional margins for RTL support
                  margin: EdgeInsetsDirectional.only(end: index < 2 ? 12 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Chart Title
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Chart Box
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 32),
          // Bar Chart Title
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Bar Chart Box
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onBackground.withOpacity(0.4),
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String fontFamily,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
        fontFamily: fontFamily,
      ),
    );
  }

  // --- 1. Header Cards ---
  Widget _buildDailyHeader(
    BuildContext context,
    StatisticsData data,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.statReviewed,
            "${data.reviewedToday}",
            HugeIcons.strokeRoundedView,
            fontFamily,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.statLearned,
            "${data.learnedToday}",
            HugeIcons.strokeRoundedBrain02,
            fontFamily,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.statAccuracy,
            "${(data.dailyAccuracy * 100).toInt()}%",
            HugeIcons.strokeRoundedTarget02,
            fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    List<List<dynamic>> icon,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: icon,
            size: 24,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onBackground,
              fontSize: 20,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Line Chart ---
  Widget _buildLineChart(
    BuildContext context,
    List<DailyTrend> trends,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 2,
                getTitlesWidget: (val, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "${val.toInt()}",
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                        fontSize: 10,
                        fontFamily: fontFamily,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => theme.colorScheme.onBackground,
              tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
              getTooltipItems: (items) => items
                  .map(
                    (spot) => LineTooltipItem(
                      spot.y.toInt().toString(),
                      TextStyle(
                        color: theme.colorScheme.background,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: trends
                  .map((e) => FlSpot(e.dayIndex.toDouble(), e.count.toDouble()))
                  .toList(),
              isCurved: true,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 5,
                      color: theme.colorScheme.background,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.onBackground,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.onBackground.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Bar Chart ---
  Widget _buildBarChart(
    BuildContext context,
    List<DailyTrend> trends,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.onBackground,
              tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${rod.toY.toInt()}%",
                  TextStyle(
                    color: theme.colorScheme.background,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                );
              },
            ),
          ),
          barGroups: trends.map((e) {
            return BarChartGroupData(
              x: e.dayIndex,
              barRods: [
                BarChartRodData(
                  toY: e.accuracy * 100,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- 4. Leitner Pie Chart & List ---
  Widget _buildLeitnerCard(
    BuildContext context,
    Map<int, int> counts,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onBackground;

    final colors = [
      baseColor.withOpacity(0.1), // Box 1
      baseColor.withOpacity(0.2), // Box 2
      baseColor.withOpacity(0.35), // Box 3
      baseColor.withOpacity(0.5), // Box 4
      baseColor.withOpacity(0.7), // Box 5
      baseColor.withOpacity(0.9), // Box 6 (Mastered)
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Pie Chart
          SizedBox(
            height: 140,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 30,
                sections: [
                  for (int i = 1; i <= 6; i++)
                    PieChartSectionData(
                      color: colors[i - 1],
                      value: (counts[i] ?? 0).toDouble(),
                      title: '',
                      radius: 18,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend List
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                  context,
                  colors[0],
                  l10n.box1New,
                  counts[1] ?? 0,
                  fontFamily,
                ),
                _buildLegendItem(
                  context,
                  colors[1],
                  l10n.box2,
                  counts[2] ?? 0,
                  fontFamily,
                ),
                _buildLegendItem(
                  context,
                  colors[2],
                  l10n.box3,
                  counts[3] ?? 0,
                  fontFamily,
                ),
                _buildLegendItem(
                  context,
                  colors[3],
                  l10n.box4,
                  counts[4] ?? 0,
                  fontFamily,
                ),
                _buildLegendItem(
                  context,
                  colors[4],
                  l10n.box5,
                  counts[5] ?? 0,
                  fontFamily,
                ),
                _buildLegendItem(
                  context,
                  colors[5],
                  l10n.box6Mastered,
                  counts[6] ?? 0,
                  fontFamily,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Color color,
    String label,
    int count,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontFamily: fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$count",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Smart Insights ---
  Widget _buildSmartInsights(
    BuildContext context,
    Map<int, int> counts,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    String message = l10n.insightDefault;
    List<List<dynamic>> icon = HugeIcons.strokeRoundedIdea01;

    // Logic based on counts
    if ((counts[1] ?? 0) > 20) {
      message = l10n.insightBox1Full;
      icon = HugeIcons.strokeRoundedAlert02;
    } else if ((counts[6] ?? 0) > 30) {
      message = l10n.insightMastered(counts[6] ?? 0);
      icon = HugeIcons.strokeRoundedChampion;
    } else if ((counts[4] ?? 0) + (counts[5] ?? 0) > 40) {
      message = l10n.insightLongTerm;
      icon = HugeIcons.strokeRoundedBrain02;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.smartInsight,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Strong & Weak Areas ---
  Widget _buildStrengthsAndWeaknesses(
    BuildContext context,
    StatisticsData data,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    return Column(
      children: [
        _buildAreaCard(
          context,
          l10n.strongAreas,
          data.categoryStrengths,
          true,
          l10n,
          fontFamily,
        ),
        const SizedBox(height: 16),
        _buildAreaCard(
          context,
          l10n.needsPractice,
          data.categoryWeaknesses,
          false,
          l10n,
          fontFamily,
        ),
      ],
    );
  }

  Widget _buildAreaCard(
    BuildContext context,
    String title,
    List<CategoryAccuracy> items,
    bool isStrong,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: isStrong
                    ? HugeIcons.strokeRoundedTradeUp
                    : HugeIcons.strokeRoundedTradeDown,
                color: theme.colorScheme.onBackground,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                l10n.notEnoughData,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ...items.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.onBackground.withOpacity(0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "${(e.accuracy * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground.withOpacity(
                        isStrong ? 0.8 : 0.6,
                      ),
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Streak & Goals ---
  Widget _buildGoalsAndStreak(
    BuildContext context,
    StatisticsData data,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);

    const int dailyTarget = 20;
    const int weeklyTarget = 140;

    double dailyProgress = (data.reviewedToday / dailyTarget).clamp(0.0, 1.0);
    double weeklyProgress = (data.weeklyReviewCount / weeklyTarget).clamp(
      0.0,
      1.0,
    );

    return Row(
      children: [
        // Streak Card
        Expanded(
          flex: 4,
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: theme.colorScheme.background,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  "${data.streak}",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.background,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  l10n.dayStreak,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.background.withOpacity(0.7),
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Goals Card
        Expanded(
          flex: 5,
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.onBackground.withOpacity(0.05),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalProgress(
                  context,
                  "${l10n.dailyGoal} (${data.reviewedToday}/$dailyTarget)",
                  dailyProgress,
                  fontFamily,
                ),
                _buildGoalProgress(
                  context,
                  "${l10n.weeklyGoal} (${data.weeklyReviewCount}/$weeklyTarget)",
                  weeklyProgress,
                  fontFamily,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgress(
    BuildContext context,
    String label,
    double progress,
    String fontFamily,
  ) {
    final safeProgress = progress.isNaN || progress.isInfinite ? 0.0 : progress;

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
            Text(
              "${(safeProgress * 100).toInt()}%",
              style: TextStyle(fontSize: 11, fontFamily: fontFamily),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}
