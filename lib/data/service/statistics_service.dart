import 'package:leit/data/database/db_helper.dart';

class StatisticsData {
  final int reviewedToday;
  final int learnedToday;
  final double dailyAccuracy;
  final Map<int, int> boxCounts;
  final List<DailyTrend> reviewTrend;
  final List<CategoryAccuracy> categoryStrengths;
  final List<CategoryAccuracy> categoryWeaknesses;
  final int streak;
  final int weeklyReviewCount;

  StatisticsData({
    required this.reviewedToday,
    required this.learnedToday,
    required this.dailyAccuracy,
    required this.boxCounts,
    required this.reviewTrend,
    required this.categoryStrengths,
    required this.categoryWeaknesses,
    required this.streak,
    required this.weeklyReviewCount,
  });
}

class DailyTrend {
  final int dayIndex;
  final int count;
  final double accuracy;
  final String label; // مثلا "Mon", "Tue" (اختیاری برای آینده)
  DailyTrend(this.dayIndex, this.count, this.accuracy, this.label);
}

class CategoryAccuracy {
  final String category;
  final double accuracy;
  CategoryAccuracy(this.category, this.accuracy);
}

class _DailyStat {
  int count = 0;
  int totalReviews = 0;
  int totalWrongs = 0;
}

class StatisticsService {
  final DBHelper _db = DBHelper.instance;

  // تنظیمات: نمودار ۱۰ روزه، اما محاسبه استریک تا ۶۰ روز قبل
  static const int chartDays = 10;
  static const int historyLookbackDays = 60;

  // اهداف
  static const int dailyTarget = 20;
  static const int weeklyTarget = 140;

  Future<StatisticsData> fetchStatistics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;

    // تاریخ شروع برای محاسبه Streak (۶۰ روز قبل)
    final historyStart = now
        .subtract(const Duration(days: historyLookbackDays))
        .millisecondsSinceEpoch;

    // 1. آمار امروز
    final int reviewed = await _db.getReviewedTodayCount(startOfDay);
    final int learned = await _db.getLearnedTodayCount(startOfDay);

    // 2. جعبه‌ها
    final Map<int, int> boxes = await _db.getLeitnerBoxCounts();

    // 3. دریافت تاریخچه (۶۰ روزه برای محاسبه دقیق Streak)
    // توجه: اگر متد getReviewHistoryLast30Days را هنوز دارید، نامش را در DBHelper عوض کنید یا همان را صدا بزنید ولی مقدار historyStart را بدهید.
    final List<Map<String, dynamic>> historyRaw = await _db
        .getReviewHistorySince(historyStart);

    Map<int, _DailyStat> dailyMap = {};

    for (var row in historyRaw) {
      final ts = row['lastReview'] as int? ?? 0;
      if (ts == 0) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      // فاصله روزها نسبت به "شروع بازه ۶۰ روزه"
      final diff = date
          .difference(now.subtract(const Duration(days: historyLookbackDays)))
          .inDays;

      if (diff >= 0 && diff < historyLookbackDays) {
        if (!dailyMap.containsKey(diff)) dailyMap[diff] = _DailyStat();

        final rCount = row['reviewCount'] as int? ?? 1;
        final wCount = row['wrongCount'] as int? ?? 0;

        dailyMap[diff]!.count += 1; // تعداد کارت‌های یونیک
        dailyMap[diff]!.totalReviews += rCount;
        dailyMap[diff]!.totalWrongs += wCount;
      }
    }

    // --- آماده‌سازی داده‌های نمودار (فقط ۱۰ روز آخر) ---
    List<DailyTrend> trends = [];
    int weeklySum = 0;

    // ایندکس شروع برای ۱۰ روز آخر در بازه ۶۰ روزه
    // بازه ما 0 تا 59 است (60 روز). ۱۰ روز آخر می‌شود 50 تا 59.
    int startChartIndex = historyLookbackDays - chartDays;

    for (int i = 0; i < chartDays; i++) {
      int mapIndex = startChartIndex + i; // مپ کردن به روزهای واقعی در dailyMap

      int count = 0;
      double acc = 0.0;

      if (dailyMap.containsKey(mapIndex)) {
        final stat = dailyMap[mapIndex]!;
        count = stat.count;
        if (stat.totalReviews > 0) {
          acc = 1.0 - (stat.totalWrongs / stat.totalReviews);
        }
        if (acc < 0) acc = 0;
        if (acc > 1) acc = 1;
      }

      // dayIndex برای نمودار باید از 0 تا 9 باشد
      trends.add(DailyTrend(i, count, acc, ""));
    }

    // --- محاسبه Weekly Goal (7 روز آخر) ---
    for (int i = 0; i < 7; i++) {
      int mapIndex =
          (historyLookbackDays - 1) - i; // از دیروز به عقب (روز 59, 58, ...)
      if (dailyMap.containsKey(mapIndex)) {
        weeklySum += dailyMap[mapIndex]!.count;
      }
    }

    // --- محاسبه Streak (تا جایی که صفر نباشد) ---
    int streak = 0;
    // از آخرین روز (روز 59) به عقب چک می‌کنیم
    for (int i = historyLookbackDays - 1; i >= 0; i--) {
      int count = dailyMap.containsKey(i) ? dailyMap[i]!.count : 0;

      if (count > 0) {
        streak++;
      } else {
        // اگر امروز (روز آخر) هنوز تمرین نکرده، استریک قطع نمی‌شود
        if (i == (historyLookbackDays - 1) && reviewed == 0) {
          continue;
        }
        break;
      }
    }

    // دقت امروز
    double todayAcc = trends.last.accuracy;
    if (todayAcc == 0 && reviewed > 0) todayAcc = 1.0;

    // 4. دسته‌بندی‌ها (با پاک‌سازی نام‌ها)
    final List<Map<String, dynamic>> rawTypes = await _db.getAccuracyByType();
    List<CategoryAccuracy> cats = [];

    for (var row in rawTypes) {
      double total = (row['total'] as int? ?? 0).toDouble();
      double wrong = (row['wrong'] as int? ?? 0).toDouble();
      String rawType = row['type'] as String? ?? 'Unknown';

      // --- اصلاح نام دسته (حذف ContentType.) ---
      String cleanType = _cleanCategoryName(rawType);

      if (total > 0) {
        double acc = 1.0 - (wrong / total);
        if (acc < 0) acc = 0;
        cats.add(CategoryAccuracy(cleanType, acc));
      }
    }

    cats.sort((a, b) => b.accuracy.compareTo(a.accuracy));
    final strong = cats.where((e) => e.accuracy >= 0.8).take(3).toList();
    final weak = cats.where((e) => e.accuracy < 0.8).take(3).toList();

    return StatisticsData(
      reviewedToday: reviewed,
      learnedToday: learned,
      dailyAccuracy: todayAcc,
      boxCounts: boxes,
      reviewTrend: trends,
      categoryStrengths: strong,
      categoryWeaknesses: weak,
      streak: streak,
      weeklyReviewCount: weeklySum,
    );
  }

  // متد کمکی برای تمیز کردن رشته‌ها
  String _cleanCategoryName(String raw) {
    // حذف بخش "ContentType."
    String cleaned = raw.replaceAll('ContentType.', '');

    // حذف کاراکترهای اضافه احتمالی و فاصله‌ها
    cleaned = cleaned.replaceAll('_', ' ').trim();

    // بزرگ کردن حرف اول (Capitalize)
    if (cleaned.isNotEmpty) {
      return cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    return cleaned;
  }
}
