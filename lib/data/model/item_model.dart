import 'dart:convert';

class ItemModel {
  final int? id;
  final String type;
  final String german;
  final List<String> en;
  final List<String> fa;
  final List<String> examples; // مثال‌های آلمانی
  final List<String> examplesEn; // ترجمه انگلیسی مثال‌ها
  final List<String> examplesFa; // ترجمه فارسی مثال‌ها
  final String? article;
  final String? plural;
  final String? prateritum;
  final String? perfekt;
  final String? partizip;
  final List<String>? synonyms;
  final List<String>? antonyms;
  final String? explanation;
  final String level;
  final String? tags;
  final String? notes;
  final int createdAt;

  ItemModel({
    this.id,
    required this.type,
    required this.german,
    required this.en,
    required this.fa,
    required this.examples,
    this.examplesEn = const [],
    this.examplesFa = const [],
    this.article,
    this.plural,
    this.prateritum,
    this.perfekt,
    this.partizip,
    this.synonyms,
    this.antonyms,
    this.explanation,
    required this.level,
    this.tags,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'german': german,
      'en': jsonEncode(en),
      'fa': jsonEncode(fa),
      'examples': jsonEncode(examples),
      'examplesEn': jsonEncode(examplesEn),
      'examplesFa': jsonEncode(examplesFa),
      'article': article,
      'plural': plural,
      'prateritum': prateritum,
      'perfekt': perfekt,
      'partizip': partizip,
      'synonyms': synonyms != null ? jsonEncode(synonyms) : null,
      'antonyms': antonyms != null ? jsonEncode(antonyms) : null,
      'explanation': explanation,
      'level': level,
      'tags': tags,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  // تغییر نام از fromMap به fromDB برای هماهنگی با کدهای قبلی
  factory ItemModel.fromDB(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      type: map['type'],
      german: map['german'],
      en: List<String>.from(jsonDecode(map['en'])),
      fa: List<String>.from(jsonDecode(map['fa'])),
      examples: List<String>.from(jsonDecode(map['examples'])),
      examplesEn: map['examplesEn'] != null
          ? List<String>.from(jsonDecode(map['examplesEn']))
          : [],
      examplesFa: map['examplesFa'] != null
          ? List<String>.from(jsonDecode(map['examplesFa']))
          : [],
      article: map['article'],
      plural: map['plural'],
      prateritum: map['prateritum'],
      perfekt: map['perfekt'],
      partizip: map['partizip'],
      synonyms: map['synonyms'] != null
          ? List<String>.from(jsonDecode(map['synonyms']))
          : null,
      antonyms: map['antonyms'] != null
          ? List<String>.from(jsonDecode(map['antonyms']))
          : null,
      explanation: map['explanation'],
      level: map['level'],
      tags: map['tags'],
      notes: map['notes'],
      createdAt: map['createdAt'],
    );
  }
}
