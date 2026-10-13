import 'package:asmitra_game/game/checkpoints/std1_run.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a correct colour answer adds ten points', () {
    final run = Std1Run();
    run.answerColour('🥛 दूध');
    expect(run.points, 10);
    expect(run.index, 1);
    expect(run.checkpoint, Std1Checkpoint.colour);
  });

  test('four colour answers open the object game', () {
    final run = Std1Run();
    for (final ask in Std1Run.colourQuiz) {
      run.answerColour(ask.answer);
    }
    expect(run.colourHits, 6);
    expect(run.checkpoint, Std1Checkpoint.object);
    expect(run.points, 60);
  });

  test('too few colours stay on the checkpoint until a retry', () {
    final run = Std1Run();
    run.answerColour(Std1Run.colourQuiz.first.answer);
    for (var i = 1; i < Std1Run.colourQuiz.length; i++) {
      run.answerColour('चूक');
    }
    expect(run.colourFailed, isTrue);
    expect(run.checkpoint, Std1Checkpoint.colour);
    expect(run.points, 10);
    run.retryColours();
    expect(run.points, 0);
    expect(run.colourFailed, isFalse);
    expect(run.index, 0);
  });

  test('the cart accepts only the object being asked for', () {
    final run = Std1Run()..checkpoint = Std1Checkpoint.object;
    expect(run.take('word-soap'), isFalse);
    expect(run.take('word-apple'), isTrue);
    expect(run.cart, ['word-apple']);
    expect(run.points, 10);
  });

  test('buying the six objects opens the letter game', () {
    final run = Std1Run()..checkpoint = Std1Checkpoint.object;
    for (final id in Std1Run.objectOrder) {
      expect(run.take(id), isTrue);
    }
    run.buyObjects();
    expect(run.checkpoint, Std1Checkpoint.letter);
  });

  test('a letter accepts only the matching product', () {
    final run = Std1Run()
      ..checkpoint = Std1Checkpoint.letter
      ..index = 0;
    expect(run.take('word-banana'), isFalse);
    expect(run.take('word-apple'), isTrue);
    expect(run.wantedLetter!.$1, 'क');
  });

  test('the shopping list is bought when the money covers it', () {
    final run = Std1Run()..checkpoint = Std1Checkpoint.shop;
    for (final id in Std1Run.shopList) {
      expect(run.take(id), isTrue);
    }
    expect(run.take('word-milk'), isFalse);
    run.buyList();
    expect(run.checkpoint, Std1Checkpoint.done);
    expect(run.money, 50 - run.shopCost);
    expect(run.money, greaterThanOrEqualTo(0));
  });

  test('the list stays unbought when the money is short', () {
    final run = Std1Run()
      ..checkpoint = Std1Checkpoint.shop
      ..money = 5;
    for (final id in Std1Run.shopList) {
      expect(run.take(id), isTrue);
    }
    run.buyList();
    expect(run.checkpoint, Std1Checkpoint.shop);
    expect(run.money, 5);
  });
}
