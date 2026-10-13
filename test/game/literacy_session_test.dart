import 'package:asmitra_game/game/literacy/literacy_session.dart';
import 'package:asmitra_game/game/literacy/market_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LiteracySession startShopping(LearningStandard standard) {
    final session = LiteracySession()..begin();
    session.chooseStandard(standard);
    session.chooseActivity(LearningActivity.shopping);
    return session;
  }

  test('the market opens as a Marathi lesson', () {
    final session = LiteracySession();
    expect(session.phase, LearningPhase.welcome);
    expect(session.feedback, contains('मराठी'));
    session.begin();
    expect(session.phase, LearningPhase.standard);
  });

  test('standard 1 shopping matches pictures to words', () {
    final session = startShopping(LearningStandard.std1);
    expect(session.listIds, ['word-apple', 'word-carrot', 'word-banana']);
    expect(session.aimTitle('word-apple'), 'सफरचंद');
    expect(session.task, contains('चित्र'));

    expect(session.collect('word-mango'), isFalse);
    expect(session.feedback, 'हे यादीत नाही.');
    expect(session.collect('word-apple'), isTrue);
    expect(session.collect('word-apple'), isFalse);
    expect(session.foundCount, 1);
    session.collect('word-carrot');
    session.collect('word-banana');
    expect(session.phase, LearningPhase.done);
    expect(session.feedback, 'खरेदी झाली!');
  });

  test('standard 2 shows the picture when the child aims', () {
    final session = startShopping(LearningStandard.std2);
    expect(session.aimTitle('word-banana'), '🍌');
    expect(session.task, contains('शब्द'));
  });

  test('syllable blocks build टोमॅटो', () {
    final session = LiteracySession()..begin();
    session.chooseStandard(LearningStandard.std1);
    session.chooseActivity(LearningActivity.syllables);
    session.pickSyllable(2);
    session.pickSyllable(1);
    session.pickSyllable(3);
    expect(session.phase, LearningPhase.playing);
    expect(session.feedback, 'पुन्हा प्रयत्न करा.');

    session.pickSyllable(1);
    session.pickSyllable(3);
    session.pickSyllable(4);
    expect(session.phase, LearningPhase.done);
    expect(session.feedback, contains('टोमॅटो'));
  });

  test('older children name the tomato from the picture', () {
    final session = LiteracySession()..begin();
    session.chooseStandard(LearningStandard.upper);
    session.chooseActivity(LearningActivity.syllables);
    expect(session.task, 'याचे नाव कोणते?');
    session.chooseName('केळी');
    expect(session.phase, LearningPhase.playing);
    session.chooseName('टोमॅटो');
    expect(session.phase, LearningPhase.done);
  });

  test('the milk task opens the dairy', () {
    final session = LiteracySession()..begin();
    session.chooseStandard(LearningStandard.upper);
    session.chooseActivity(LearningActivity.shops);
    expect(session.task, contains('दूध'));
    expect(session.visitShop('shop-fruit'), isFalse);
    expect(session.visitShop('shop-dairy'), isTrue);
    expect(session.feedback, 'बरोबर दुकान!');
  });

  test('standard 2 looks for the vegetable stall', () {
    final session = LiteracySession()..begin();
    session.chooseStandard(LearningStandard.std2);
    session.chooseActivity(LearningActivity.shops);
    expect(session.visitShop('shop-vegetable'), isTrue);
  });

  test('prices are read from the board', () {
    final younger = LiteracySession()..begin();
    younger.chooseStandard(LearningStandard.std1);
    younger.chooseActivity(LearningActivity.prices);
    expect(younger.task, contains('किंमत'));
    younger.answerPrice(20);
    expect(younger.phase, LearningPhase.playing);
    younger.answerPrice(30);
    expect(younger.feedback, contains('₹30'));

    final older = LiteracySession()..begin();
    older.chooseStandard(LearningStandard.upper);
    older.chooseActivity(LearningActivity.prices);
    older.answerPrice(15);
    expect(older.feedback, contains('₹15'));
  });

  test('sentence cards and a jumbled line both reach the shopkeeper', () {
    final cards = LiteracySession()..begin();
    cards.chooseStandard(LearningStandard.std1);
    cards.chooseActivity(LearningActivity.talk);
    cards.chooseSentence('मला दूध हवे आहे.');
    expect(cards.phase, LearningPhase.playing);
    cards.chooseSentence(LiteracySession.correctSentence);
    expect(cards.feedback, contains('ही घे'));

    final jumble = LiteracySession()..begin();
    jumble.chooseStandard(LearningStandard.upper);
    jumble.chooseActivity(LearningActivity.talk);
    for (var i = 0; i < LiteracySession.jumbleBank.length; i++) {
      final word = LiteracySession.jumbleAnswer[i];
      final index = LiteracySession.jumbleBank.indexOf(word);
      jumble.arrangeWord(index);
    }
    expect(jumble.phase, LearningPhase.done);
    expect(jumble.arranged.join(' '), 'मला दोन आंबे हवे आहेत');
  });

  test('lesson goods stay off the shop shelf list', () {
    expect(marketGoods.where((goods) => goods.onList).length, 3);
    expect(goodsById('word-apple')!.price, 20);
    expect(shopById('shop-dairy')!.marathi, 'दूध डेअरी');
  });
}
