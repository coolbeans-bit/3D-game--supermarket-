import 'dart:math';

import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/find/letter_round.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ProductCatalog.starter;

  test('the prompt letter is one that a shelf product uses', () {
    final round = LetterRound(catalog: catalog, random: Random(1));

    expect(catalog.withFirstLetter(round.letter), isNotEmpty);
  });

  test('a matching pickup scores and asks for a new letter', () {
    final round = LetterRound(catalog: catalog, random: Random(2));
    final match = catalog.withFirstLetter(round.letter).first;
    final previous = round.letter;

    expect(round.checkPickup(match), isTrue);

    expect(round.score, 1);
    expect(round.streak, 1);
    expect(round.mistakes, 0);
    expect(round.notice, match.marathiName);
    expect(round.letter, isNot(previous));
    expect(catalog.withFirstLetter(round.letter), isNotEmpty);
  });

  test('a wrong pickup keeps the same letter', () {
    final round = LetterRound(catalog: catalog, random: Random(3));
    final wrong = catalog.products.firstWhere(
      (product) => product.firstLetter != round.letter,
    );

    expect(round.checkPickup(wrong), isFalse);

    expect(round.score, 0);
    expect(round.streak, 0);
    expect(round.mistakes, 1);
    expect(round.letter, isNot(wrong.firstLetter));
    expect(round.notice, wrong.marathiName);
  });

  test('either product of a shared letter counts', () {
    final banana = LetterRound(catalog: catalog, startLetter: 'क');
    final onion = LetterRound(catalog: catalog, startLetter: 'क');

    expect(banana.checkPickup(catalog.require('banana')), isTrue);
    expect(onion.checkPickup(catalog.require('onion')), isTrue);
  });
}
