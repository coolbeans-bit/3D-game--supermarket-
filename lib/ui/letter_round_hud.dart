import 'package:flutter/material.dart';

import '../game/find/letter_round.dart';

/// Mission card for the letter hunt: the letter pops, the score sits in a
/// coin, and a right or wrong pickup flashes under it.
class LetterRoundHud extends StatefulWidget {
  const LetterRoundHud({super.key, required this.round});

  final LetterRound round;

  @override
  State<LetterRoundHud> createState() => _LetterRoundHudState();
}

class _LetterRoundHudState extends State<LetterRoundHud>
    with TickerProviderStateMixin {
  static const _script = TextStyle(
    fontFamily: 'Nirmala UI',
    fontFamilyFallback: ['Segoe UI', 'Noto Sans Devanagari', 'Mangal'],
  );

  late final AnimationController _pop;
  late final AnimationController _flash;
  late final Animation<double> _popScale;
  String _shownLetter = '';

  @override
  void initState() {
    super.initState();
    _shownLetter = widget.round.letter;
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _popScale = Tween<double>(
      begin: 0.72,
      end: 1,
    ).animate(CurvedAnimation(parent: _pop, curve: Curves.elasticOut));
    _pop.value = 1;
    widget.round.addListener(_onRound);
  }

  void _onRound() {
    if (widget.round.letter != _shownLetter) {
      _shownLetter = widget.round.letter;
      _pop.forward(from: 0);
    }
    if (widget.round.lastMatched != null) {
      _flash.forward(from: 0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.round.removeListener(_onRound);
    _pop.dispose();
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.round;
    final matched = round.lastMatched;
    final notice = round.notice;
    return Material(
      color: const Color(0xF7FFF6E8),
      elevation: 8,
      shadowColor: const Color(0x66000000),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _popScale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE082),
                      border: Border.all(
                        color: const Color(0xFF2E7D32),
                        width: 3,
                      ),
                    ),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                        child: Text(
                          round.letter,
                          key: const Key('find-letter'),
                          style: _script.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'हे अक्षर शोधा',
                      style: _script.copyWith(
                        color: const Color(0xFF1B5E20),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Pill(
                          color: const Color(0xFFFFC107),
                          child: Text(
                            '★  ${round.score}',
                            key: const Key('find-score'),
                            style: const TextStyle(
                              color: Color(0xFF3E2723),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (round.streak >= 2) ...[
                          const SizedBox(width: 6),
                          _Pill(
                            color: const Color(0xFFFF7043),
                            child: Text(
                              'x${round.streak}',
                              key: const Key('find-streak'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notice != null && matched != null) ...[
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _flash,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: matched
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              matched ? 'बरोबर!  $notice' : 'हे नाही  $notice',
                              key: const Key('find-notice'),
                              style: _script.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (round.whereHint != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: 220,
                child: Text(
                  round.whereHint!,
                  key: const Key('cashier-hint'),
                  textAlign: TextAlign.right,
                  style: _script.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      ),
    );
  }
}
