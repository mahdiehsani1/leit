// ignore_for_file: deprecated_member_use, unreachable_switch_default

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:leit/data/service/leitner_service.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/practice/practice_card.dart';
import 'package:leit/screens/practice/progress_bar.dart';

// Enums for Practice Mode
enum PracticeMode { normal, reverse, mixed }

class LeitnerScreen extends StatefulWidget {
  final PracticeMode mode;

  const LeitnerScreen({super.key, this.mode = PracticeMode.normal});

  @override
  State<LeitnerScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<LeitnerScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  bool _loading = true;
  List<LeitnerCard> _cards = [];
  final int _batchSize = 20;
  bool _hasMoreCards = false;
  int _currentIndex = 0;

  // Holds visual state of current card
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _loading = true);

    final allDueCards = await LeitnerService.instance.getDueCards();
    List<LeitnerCard> sessionCards = [];
    bool hasMore = false;

    if (allDueCards.length > _batchSize) {
      sessionCards = allDueCards.take(_batchSize).toList();
      hasMore = true;
    } else {
      sessionCards = allDueCards;
      hasMore = false;
    }

    // --- Apply Reverse/Mixed Logic ---
    final random = Random();
    final processedCards = sessionCards.map((c) {
      bool startWithBack = false;
      if (widget.mode == PracticeMode.reverse) {
        startWithBack = true;
      } else if (widget.mode == PracticeMode.mixed) {
        startWithBack = random.nextBool(); // 50% chance
      }

      return LeitnerCard(
        item: c.item,
        state: c.state,
        startWithBack: startWithBack,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _cards = processedCards;
        _hasMoreCards = hasMore;
        _loading = false;
        _currentIndex = 0;
        // Set first card state
        if (_cards.isNotEmpty) {
          _isFront = !_cards[0].startWithBack;
        }
      });
    }
  }

  void _onEnd() {
    setState(() {
      _currentIndex = _cards.length;
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final card = _cards[previousIndex];
    final state = card.state;

    if (direction == CardSwiperDirection.left) {
      LeitnerService.instance.markWrong(state);
    } else if (direction == CardSwiperDirection.right) {
      LeitnerService.instance.markCorrect(state);
    } else if (direction == CardSwiperDirection.top ||
        direction == CardSwiperDirection.bottom) {
      LeitnerService.instance.markHard(state);
    }

    setState(() {
      _currentIndex = (currentIndex ?? _cards.length);
      // Set next card state based on its config
      if (_currentIndex < _cards.length) {
        _isFront = !_cards[_currentIndex].startWithBack;
      }
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFamily = isRtl ? 'IRANSans' : 'Poppins';

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      );
    }

    final total = _cards.length;
    final finished = _currentIndex >= total && total > 0;
    final isEmpty = total == 0;

    if (finished || isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context, theme, l10n, isRtl, fontFamily),
        body: _buildFinished(context, isEmpty, l10n, fontFamily),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme, l10n, isRtl, fontFamily),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PracticeProgressBar(
                current: _currentIndex + 1,
                total: total,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: CardSwiper(
                controller: _swiperController,
                cardsCount: _cards.length,
                isLoop: false,
                onEnd: _onEnd,
                numberOfCardsDisplayed: _cards.length < 3 ? _cards.length : 3,
                scale: 0.95,
                backCardOffset: const Offset(0, 20),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                  horizontal: true,
                  vertical: true,
                ),
                onSwipe: _onSwipe,
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) {
                      final isTopCard = index == _currentIndex;
                      // If under-layer card, show its default start state
                      final showFront = isTopCard
                          ? _isFront
                          : !_cards[index].startWithBack;

                      return GestureDetector(
                        onTap: isTopCard ? _flipCard : null,
                        child: PracticeCard(
                          item: _cards[index].item,
                          isFront: showFront,
                        ),
                      );
                    },
              ),
            ),
            const SizedBox(height: 40),
            _buildMinimalActionButtons(context, l10n, fontFamily),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _flipCard() {
    setState(() => _isFront = !_isFront);
  }

  // --- UI Widgets ---

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isRtl,
    String fontFamily,
  ) {
    String title;
    switch (widget.mode) {
      case PracticeMode.reverse:
        title = l10n.reversePracticeTitle;
        break;
      case PracticeMode.mixed:
        title = l10n.mixedPracticeTitle;
        break;
      case PracticeMode.normal:
      default:
        title = l10n.practiceTitle;
        break;
    }

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      centerTitle: true,
      leading: IconButton(
        icon: Transform.rotate(
          angle: isRtl ? pi : 0,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 22,
            color: theme.colorScheme.onBackground,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onBackground,
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  Widget _buildMinimalActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionBtn(
            context,
            label: l10n.btnAgain,
            icon: HugeIcons.strokeRoundedRefresh,
            fontFamily: fontFamily,
            onTap: () => _swiperController.swipe(CardSwiperDirection.left),
          ),
          _actionBtn(
            context,
            label: l10n.btnHard,
            icon: HugeIcons.strokeRoundedHelpCircle,
            fontFamily: fontFamily,
            onTap: () => _swiperController.swipe(CardSwiperDirection.top),
          ),
          _actionBtn(
            context,
            label: l10n.btnEasy,
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            fontFamily: fontFamily,
            onTap: () => _swiperController.swipe(CardSwiperDirection.right),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required String label,
    required List<List<dynamic>> icon,
    required VoidCallback onTap,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onBackground.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: icon,
              size: 24,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinished(
    BuildContext context,
    bool isEmpty,
    AppLocalizations l10n,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    String title;
    String subtitle;

    if (isEmpty) {
      title = l10n.sessionNoCardsTitle;
      subtitle = l10n.sessionNoCardsSubtitle;
    } else {
      if (_hasMoreCards) {
        subtitle = l10n.sessionMoreAvailable(_cards.length);
        title = l10n.sessionCompleteTitle;
      } else {
        title = l10n.sessionCompleteTitle;
        subtitle = l10n.sessionCompleteSubtitle(_cards.length);
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: isEmpty
                  ? HugeIcons.strokeRoundedInbox
                  : HugeIcons.strokeRoundedSecurityCheck,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                height: 1.5,
                fontFamily: fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (_hasMoreCards)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _loadCards,
                  child: Text(
                    l10n.btnContinueSession,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),
            if (_hasMoreCards) const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  foregroundColor: theme.colorScheme.onBackground,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.btnFinishForNow,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
