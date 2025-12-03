// ignore_for_file: deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:leit/data/database/db_helper.dart';
import 'package:leit/data/model/item_model.dart';
import 'package:leit/data/service/ai_service.dart'; // سرویس هوش مصنوعی
import 'package:leit/data/service/leitner_service.dart';
import 'package:leit/l10n/app_localizations.dart';

enum ContentType {
  word,
  verb,
  adjective,
  adverb,
  nounPhrase,
  sentence,
  idiom,
  verbNounPhrase,
}

class AddItemScreen extends StatefulWidget {
  final ItemModel? itemToEdit;

  const AddItemScreen({super.key, this.itemToEdit});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  ContentType? _selectedType;
  final TextEditingController _germanController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<TextEditingController> _enTranslations = [TextEditingController()];
  List<TextEditingController> _faTranslations = [TextEditingController()];

  // مدیریت مثال‌ها به صورت گروهی (آلمانی، انگلیسی، فارسی)
  List<Map<String, TextEditingController>> _exampleGroups = [
    {
      'de': TextEditingController(),
      'en': TextEditingController(),
      'fa': TextEditingController(),
    },
  ];

  String _selectedLevel = "A2";
  String _selectedArticle = "der";
  final TextEditingController _nounPluralController = TextEditingController();
  final TextEditingController _verbPastSimpleController =
      TextEditingController();
  final TextEditingController _verbPastPerfectController =
      TextEditingController();
  final TextEditingController _verbPartizipController = TextEditingController();
  List<TextEditingController> _adjSynonyms = [TextEditingController()];
  List<TextEditingController> _adjAntonyms = [TextEditingController()];
  final TextEditingController _expressionExplanationController =
      TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _isMagicLoading = false; // متغیر لودینگ برای دکمه هوش مصنوعی

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _populateFields(widget.itemToEdit!);
    }
  }

  void _populateFields(ItemModel item) {
    _selectedType = _getTypeFromDbString(item.type);
    _selectedLevel = item.level;
    _germanController.text = item.german;
    _tagsController.text = item.tags ?? "";
    _notesController.text = item.notes ?? "";
    _expressionExplanationController.text = item.explanation ?? "";

    _enTranslations = item.en.isNotEmpty
        ? item.en.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController()];

    _faTranslations = item.fa.isNotEmpty
        ? item.fa.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController()];

    // پر کردن فیلدهای مثال
    if (item.examples.isNotEmpty) {
      _exampleGroups = [];
      for (int i = 0; i < item.examples.length; i++) {
        _exampleGroups.add({
          'de': TextEditingController(text: item.examples[i]),
          'en': TextEditingController(
            text: (item.examplesEn.length > i) ? item.examplesEn[i] : "",
          ),
          'fa': TextEditingController(
            text: (item.examplesFa.length > i) ? item.examplesFa[i] : "",
          ),
        });
      }
    }

    if (item.synonyms != null && item.synonyms!.isNotEmpty) {
      _adjSynonyms = item.synonyms!
          .map((e) => TextEditingController(text: e))
          .toList();
    }
    if (item.antonyms != null && item.antonyms!.isNotEmpty) {
      _adjAntonyms = item.antonyms!
          .map((e) => TextEditingController(text: e))
          .toList();
    }

    if (_selectedType == ContentType.word) {
      _selectedArticle = item.article ?? "der";
      _nounPluralController.text = item.plural ?? "";
    } else if (_selectedType == ContentType.verb) {
      _verbPastSimpleController.text = item.prateritum ?? "";
      _verbPastPerfectController.text = item.perfekt ?? "";
      _verbPartizipController.text = item.partizip ?? "";
    }
  }

  ContentType? _getTypeFromDbString(String typeStr) {
    for (var value in ContentType.values) {
      if (typeStr.contains(value.name)) return value;
    }
    return null;
  }

  // --- Magic Fill Method ---
  Future<void> _handleMagicFill() async {
    final text = _germanController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a German word first!")),
      );
      return;
    }

    setState(() => _isMagicLoading = true);

    try {
      // درخواست به سرویس هوش مصنوعی
      final ItemModel? result = await AIService.instance.magicFill(text);

      if (result != null && mounted) {
        setState(() {
          // 1. تعیین نوع کلمه
          _selectedType = _getTypeFromDbString(result.type) ?? ContentType.word;

          // 2. ترجمه‌ها (انگلیسی و فارسی)
          _enTranslations = result.en.isNotEmpty
              ? result.en.map((e) => TextEditingController(text: e)).toList()
              : [TextEditingController()];

          _faTranslations = result.fa.isNotEmpty
              ? result.fa.map((e) => TextEditingController(text: e)).toList()
              : [TextEditingController()];

          // 3. مثال‌ها
          if (result.examples.isNotEmpty) {
            _exampleGroups.clear();
            for (int i = 0; i < result.examples.length; i++) {
              _exampleGroups.add({
                'de': TextEditingController(text: result.examples[i]),
                'en': TextEditingController(
                  text: (i < result.examplesEn.length)
                      ? result.examplesEn[i]
                      : '',
                ),
                'fa': TextEditingController(
                  text: (i < result.examplesFa.length)
                      ? result.examplesFa[i]
                      : '',
                ),
              });
            }
          } else {
            // اگر مثالی نبود یک گروه خالی بگذار تا UI خراب نشود
            _exampleGroups = [
              {
                'de': TextEditingController(),
                'en': TextEditingController(),
                'fa': TextEditingController(),
              },
            ];
          }

          // 4. فیلدهای اختصاصی بر اساس نوع
          if (_selectedType == ContentType.word) {
            if (result.article != null &&
                ['der', 'die', 'das'].contains(result.article)) {
              _selectedArticle = result.article!;
            }
            if (result.plural != null) {
              _nounPluralController.text = result.plural!;
            }
          } else if (_selectedType == ContentType.verb) {
            if (result.prateritum != null) {
              _verbPastSimpleController.text = result.prateritum!;
            }
            if (result.perfekt != null) {
              _verbPastPerfectController.text = result.perfekt!;
            }
            if (result.partizip != null) {
              _verbPartizipController.text = result.partizip!;
            }
          }

          // 5. مترادف و متضاد (برای صفت)
          if (result.synonyms != null && result.synonyms!.isNotEmpty) {
            _adjSynonyms = result.synonyms!
                .map((e) => TextEditingController(text: e))
                .toList();
          }
          if (result.antonyms != null && result.antonyms!.isNotEmpty) {
            _adjAntonyms = result.antonyms!
                .map((e) => TextEditingController(text: e))
                .toList();
          }

          // 6. توضیحات و تگ‌ها
          if (result.explanation != null) {
            _expressionExplanationController.text = result.explanation!;
          }
          if (result.tags != null) {
            _tagsController.text = result.tags!;
          }
          if (result.notes != null) {
            _notesController.text = result.notes!;
          }

          // 7. سطح
          if (["A1", "A2", "B1", "B2", "C1", "C2"].contains(result.level)) {
            _selectedLevel = result.level;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✨ Magic Fill Successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Magic Fill Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isMagicLoading = false);
    }
  }

  @override
  void dispose() {
    _germanController.dispose();
    _notesController.dispose();
    _nounPluralController.dispose();
    _verbPastSimpleController.dispose();
    _verbPastPerfectController.dispose();
    _verbPartizipController.dispose();
    _expressionExplanationController.dispose();
    _tagsController.dispose();

    for (final c in _enTranslations) c.dispose();
    for (final c in _faTranslations) c.dispose();
    for (final group in _exampleGroups) {
      group['de']!.dispose();
      group['en']!.dispose();
      group['fa']!.dispose();
    }
    for (final c in _adjSynonyms) c.dispose();
    for (final c in _adjAntonyms) c.dispose();
    super.dispose();
  }

  void _clearTypeSpecificFields() {
    _nounPluralController.clear();
    _verbPastSimpleController.clear();
    _verbPastPerfectController.clear();
    _verbPartizipController.clear();
    _expressionExplanationController.clear();
  }

  // --- Save Logic ---
  void _saveItem() async {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    if (_formKey.currentState?.validate() != true) return;
    if (_selectedType == null) {
      _showError(l10n.errSelectType, fontFamily);
      return;
    }
    if (!_enTranslations.any((c) => c.text.trim().isNotEmpty)) {
      _showError(l10n.errEnterEnglish, fontFamily);
      return;
    }
    if (!_faTranslations.any((c) => c.text.trim().isNotEmpty)) {
      _showError(l10n.errEnterPersian, fontFamily);
      return;
    }

    if (_selectedType == ContentType.verb) {
      if (_verbPastSimpleController.text.trim().isEmpty) {
        _showError(l10n.errPrateritum, fontFamily);
        return;
      }
      if (_verbPastPerfectController.text.trim().isEmpty) {
        _showError(l10n.errPerfekt, fontFamily);
        return;
      }
    }

    final germanText = _germanController.text.trim();

    // Check Duplicate
    if (widget.itemToEdit == null ||
        (widget.itemToEdit != null &&
            widget.itemToEdit!.german != germanText)) {
      final exists = await DBHelper.instance.itemExists(germanText);
      if (exists) {
        _showError(l10n.errDuplicate, fontFamily);
        return;
      }
    }

    final item = ItemModel(
      id: widget.itemToEdit?.id,
      type: _selectedType.toString(),
      german: germanText,
      en: _enTranslations
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      fa: _faTranslations
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      // ذخیره مثال‌ها
      examples: _exampleGroups
          .map((g) => g['de']!.text.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      examplesEn: _exampleGroups
          .where((g) => g['de']!.text.trim().isNotEmpty)
          .map((g) => g['en']!.text.trim())
          .toList(),
      examplesFa: _exampleGroups
          .where((g) => g['de']!.text.trim().isNotEmpty)
          .map((g) => g['fa']!.text.trim())
          .toList(),
      article: _selectedType == ContentType.word ? _selectedArticle : null,
      plural: _selectedType == ContentType.word
          ? _nounPluralController.text.trim()
          : null,
      prateritum: _selectedType == ContentType.verb
          ? _verbPastSimpleController.text.trim()
          : null,
      perfekt: _selectedType == ContentType.verb
          ? _verbPastPerfectController.text.trim()
          : null,
      partizip: _selectedType == ContentType.verb
          ? _verbPartizipController.text.trim()
          : null,
      synonyms: _selectedType == ContentType.adjective
          ? _adjSynonyms
                .map((c) => c.text.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : null,
      antonyms: _selectedType == ContentType.adjective
          ? _adjAntonyms
                .map((c) => c.text.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : null,
      explanation:
          [
            ContentType.adverb,
            ContentType.idiom,
            ContentType.sentence,
            ContentType.verbNounPhrase,
            ContentType.nounPhrase,
          ].contains(_selectedType)
          ? _expressionExplanationController.text.trim()
          : null,
      level: _selectedLevel,
      tags: _tagsController.text.trim().isEmpty
          ? null
          : _tagsController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt:
          widget.itemToEdit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    final db = await DBHelper.instance.database;

    if (widget.itemToEdit == null) {
      final id = await DBHelper.instance.insertItem(item);
      await LeitnerService.instance.addToLeitner(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.msgSaved,
            style: TextStyle(fontFamily: fontFamily),
          ),
          backgroundColor: Theme.of(context).colorScheme.onBackground,
        ),
      );
    } else {
      await db.update(
        "items",
        item.toMap(),
        where: "id = ?",
        whereArgs: [item.id],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.msgUpdated,
            style: TextStyle(fontFamily: fontFamily),
          ),
          backgroundColor: Theme.of(context).colorScheme.onBackground,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showError(String message, String fontFamily) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: fontFamily)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Transform.rotate(
            angle: isRtl ? 3.14159 : 0,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 22,
              color: theme.colorScheme.onBackground,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? l10n.editItemTitle : l10n.addItemTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
            fontFamily: fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: Text(
              isEditing ? l10n.btnUpdate : l10n.btnSave,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
                fontFamily: fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
              children: [
                _buildTypeSelector(context, l10n, fontFamily),
                const SizedBox(height: 20),
                _sectionCard(
                  context,
                  title: l10n.labelGermanText,
                  child: _buildTextField(
                    context,
                    controller: _germanController,
                    hint: l10n.hintGermanText,
                    icon: HugeIcons.strokeRoundedTextFont,
                    fontFamily: 'Poppins',
                    l10n: l10n,
                    // --- اضافه کردن دکمه جادویی در انتهای فیلد متنی ---
                    suffixIcon: IconButton(
                      onPressed: _isMagicLoading ? null : _handleMagicFill,
                      tooltip: "Magic Fill with AI",
                      icon: _isMagicLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.amber,
                              ),
                            )
                          : const HugeIcon(
                              icon: HugeIcons.strokeRoundedAiMagic,
                              color: Colors.amber,
                              size: 24,
                            ),
                    ),
                  ),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  context,
                  title: l10n.labelEnTrans,
                  trailing: l10n.trailingMultiple,
                  child: _buildDynamicFieldList(
                    context,
                    controllers: _enTranslations,
                    hint: l10n.hintEnTrans,
                    addLabel: l10n.btnAddEn,
                    icon: HugeIcons.strokeRoundedTranslate,
                    fontFamily: 'Poppins',
                  ),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  context,
                  title: l10n.labelFaTrans,
                  trailing: l10n.trailingMultiple,
                  child: _buildDynamicFieldList(
                    context,
                    controllers: _faTranslations,
                    hint: l10n.hintFaTrans,
                    addLabel: l10n.btnAddFa,
                    icon: HugeIcons.strokeRoundedTranslate,
                    // اجباری کردن فونت فارسی برای فیلد ترجمه فارسی
                    fontFamily: 'IRANSans',
                  ),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                if (_selectedType != null) ...[
                  _buildSpecificFieldsForType(context, l10n, fontFamily),
                  const SizedBox(height: 14),
                ],
                _sectionCard(
                  context,
                  title: l10n.labelLevel,
                  child: _buildLevelSelector(context, fontFamily),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  context,
                  title: l10n.sectionExamples,
                  trailing: l10n.trailingOptional,
                  child: _buildExampleGroupList(context, l10n, fontFamily),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  context,
                  title: l10n.labelTags,
                  trailing: l10n.trailingOptional,
                  child: _buildTextField(
                    context,
                    controller: _tagsController,
                    hint: l10n.hintTags,
                    icon: HugeIcons.strokeRoundedTag01,
                    fontFamily: fontFamily,
                    l10n: l10n,
                  ),
                  fontFamily: fontFamily,
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  context,
                  title: l10n.labelNotes,
                  trailing: l10n.trailingOptional,
                  child: _buildTextField(
                    context,
                    controller: _notesController,
                    hint: l10n.hintNotes,
                    icon: HugeIcons.strokeRoundedNote01,
                    maxLines: 3,
                    fontFamily: fontFamily,
                    l10n: l10n,
                  ),
                  fontFamily: fontFamily,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    String label;
    if (_selectedType == null) {
      label = l10n.hintSelectType;
    } else {
      label = _contentTypeLabel(_selectedType!, l10n);
    }

    return _sectionCard(
      context,
      title: l10n.labelContentType,
      fontFamily: fontFamily,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTypeBottomSheet(context, l10n, fontFamily),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLayers01,
                size: 22,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(
                      _selectedType == null ? 0.4 : 0.85,
                    ),
                    fontWeight: _selectedType == null
                        ? FontWeight.w400
                        : FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                size: 18,
                color: theme.colorScheme.onBackground.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeBottomSheet(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.sheetChooseType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onBackground,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _typeTile(
                    context,
                    type: ContentType.word,
                    icon: HugeIcons.strokeRoundedAlpha,
                    title: l10n.typeWord,
                    subtitle: l10n.typeWordSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.verb,
                    icon: HugeIcons.strokeRoundedSun01,
                    title: l10n.typeVerb,
                    subtitle: l10n.typeVerbSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.adjective,
                    icon: HugeIcons.strokeRoundedSparkles,
                    title: l10n.typeAdj,
                    subtitle: l10n.typeAdjSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.adverb,
                    icon: HugeIcons.strokeRoundedFastWind,
                    title: l10n.typeAdv,
                    subtitle: l10n.typeAdvSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.verbNounPhrase,
                    icon: HugeIcons.strokeRoundedLayersLogo,
                    title: l10n.typeVerbNoun,
                    subtitle: l10n.typeVerbNounSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.sentence,
                    icon: HugeIcons.strokeRoundedParagraph,
                    title: l10n.typeSentence,
                    subtitle: l10n.typeSentenceSub,
                    fontFamily: fontFamily,
                  ),
                  _typeTile(
                    context,
                    type: ContentType.idiom,
                    icon: HugeIcons.strokeRoundedBulb,
                    title: l10n.typeIdiom,
                    subtitle: l10n.typeIdiomSub,
                    fontFamily: fontFamily,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _typeTile(
    BuildContext context, {
    required ContentType type,
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        if (_selectedType != type) _clearTypeSpecificFields();
        setState(() => _selectedType = type);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.onBackground
              : theme.colorScheme.onBackground.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.background
                    : theme.colorScheme.onBackground.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(
                icon: icon,
                size: 22,
                color: isSelected
                    ? theme.colorScheme.onBackground
                    : theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.background
                          : theme.colorScheme.onBackground,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.background.withOpacity(0.7)
                          : theme.colorScheme.onBackground.withOpacity(0.6),
                      fontFamily: fontFamily,
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

  String _contentTypeLabel(ContentType type, AppLocalizations l10n) {
    switch (type) {
      case ContentType.word:
        return l10n.typeWord;
      case ContentType.verb:
        return l10n.typeVerb;
      case ContentType.adjective:
        return l10n.typeAdj;
      case ContentType.adverb:
        return l10n.typeAdv;
      case ContentType.nounPhrase:
        return l10n.typeNounPhrase;
      case ContentType.sentence:
        return l10n.typeSentence;
      case ContentType.idiom:
        return l10n.typeIdiom;
      case ContentType.verbNounPhrase:
        return l10n.typeVerbNoun;
    }
  }

  Widget _buildSpecificFieldsForType(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    switch (_selectedType) {
      case ContentType.word:
        return _sectionCard(
          context,
          title: l10n.sectionNounDetails,
          fontFamily: fontFamily,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildDropdownField(
                      context,
                      title: l10n.labelArticle,
                      value: _selectedArticle,
                      items: const ["der", "die", "das"],
                      fontFamily: fontFamily,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedArticle = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _buildTextField(
                      context,
                      controller: _nounPluralController,
                      hint: l10n.hintPlural,
                      icon: HugeIcons.strokeRoundedCopy01,
                      fontFamily: 'Poppins',
                      l10n: l10n,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case ContentType.verb:
        return _sectionCard(
          context,
          title: l10n.sectionVerbForms,
          fontFamily: fontFamily,
          child: Column(
            children: [
              _buildTextField(
                context,
                controller: _verbPastSimpleController,
                hint: l10n.hintPrateritum,
                icon: HugeIcons.strokeRoundedClock01,
                fontFamily: 'Poppins',
                l10n: l10n,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                context,
                controller: _verbPastPerfectController,
                hint: l10n.hintPerfekt,
                icon: HugeIcons.strokeRoundedClock01,
                fontFamily: 'Poppins',
                l10n: l10n,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                context,
                controller: _verbPartizipController,
                hint: l10n.hintPartizip,
                icon: HugeIcons.strokeRoundedClock01,
                fontFamily: 'Poppins',
                l10n: l10n,
              ),
            ],
          ),
        );

      case ContentType.adjective:
        return Column(
          children: [
            _sectionCard(
              context,
              title: l10n.labelSynonyms,
              trailing: l10n.trailingOptional,
              fontFamily: fontFamily,
              child: _buildDynamicFieldList(
                context,
                controllers: _adjSynonyms,
                hint: l10n.hintSynonym,
                addLabel: l10n.btnAddSynonym,
                icon: HugeIcons.strokeRoundedLinkCircle,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.labelAntonyms,
              trailing: l10n.trailingOptional,
              fontFamily: fontFamily,
              child: _buildDynamicFieldList(
                context,
                controllers: _adjAntonyms,
                hint: l10n.hintAntonym,
                addLabel: l10n.btnAddAntonym,
                icon: HugeIcons.strokeRoundedLinkCircle,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        );

      case ContentType.adverb:
        return _sectionCard(
          context,
          title: l10n.sectionUsageNotes,
          trailing: l10n.trailingOptional,
          fontFamily: fontFamily,
          child: _buildTextField(
            context,
            controller: _expressionExplanationController,
            hint: l10n.hintUsageNotes,
            icon: HugeIcons.strokeRoundedInformationCircle,
            maxLines: 3,
            fontFamily: fontFamily,
            l10n: l10n,
          ),
        );

      case ContentType.verbNounPhrase:
      case ContentType.nounPhrase:
      case ContentType.sentence:
      case ContentType.idiom:
        return _sectionCard(
          context,
          title: l10n.sectionExplanation,
          trailing: l10n.trailingOptional,
          fontFamily: fontFamily,
          child: _buildTextField(
            context,
            controller: _expressionExplanationController,
            hint: l10n.hintExplanation,
            icon: HugeIcons.strokeRoundedInformationCircle,
            maxLines: 3,
            fontFamily: fontFamily,
            l10n: l10n,
          ),
        );

      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLevelSelector(BuildContext context, String fontFamily) {
    final theme = Theme.of(context);
    const levels = ["A1", "A2", "B1", "B2", "C1", "C2"];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: levels.map((lvl) {
        final bool active = lvl == _selectedLevel;
        return GestureDetector(
          onTap: () => setState(() => _selectedLevel = lvl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.onBackground
                  : theme.colorScheme.onBackground.withOpacity(0.04),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              lvl,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: active
                    ? theme.colorScheme.background
                    : theme.colorScheme.onBackground.withOpacity(0.8),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    String? trailing,
    required Widget child,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                  fontFamily: fontFamily,
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                    fontFamily: fontFamily,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required List<List<dynamic>> icon,
    int maxLines = 1,
    required String fontFamily,
    required AppLocalizations l10n,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: maxLines == 1
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: HugeIcon(
            icon: icon,
            size: 20,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground,
              fontFamily: fontFamily, // فونت اجباری
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.4),
                fontFamily: fontFamily, // فونت هینت هم پیروی می‌کند
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
            validator: (value) =>
                (controller == _germanController &&
                    (value == null || value.trim().isEmpty))
                ? l10n.errGermanText
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowDown01,
            size: 18,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontFamily: fontFamily,
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildExampleGroupList(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ...List.generate(_exampleGroups.length, (index) {
          final group = _exampleGroups[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onBackground.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                if (_exampleGroups.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          group['de']!.dispose();
                          group['en']!.dispose();
                          group['fa']!.dispose();
                          _exampleGroups.removeAt(index);
                        });
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: 18,
                          color: Colors.redAccent.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                _buildTextField(
                  context,
                  controller: group['de']!,
                  hint: l10n.hintExample,
                  icon: HugeIcons.strokeRoundedQuoteUp,
                  fontFamily: 'Poppins',
                  l10n: l10n,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  context,
                  controller: group['en']!,
                  hint: "English Translation",
                  icon: HugeIcons.strokeRoundedTranslate,
                  fontFamily: 'Poppins',
                  l10n: l10n,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  context,
                  controller: group['fa']!,
                  hint: "ترجمه فارسی",
                  icon: HugeIcons.strokeRoundedTranslate,
                  // اجباری کردن فونت فارسی برای فیلد مثال فارسی
                  fontFamily: 'IRANSans',
                  l10n: l10n,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => setState(
              () => _exampleGroups.add({
                'de': TextEditingController(),
                'en': TextEditingController(),
                'fa': TextEditingController(),
              }),
            ),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: 18,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            label: Text(
              l10n.btnAddExample,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicFieldList(
    BuildContext context, {
    required List<TextEditingController> controllers,
    required String hint,
    required String addLabel,
    required List<List<dynamic>> icon,
    String? fontFamily,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ...List.generate(controllers.length, (index) {
          final isLast = index == controllers.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontFamily:
                          fontFamily, // فونت اجباری در اینجا اعمال می‌شود
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.4),
                        fontFamily: fontFamily, // فونت هینت
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.onBackground.withOpacity(
                        0.03,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (controllers.length > 1)
                  InkWell(
                    onTap: () {
                      setState(() {
                        controllers[index].dispose();
                        controllers.removeAt(index);
                      });
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete02,
                        size: 20,
                        color: theme.colorScheme.onBackground.withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () =>
                setState(() => controllers.add(TextEditingController())),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: 18,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            label: Text(
              addLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
