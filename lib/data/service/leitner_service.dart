// ignore_for_file: unused_import

import 'dart:math'; // برای max
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/data/model/leitnerModel.dart';

/// مدل ترکیبی برای تمرین: خود آیتم + وضعیت لایتنر + وضعیت نمایش معکوس
class LeitnerCard {
  final ItemModel item;
  final LeitnerModel state;
  final bool startWithBack; // آیا کارت باید برعکس شروع شود؟

  LeitnerCard({
    required this.item,
    required this.state,
    this.startWithBack = false,
  });
}

class LeitnerService {
  static final LeitnerService instance = LeitnerService._internal();
  LeitnerService._internal();

  int _now() => DateTime.now().millisecondsSinceEpoch;

  /// اضافه کردن یک آیتم جدید به سیستم لایتنر
  Future<void> addToLeitner(int itemId) async {
    final db = DBHelper.instance;
    final m = LeitnerModel(
      itemId: itemId,
      box: 1,
      nextReview: _now(),
      lastReview: 0,
      reviewCount: 0,
      wrongCount: 0,
      isSuspended: 0,
      easeFactor: 2.5, // مقدار اولیه استاندارد
      lastInterval: 0,
    );
    await db.insertLeitner(m);
  }

  /// دریافت کارت‌هایی که موعد مرورشان رسیده است
  Future<List<LeitnerCard>> getDueCards() async {
    final db = await DBHelper.instance.database;
    final now = _now();

    // تغییر مهم: اضافه کردن ستون‌های examplesEn و examplesFa به کوئری
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT 
        l.id as l_id, l.itemId as l_itemId, l.box, l.nextReview, l.lastReview, 
        l.reviewCount, l.wrongCount, l.isSuspended, l.easeFactor, l.lastInterval,
        i.id as i_id, i.type, i.german, i.en, i.fa, i.examples, 
        i.examplesEn, i.examplesFa, -- <--- این خط اضافه شد
        i.article, i.plural, 
        i.prateritum, i.perfekt, i.partizip, i.synonyms, i.antonyms, i.explanation, 
        i.level, i.tags, i.notes, i.createdAt
      FROM leitner l
      INNER JOIN items i ON l.itemId = i.id
      WHERE l.nextReview <= ? AND l.isSuspended = 0
      ORDER BY l.nextReview ASC
    ''',
      [now],
    );

    return results.map((row) {
      // ساخت مپ ItemModel
      final itemMap = {
        'id': row['i_id'],
        'type': row['type'],
        'german': row['german'],
        'en': row['en'],
        'fa': row['fa'],
        'examples': row['examples'],
        'examplesEn': row['examplesEn'], // <--- اضافه شد
        'examplesFa': row['examplesFa'], // <--- اضافه شد
        'article': row['article'],
        'plural': row['plural'],
        'prateritum': row['prateritum'],
        'perfekt': row['perfekt'],
        'partizip': row['partizip'],
        'synonyms': row['synonyms'],
        'antonyms': row['antonyms'],
        'explanation': row['explanation'],
        'level': row['level'],
        'tags': row['tags'],
        'notes': row['notes'],
        'createdAt': row['createdAt'],
      };

      // ساخت مپ LeitnerModel
      final leitnerMap = {
        'id': row['l_id'],
        'itemId': row['l_itemId'],
        'box': row['box'],
        'nextReview': row['nextReview'],
        'lastReview': row['lastReview'],
        'reviewCount': row['reviewCount'],
        'wrongCount': row['wrongCount'],
        'isSuspended': row['isSuspended'],
        'easeFactor': row['easeFactor'],
        'lastInterval': row['lastInterval'],
      };

      // استفاده از fromDB که در مدل تعریف کردیم
      return LeitnerCard(
        item: ItemModel.fromDB(itemMap),
        state: LeitnerModel.fromDB(leitnerMap),
        startWithBack: false,
      );
    }).toList();
  }

  // --- پیاده‌سازی الگوریتم SM-2 ---

  void _updateSM2(LeitnerModel m, int quality) {
    if (quality >= 3) {
      // پاسخ صحیح
      if (m.reviewCount == 0) {
        m.lastInterval = 1;
      } else if (m.reviewCount == 1) {
        m.lastInterval = 6;
      } else {
        m.lastInterval = (m.lastInterval * m.easeFactor).round();
      }

      m.reviewCount++;

      // آپدیت Ease Factor
      double newEf =
          m.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEf < 1.3) newEf = 1.3;
      m.easeFactor = newEf;

      // آپدیت تقریبی جعبه
      if (m.lastInterval < 3)
        m.box = 1;
      else if (m.lastInterval < 10)
        m.box = 2;
      else if (m.lastInterval < 30)
        m.box = 3;
      else if (m.lastInterval < 90)
        m.box = 4;
      else if (m.lastInterval < 180)
        m.box = 5;
      else
        m.box = 6;
    } else {
      // پاسخ غلط
      m.reviewCount = 0;
      m.lastInterval = 1;
      m.box = 1;
    }

    m.lastReview = _now();
    m.nextReview = DateTime.now()
        .add(Duration(days: m.lastInterval))
        .millisecondsSinceEpoch;
  }

  Future<void> markCorrect(LeitnerModel m) async {
    _updateSM2(m, 5);
    await DBHelper.instance.updateLeitner(m);
  }

  Future<void> markHard(LeitnerModel m) async {
    _updateSM2(m, 3);
    await DBHelper.instance.updateLeitner(m);
  }

  Future<void> markWrong(LeitnerModel m) async {
    m.wrongCount++;
    _updateSM2(m, 0);
    await DBHelper.instance.updateLeitner(m);
  }

  Future<void> suspend(LeitnerModel m) async {
    m.isSuspended = 1;
    await DBHelper.instance.updateLeitner(m);
  }

  Future<void> unsuspend(LeitnerModel m) async {
    m.isSuspended = 0;
    await DBHelper.instance.updateLeitner(m);
  }

  Future<void> resetCard(LeitnerModel m) async {
    m.box = 1;
    m.nextReview = _now();
    m.reviewCount = 0;
    m.wrongCount = 0;
    m.isSuspended = 0;
    m.lastReview = 0;
    m.easeFactor = 2.5;
    m.lastInterval = 0;
    await DBHelper.instance.updateLeitner(m);
  }
}
