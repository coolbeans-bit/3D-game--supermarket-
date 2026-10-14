import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/find/letter_round.dart';
import 'package:asmitra_game/game/find/shelf_hint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the cashier names a real shelf for the current letter', () {
    final hint = whereIsLetter(ProductCatalog.starter, 'द');

    expect(hint, 'द साठी दूध पहिल्या रांगेत आहे.');
  });

  test('finding the letter clears the cashier hint', () {
    final round = LetterRound(
      catalog: ProductCatalog.starter,
      startLetter: 'द',
    );
    round.rememberHint(whereIsLetter(ProductCatalog.starter, round.letter));
    expect(round.whereHint, isNotNull);

    round.checkPickup(ProductCatalog.starter.require('milk'));

    expect(round.whereHint, isNull);
    expect(round.letter, isNot('द'));
  });
}
