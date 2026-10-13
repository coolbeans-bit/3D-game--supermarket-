import 'package:asmitra_game/game/literacy/lesson_player.dart';
import 'package:asmitra_game/game/literacy/marathi_lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each class is a different lesson', () {
    expect(pathFor(ClassYear.std1).steps.first.word, 'सफरचंद');
    expect(pathFor(ClassYear.std2).learns, contains('शब्द'));
    expect(pathFor(ClassYear.std3).learns, contains('वाक्य'));
    expect(pathFor(ClassYear.std4).learns, contains('किंमत'));
    expect(pathFor(ClassYear.std5).learns, contains('वाक्य'));
    expect(
      pathFor(ClassYear.std1).steps.length,
      isNot(pathFor(ClassYear.std5).steps.length),
    );
  });

  test('a class teaches the word before it asks', () {
    final player = LessonPlayer()..chooseClass(ClassYear.std1);
    expect(player.step!.kind, StepKind.teach);
    expect(player.step!.word, 'सफरचंद');
    player.nextTeach();
    expect(player.step!.kind, StepKind.ask);
    expect(player.step!.picture, '🍎');
  });

  test('a wrong answer stays on the step and explains the word', () {
    final player = LessonPlayer()..chooseClass(ClassYear.std1);
    player.nextTeach();
    final index = player.index;
    player.answer('केळी');
    expect(player.index, index);
    expect(player.feedback, contains('सफरचंद'));
    player.answer('सफरचंद');
    expect(player.index, index + 1);
    expect(player.feedback, 'बरोबर.');
  });

  test('finishing the last question ends the class', () {
    final player = LessonPlayer()..chooseClass(ClassYear.std4);
    while (!player.finished) {
      final step = player.step!;
      if (step.kind == StepKind.teach) {
        player.nextTeach();
      } else {
        player.answer(step.answer);
      }
    }
    expect(player.finished, isTrue);
    player.leaveClass();
    expect(player.choosingClass, isTrue);
  });

  test('standard 5 asks for sentence order after showing the pattern', () {
    final player = LessonPlayer()..chooseClass(ClassYear.std5);
    expect(player.step!.word, contains('मला दोन सफरचंद'));
    expect(player.step!.parts, ['मला', 'दोन', 'सफरचंद', 'हवे आहेत']);
    player.nextTeach();
    player.answer('हवे आहेत मला सफरचंद.');
    expect(player.feedback, contains('क्रम'));
    player.answer('मला दोन सफरचंद हवे आहेत.');
    expect(player.step!.kind, StepKind.teach);
  });
}
