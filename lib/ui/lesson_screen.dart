import 'package:flutter/material.dart';

import '../game/literacy/lesson_player.dart';
import '../game/literacy/marathi_lesson.dart';
import 'chiku_mark.dart';
import 'prototype_screen.dart';

/// The class path a student actually plays. One card, then the next.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LessonPlayer _player = LessonPlayer();

  void _openMarket({ClassYear? year}) {
    if (year != null) {
      _player.chooseClass(year);
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const PrototypeScreen()))
        .then((_) {
          if (_player.year != null) {
            _player.leaveClass();
          }
        });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E4C4),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _player,
          builder: (context, _) {
            if (_player.choosingClass) {
              return _classList(
                _player,
                onEnterMarket: _openMarket,
                onClass: (year) => _openMarket(year: year),
              );
            }
            if (_player.finished) {
              return _done(_player);
            }
            return _step(_player);
          },
        ),
      ),
    );
  }
}

Widget _classList(
  LessonPlayer player, {
  required VoidCallback onEnterMarket,
  required void Function(ClassYear year) onClass,
}) {
  return ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
    children: [
      const Row(
        children: [
          ChikuMark(size: 64),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'चिकूची मराठी',
              style: TextStyle(
                color: Color(0xFF3A2A1A),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'इयत्ता निवडा, मग बाजारात चालत जा. आधी शब्द शिक, मग उत्तर द्या.',
        style: TextStyle(
          color: Color(0xFF3A2A1A),
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('enter-market'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8A4B1F),
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 64),
        ),
        onPressed: onEnterMarket,
        child: const Text(
          'बाजारात चला',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 16),
      for (final path in classPaths) ...[
        FilledButton(
          key: Key('lesson-class-${path.year.name}'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B57),
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 72),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => onClass(path.year),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(path.learns, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    ],
  );
}

Widget _step(LessonPlayer player) {
  final path = player.path!;
  final step = player.step!;
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
        child: Row(
          children: [
            TextButton(
              key: const Key('lesson-back'),
              onPressed: player.leaveClass,
              child: const Text('इयत्ता'),
            ),
            Expanded(
              child: Text(
                '${path.title}  ·  ${player.stepNumber}/${player.stepCount}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Color(0xFF3A2A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              step.heading,
              style: const TextStyle(
                color: Color(0xFF8A5A2A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.picture,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 8),
            if (step.kind == StepKind.teach)
              ..._teach(player, step)
            else
              ..._ask(player, step),
          ],
        ),
      ),
    ],
  );
}

List<Widget> _teach(LessonPlayer player, LessonStep step) {
  return [
    Text(
      step.word,
      key: const Key('lesson-word'),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF3A2A1A),
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w800,
      ),
    ),
    if (step.parts.isNotEmpty) ...[
      const SizedBox(height: 10),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final part in step.parts)
            Chip(
              label: Text(
                part,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: const Color(0xFFFFF6E8),
            ),
        ],
      ),
    ],
    const SizedBox(height: 12),
    Text(
      step.note,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF3A2A1A),
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: 16),
    FilledButton(
      key: const Key('lesson-next'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        minimumSize: const Size(160, 52),
      ),
      onPressed: player.nextTeach,
      child: const Text('शिकलो, पुढे', style: TextStyle(fontSize: 18)),
    ),
  ];
}

List<Widget> _ask(LessonPlayer player, LessonStep step) {
  return [
    Text(
      step.prompt,
      key: const Key('lesson-prompt'),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF3A2A1A),
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w800,
      ),
    ),
    if (player.feedback.isNotEmpty) ...[
      const SizedBox(height: 10),
      Text(
        player.feedback,
        key: const Key('lesson-feedback'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: player.feedback == 'बरोबर.'
              ? const Color(0xFF1B6B3A)
              : const Color(0xFF8A2A1A),
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
    const SizedBox(height: 14),
    for (var i = 0; i < step.choices.length; i++) ...[
      FilledButton(
        key: Key('lesson-choice-$i'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3A2A1A),
          minimumSize: const Size(160, 56),
        ),
        onPressed: () => player.answer(step.choices[i]),
        child: Text(
          step.choices[i],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 8),
    ],
  ];
}

Widget _done(LessonPlayer player) {
  final path = player.path!;
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChikuMark(size: 72),
        const SizedBox(height: 16),
        Text(
          '${path.title} पूर्ण',
          style: const TextStyle(
            color: Color(0xFF3A2A1A),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'तू ${path.learns} हा पाठ केला.',
          key: const Key('lesson-done'),
          style: const TextStyle(
            color: Color(0xFF3A2A1A),
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('lesson-classes'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B57),
            foregroundColor: Colors.white,
            minimumSize: const Size(160, 52),
          ),
          onPressed: player.leaveClass,
          child: const Text('दुसरी इयत्ता'),
        ),
      ],
    ),
  );
}

/// The lesson beside the first-person view. It does not cover the center.
class LessonDock extends StatelessWidget {
  const LessonDock({super.key, required this.player, required this.onLeave});

  final LessonPlayer player;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: player,
      builder: (context, _) {
        final step = player.step;
        return Material(
          color: const Color(0xF0FFF6E8),
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: step == null
                ? _dockDone(onLeave)
                : _dockStep(player, step, onLeave),
          ),
        );
      },
    );
  }
}

Widget _dockDone(VoidCallback onLeave) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'पाठ पूर्ण',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      TextButton(onPressed: onLeave, child: const Text('इयत्ता')),
    ],
  );
}

Widget _dockStep(LessonPlayer player, LessonStep step, VoidCallback onLeave) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${player.stepNumber}/${player.stepCount}',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
      Text(step.picture, style: const TextStyle(fontSize: 36)),
      if (step.kind == StepKind.teach) ...[
        Text(
          step.word,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(step.note, style: const TextStyle(fontSize: 13, height: 1.25)),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('lesson-next'),
          onPressed: player.nextTeach,
          child: const Text('शिकलो, पुढे'),
        ),
      ] else ...[
        Text(
          step.prompt,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        if (player.feedback.isNotEmpty)
          Text(
            player.feedback,
            style: const TextStyle(fontSize: 13, height: 1.2),
          ),
        const SizedBox(height: 6),
        for (var i = 0; i < step.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FilledButton(
              key: Key('lesson-choice-$i'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A2A1A),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => player.answer(step.choices[i]),
              child: Text(step.choices[i], textAlign: TextAlign.center),
            ),
          ),
      ],
      TextButton(onPressed: onLeave, child: const Text('मागे')),
    ],
  );
}
