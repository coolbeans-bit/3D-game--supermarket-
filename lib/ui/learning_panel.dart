import 'package:flutter/material.dart';

import '../game/literacy/literacy_session.dart';
import '../game/literacy/market_words.dart';
import 'chiku_mark.dart';

/// Grade, activity, and the Marathi practice for the current round.
class LearningPanel extends StatelessWidget {
  const LearningPanel({super.key, required this.session});

  final LiteracySession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final atStart =
            session.phase == LearningPhase.welcome ||
            session.phase == LearningPhase.standard ||
            session.phase == LearningPhase.activity;
        final child = switch (session.phase) {
          LearningPhase.welcome => _storyCard(session),
          LearningPhase.standard => _choiceCard(
            title: session.feedback,
            choices: const [
              ('इयत्ता १', 'literacy-std1', LearningStandard.std1),
              ('इयत्ता २', 'literacy-std2', LearningStandard.std2),
              ('इयत्ता ३ ते ५', 'literacy-upper', LearningStandard.upper),
            ],
            onSelected: session.chooseStandard,
          ),
          LearningPhase.activity => _activityCard(session),
          LearningPhase.playing
              when session.activity == LearningActivity.shopping =>
            _shoppingList(session),
          LearningPhase.playing => _roundCard(session),
          LearningPhase.done => _messageCard(
            session.feedback,
            button: 'पुन्हा खेळ',
            buttonKey: 'literacy-again',
            onPressed: session.backToActivities,
          ),
        };
        if (atStart) {
          return ColoredBox(
            color: const Color(0xFFF3D7A8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        final puzzle =
            session.phase == LearningPhase.playing &&
            session.activity != LearningActivity.shopping;
        return Align(
          alignment: puzzle ? Alignment.bottomCenter : Alignment.topLeft,
          child: Padding(
            padding: puzzle
                ? const EdgeInsets.fromLTRB(150, 0, 16, 210)
                : const EdgeInsets.only(left: 8, top: 156),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: puzzle ? 340 : 168),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

const TextStyle _ink = TextStyle(
  color: Color(0xFF3A2A1A),
  fontSize: 18,
  height: 1.3,
  fontWeight: FontWeight.w700,
);

Widget _storyCard(LiteracySession session) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const ChikuMark(size: 84),
      const SizedBox(height: 14),
      const Text(
        'चिकूची बाजार सफर',
        style: TextStyle(
          color: Color(0xFF3A2A1A),
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      const Text('मी चिकू. आज सकाळी आईने बाजाराची यादी दिली.', style: _ink),
      const SizedBox(height: 8),
      const Text(
        'ती म्हणाली: शब्द वाच, योग्य वस्तू ओळख, आणि टोपलीत टाक.',
        style: _ink,
      ),
      const SizedBox(height: 8),
      Text(session.feedback, key: const Key('literacy-status'), style: _ink),
      const SizedBox(height: 8),
      const Text('सुरुवात दाराजवळ आहे. Open दाबा, मग आत जा.', style: _ink),
      const SizedBox(height: 16),
      _action('सुरुवात', 'literacy-start', session.begin),
    ],
  );
}

Widget _messageCard(
  String message, {
  required String button,
  required String buttonKey,
  required VoidCallback onPressed,
}) {
  return _sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            ChikuMark(size: 48),
            SizedBox(width: 10),
            Expanded(child: Text('अस्मित्रा बाजार', style: _ink)),
          ],
        ),
        const SizedBox(height: 8),
        Text(message, key: const Key('literacy-status'), style: _ink),
        const SizedBox(height: 12),
        _action(button, buttonKey, onPressed),
      ],
    ),
  );
}

Widget _choiceCard({
  required String title,
  required List<(String, String, LearningStandard)> choices,
  required void Function(LearningStandard) onSelected,
}) {
  return _sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: _ink),
        const SizedBox(height: 10),
        for (final choice in choices) ...[
          _action(choice.$1, choice.$2, () => onSelected(choice.$3)),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}

Widget _activityCard(LiteracySession session) {
  const activities = [
    (
      LearningActivity.shopping,
      'बाजाराची खरेदी',
      'शब्द वाचून वस्तू शोधा',
      'literacy-shopping',
    ),
    (
      LearningActivity.syllables,
      'भाजीवाल्याचा खेळ',
      'अक्षरांपासून शब्द तयार करा',
      'literacy-syllables',
    ),
    (
      LearningActivity.shops,
      'दुकान शोधा',
      'दुकानाचे नाव वाचा',
      'literacy-shops',
    ),
    (
      LearningActivity.prices,
      'बाजारातील किंमत',
      'किंमत वाचून उत्तर द्या',
      'literacy-prices',
    ),
    (
      LearningActivity.talk,
      'बाजारातील संवाद',
      'वाक्य निवडा किंवा जुळवा',
      'literacy-talk',
    ),
  ];
  return SingleChildScrollView(
    child: _sheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(session.feedback, style: _ink),
          const SizedBox(height: 8),
          for (final activity in activities) ...[
            FilledButton(
              key: Key(activity.$4),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 52),
              ),
              onPressed: () => session.chooseActivity(activity.$1),
              child: Column(
                children: [
                  Text(
                    activity.$2,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(activity.$3, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    ),
  );
}

Widget _shoppingList(LiteracySession session) {
  return _sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.feedback,
          key: const Key('literacy-status'),
          style: const TextStyle(
            color: Color(0xFF3A2A1A),
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'मला घ्यायचे आहे:',
          style: TextStyle(
            color: Color(0xFF3A2A1A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        for (final id in session.listIds) _listRow(session, id),
        const SizedBox(height: 6),
        Text(
          'टोपली ${session.foundCount}/${session.goal}',
          key: const Key('literacy-basket'),
          style: _ink,
        ),
        if (session.collected.isNotEmpty)
          Wrap(
            spacing: 6,
            children: [
              for (final id in session.listIds)
                if (session.collected.contains(id))
                  Text(
                    goodsById(id)!.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
            ],
          ),
      ],
    ),
  );
}

Widget _listRow(LiteracySession session, String id) {
  final goods = goodsById(id)!;
  final done = session.collected.contains(id);
  final child = switch (session.standard) {
    LearningStandard.std2 => Text(goods.marathi, style: _ink),
    LearningStandard.upper => Text(goods.sentence, style: _ink),
    _ => Text(goods.emoji, style: const TextStyle(fontSize: 32)),
  };
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.circle_outlined,
          color: done ? const Color(0xFF2E8B57) : const Color(0xFF8A7058),
          size: 18,
        ),
        const SizedBox(width: 8),
        Flexible(child: child),
      ],
    ),
  );
}

Widget _roundCard(LiteracySession session) {
  return SingleChildScrollView(
    child: _sheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(session.task, key: const Key('literacy-status'), style: _ink),
          const SizedBox(height: 8),
          Text(session.feedback, style: _ink),
          const SizedBox(height: 10),
          ...switch (session.activity) {
            LearningActivity.syllables => _syllableBody(session),
            LearningActivity.prices => _priceBody(session),
            LearningActivity.talk => _talkBody(session),
            LearningActivity.shops => [
              const Text(
                'दुकानाकडे पहा आणि नाव वाचा. मग निवडा दाबा.',
                style: _ink,
              ),
            ],
            _ => const <Widget>[],
          },
        ],
      ),
    ),
  );
}

List<Widget> _syllableBody(LiteracySession session) {
  if (session.standard == LearningStandard.upper) {
    return [
      const Text(
        '🍅',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 48),
      ),
      const SizedBox(height: 8),
      for (final name in LiteracySession.nameChoices) ...[
        _action(name, 'literacy-name-$name', () => session.chooseName(name)),
        const SizedBox(height: 8),
      ],
    ];
  }
  return [
    Text(
      session.built.isEmpty ? '___' : session.built.join(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3A2A1A),
      ),
    ),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tile in session.tiles)
          if (!tile.used)
            _action(
              tile.label,
              'literacy-tile-${tile.token}',
              () => session.pickSyllable(tile.token),
            ),
      ],
    ),
    const SizedBox(height: 8),
    _action('पुसून टाका', 'literacy-clear-tiles', session.clearSyllables),
  ];
}

List<Widget> _priceBody(LiteracySession session) {
  const lines = ['🍎 सफरचंद — ₹20', '🍌 केळी — ₹15', '🥭 आंबा — ₹30'];
  final options = session.standard == LearningStandard.upper
      ? const [15, 35, 50]
      : const [15, 20, 30];
  return [
    for (final line in lines) Text(line, style: _ink),
    const SizedBox(height: 8),
    for (final rupees in options) ...[
      _action(
        '₹$rupees',
        'literacy-price-$rupees',
        () => session.answerPrice(rupees),
      ),
      const SizedBox(height: 8),
    ],
  ];
}

List<Widget> _talkBody(LiteracySession session) {
  if (session.standard == LearningStandard.upper) {
    return [
      Text(
        session.arranged.isEmpty ? '...' : session.arranged.join(' '),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3A2A1A),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < LiteracySession.jumbleBank.length; i++)
            if (!session.jumbleUsed[i])
              _action(
                LiteracySession.jumbleBank[i],
                'literacy-jumble-$i',
                () => session.arrangeWord(i),
              ),
        ],
      ),
      const SizedBox(height: 8),
      _action('पुसून टाका', 'literacy-clear-words', session.clearArrangement),
    ];
  }
  return [
    for (final sentence in LiteracySession.sentenceCards) ...[
      _action(
        sentence,
        'literacy-sentence-$sentence',
        () => session.chooseSentence(sentence),
      ),
      const SizedBox(height: 8),
    ],
  ];
}

Widget _sheet({required Widget child}) {
  return Material(
    key: const Key('literacy-panel'),
    color: const Color(0xF0FFF6E8),
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: child,
    ),
  );
}

Widget _action(String label, String keyName, VoidCallback onPressed) {
  return FilledButton(
    key: Key(keyName),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF2E8B57),
      foregroundColor: Colors.white,
      minimumSize: const Size(88, 44),
    ),
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
  );
}
