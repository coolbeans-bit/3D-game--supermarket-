import 'package:flutter/material.dart';

import '../game/checkpoints/std1_run.dart';

/// The current Std 1 checkpoint. It sits above the market, not over the child.
class Std1CheckpointPanel extends StatelessWidget {
  const Std1CheckpointPanel({super.key, required this.run});

  final Std1Run run;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: run,
      builder: (context, _) {
        return Material(
          color: const Color(0xF0FFF6E8),
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'गुण ${run.points}',
                  key: const Key('std1-points'),
                  style: const TextStyle(
                    color: Color(0xFF3A2A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  run.feedback,
                  style: const TextStyle(
                    color: Color(0xFF3A2A1A),
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ..._body(run),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<Widget> _body(Std1Run run) {
  return switch (run.checkpoint) {
    Std1Checkpoint.colour => _colour(run),
    Std1Checkpoint.object => _object(run),
    Std1Checkpoint.letter => _letter(run),
    Std1Checkpoint.shop => _shop(run),
    Std1Checkpoint.done => [
      const Text(
        'इयत्ता १ चे चार खेळ पूर्ण.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ],
  };
}

List<Widget> _colour(Std1Run run) {
  if (run.colourFailed) {
    return [
      FilledButton(
        key: const Key('std1-retry'),
        onPressed: run.retryColours,
        child: const Text('पुन्हा खेळ'),
      ),
    ];
  }
  final ask = run.colourAsk;
  if (ask == null) {
    return const [];
  }
  return [
    Text(
      'रंग ${run.index + 1}/6',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    Text(
      ask.prompt,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 6),
    for (var i = 0; i < ask.choices.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: FilledButton(
          key: Key('std1-colour-$i'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3A2A1A),
          ),
          onPressed: () => run.answerColour(ask.choices[i]),
          child: Text(ask.choices[i]),
        ),
      ),
  ];
}

List<Widget> _object(Std1Run run) {
  final wanted = run.wantedObject;
  if (wanted == null) {
    return [
      const Text('टोपली भरली.'),
      FilledButton(
        key: const Key('std1-buy-objects'),
        onPressed: run.buyObjects,
        child: const Text('खरेदी करा'),
      ),
    ];
  }
  return [
    Text(
      'वस्तू ${run.index + 1}/6',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    Text(
      'शोधा: ${Std1Run.nameOf(wanted)}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
    const Text('दाराजवळ Open दाबा. वस्तूकडे पहा. टोपलीत टाका.'),
  ];
}

List<Widget> _letter(Std1Run run) {
  final wanted = run.wantedLetter;
  if (wanted == null) {
    return const [Text('अक्षरे पूर्ण.')];
  }
  return [
    Text(
      'अक्षर ${run.index + 1}/6',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    Text(
      wanted.$1,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
    ),
    const Text('या अक्षराने सुरू होणारी वस्तू शोधा.'),
  ];
}

List<Widget> _shop(Std1Run run) {
  return [
    Text('तुझ्याकडे ₹${run.money} आहेत.'),
    for (final id in Std1Run.shopList)
      Text(
        '${run.cart.contains(id) ? '✓' : '•'} ${Std1Run.nameOf(id)} ₹${Std1Run.prices[id]}',
      ),
    Text('एकूण ₹${run.shopCost}'),
    if (run.cart.length == Std1Run.shopList.length)
      FilledButton(
        key: const Key('std1-buy-list'),
        onPressed: run.buyList,
        child: const Text('खरेदी करा'),
      ),
  ];
}
