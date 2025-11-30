// ignore_for_file: file_names

class LeitnerModel {
  int? id;
  int itemId;
  int box; // هنوز برای آمار استفاده می‌شود
  int nextReview; // Timestamp
  int lastReview; // Timestamp
  int reviewCount;
  int wrongCount;
  int isSuspended;

  // --- فیلدهای جدید برای الگوریتم SM-2 ---
  double easeFactor; // ضریب آسانی (پیش‌فرض ۲.۵)
  int lastInterval; // آخرین فاصله زمانی (به روز)

  LeitnerModel({
    this.id,
    required this.itemId,
    required this.box,
    required this.nextReview,
    required this.lastReview,
    required this.reviewCount,
    required this.wrongCount,
    required this.isSuspended,
    this.easeFactor = 2.5, // مقدار پیش‌فرض استاندارد SM-2
    this.lastInterval = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "itemId": itemId,
      "box": box,
      "nextReview": nextReview,
      "lastReview": lastReview,
      "reviewCount": reviewCount,
      "wrongCount": wrongCount,
      "isSuspended": isSuspended,
      "easeFactor": easeFactor,
      "lastInterval": lastInterval,
    };
  }

  factory LeitnerModel.fromDB(Map<String, dynamic> e) {
    return LeitnerModel(
      id: e['id'],
      itemId: e['itemId'],
      box: e['box'],
      nextReview: e['nextReview'],
      lastReview: e['lastReview'],
      reviewCount: e['reviewCount'],
      wrongCount: e['wrongCount'],
      isSuspended: e['isSuspended'],
      // خواندن مقادیر جدید (با هندل کردن نال برای دیتابیس‌های قدیمی)
      easeFactor: (e['easeFactor'] as num?)?.toDouble() ?? 2.5,
      lastInterval: (e['lastInterval'] as int?) ?? 0,
    );
  }
}
