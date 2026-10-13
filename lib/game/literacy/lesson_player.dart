import 'package:flutter/foundation.dart';

import 'marathi_lesson.dart';

/// Plays one class from the first teach card to the last question.
///
/// A wrong answer stays on the same step and shows why.
class LessonPlayer extends ChangeNotifier {
  ClassYear? year;
  int index = 0;
  String feedback = '';

  bool get choosingClass => year == null;

  ClassPath? get path => year == null ? null : pathFor(year!);

  bool get finished => path != null && index >= path!.steps.length;

  LessonStep? get step {
    final current = path;
    if (current == null || index >= current.steps.length) {
      return null;
    }
    return current.steps[index];
  }

  int get stepNumber => index + 1;

  int get stepCount => path?.steps.length ?? 0;

  void chooseClass(ClassYear value) {
    year = value;
    index = 0;
    feedback = '';
    notifyListeners();
  }

  void leaveClass() {
    year = null;
    index = 0;
    feedback = '';
    notifyListeners();
  }

  void nextTeach() {
    final current = step;
    if (current == null || current.kind != StepKind.teach) {
      return;
    }
    index += 1;
    feedback = '';
    notifyListeners();
  }

  /// Moves on only when [choice] is the taught answer.
  void answer(String choice) {
    final current = step;
    if (current == null || current.kind != StepKind.ask) {
      return;
    }
    if (choice != current.answer) {
      feedback = current.explain;
      notifyListeners();
      return;
    }
    index += 1;
    feedback = 'बरोबर.';
    notifyListeners();
  }
}
