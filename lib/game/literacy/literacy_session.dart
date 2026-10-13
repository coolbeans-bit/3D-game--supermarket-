import 'package:flutter/foundation.dart';

import '../interaction/interactable.dart';
import 'market_words.dart';

enum LearningStandard { std1, std2, upper }

enum LearningActivity { shopping, syllables, shops, prices, talk }

enum LearningPhase { welcome, standard, activity, playing, done }

/// One syllable block on the vegetable stall.
class SyllableTile {
  SyllableTile(this.token, this.label);

  final int token;
  final String label;
  bool used = false;
}

/// Marathi practice in the market. Finding an item does not change shelf stock.
class LiteracySession extends ChangeNotifier {
  LearningPhase phase = LearningPhase.welcome;
  LearningStandard? standard;
  LearningActivity? activity;
  String feedback = 'आज आपण मराठी शब्द शिकूया.';

  final List<String> listIds = [
    for (final goods in marketGoods)
      if (goods.onList) goods.id,
  ];
  final Set<String> collected = {};

  final List<SyllableTile> tiles = [];
  final List<String> built = [];

  static const String tomatoWord = 'टोमॅटो';
  static const List<String> nameChoices = ['केळी', 'टोमॅटो', 'दूध'];
  static const List<String> sentenceCards = [
    'मला दोन सफरचंद हवे आहेत.',
    'मला दूध हवे आहे.',
    'मला एक पुस्तक हवे आहे.',
  ];
  static const String correctSentence = 'मला दोन सफरचंद हवे आहेत.';
  static const List<String> jumbleBank = ['हवे', 'मला', 'आंबे', 'दोन', 'आहेत'];
  static const List<String> jumbleAnswer = [
    'मला',
    'दोन',
    'आंबे',
    'हवे',
    'आहेत',
  ];

  final List<String> arranged = [];
  final List<bool> jumbleUsed = [];

  int get foundCount => collected.length;

  int get goal => listIds.length;

  void begin() {
    if (phase != LearningPhase.welcome) {
      return;
    }
    phase = LearningPhase.standard;
    feedback = 'इयत्ता निवडा.';
    notifyListeners();
  }

  void chooseStandard(LearningStandard value) {
    if (phase != LearningPhase.standard && phase != LearningPhase.activity) {
      return;
    }
    standard = value;
    phase = LearningPhase.activity;
    feedback = 'खेळ निवडा.';
    notifyListeners();
  }

  void chooseActivity(LearningActivity value) {
    if (standard == null) {
      return;
    }
    if (phase != LearningPhase.activity && phase != LearningPhase.done) {
      return;
    }
    activity = value;
    _resetRound();
    phase = LearningPhase.playing;
    feedback = switch (value) {
      LearningActivity.shopping => 'दाराजवळून सुरुवात.',
      LearningActivity.shops => 'दुकानाचे नाव वाचा.',
      LearningActivity.syllables => 'अक्षर निवडा.',
      LearningActivity.prices => 'किंमत वाचा.',
      LearningActivity.talk => 'उत्तर द्या.',
    };
    notifyListeners();
  }

  void backToActivities() {
    if (phase != LearningPhase.done) {
      return;
    }
    phase = LearningPhase.activity;
    feedback = 'खेळ निवडा.';
    notifyListeners();
  }

  String get task {
    return switch (activity) {
      LearningActivity.shopping => switch (standard) {
        LearningStandard.std1 =>
          'चित्र पहा. त्या वस्तूचा शब्द वाचून टोपलीत टाका.',
        LearningStandard.std2 => 'शब्द वाचा. त्याचे चित्र शोधा.',
        _ => 'वाक्य वाचा आणि ती वस्तू टोपलीत टाका.',
      },
      LearningActivity.syllables => switch (standard) {
        LearningStandard.upper => 'याचे नाव कोणते?',
        _ => 'मला ‘$tomatoWord’ शब्द तयार करून दाखव.',
      },
      LearningActivity.shops => switch (standard) {
        LearningStandard.std1 => 'दूध हा शब्द असलेले दुकान शोधा.',
        LearningStandard.std2 => 'गाजर कोणत्या दुकानात मिळेल?',
        _ => 'मला दूध घ्यायचे आहे. योग्य दुकान शोध.',
      },
      LearningActivity.prices => switch (standard) {
        LearningStandard.upper =>
          'तुझ्याकडे ₹50 आहेत. सफरचंद आणि केळी घेतल्यावर किती रुपये उरतील?',
        _ => 'आंब्याची किंमत किती आहे?',
      },
      LearningActivity.talk => 'तुला काय हवे?',
      null => '',
    };
  }

  String aimTitle(String id) {
    final goods = goodsById(id);
    if (goods != null) {
      if (collected.contains(id) && activity == LearningActivity.shopping) {
        return '${goods.emoji}\nटोपलीत आहे';
      }
      return switch (standard) {
        LearningStandard.std2 => goods.emoji,
        LearningStandard.std1 => goods.marathi,
        _ => '${goods.emoji}\n${goods.marathi}',
      };
    }
    return shopById(id)?.marathi ?? '';
  }

  /// Puts a listed item in the basket. A distractor or a repeat does not count.
  bool collect(String id) {
    if (phase != LearningPhase.playing ||
        activity != LearningActivity.shopping) {
      return false;
    }
    final goods = goodsById(id);
    if (goods == null) {
      return false;
    }
    if (!listIds.contains(id)) {
      feedback = 'हे यादीत नाही.';
      notifyListeners();
      return false;
    }
    if (!collected.add(id)) {
      return false;
    }
    if (collected.length == listIds.length) {
      phase = LearningPhase.done;
      feedback = 'खरेदी झाली!';
    } else {
      feedback = '${goods.marathi} टोपलीत टाकले.';
    }
    notifyListeners();
    return true;
  }

  bool visitShop(String id) {
    if (phase != LearningPhase.playing || activity != LearningActivity.shops) {
      return false;
    }
    if (shopById(id) == null) {
      return false;
    }
    final expected = standard == LearningStandard.std2
        ? 'shop-vegetable'
        : 'shop-dairy';
    if (id != expected) {
      feedback = 'हे दुकान वेगळे आहे. नाव पुन्हा वाचा.';
      notifyListeners();
      return false;
    }
    phase = LearningPhase.done;
    feedback = 'बरोबर दुकान!';
    notifyListeners();
    return true;
  }

  void pickSyllable(int token) {
    if (phase != LearningPhase.playing ||
        activity != LearningActivity.syllables ||
        standard == LearningStandard.upper) {
      return;
    }
    SyllableTile? tile;
    for (final candidate in tiles) {
      if (candidate.token == token && !candidate.used) {
        tile = candidate;
        break;
      }
    }
    if (tile == null || built.length >= 3) {
      return;
    }
    tile.used = true;
    built.add(tile.label);
    if (built.length < 3) {
      feedback = built.join();
      notifyListeners();
      return;
    }
    if (_sameLabels(built, const ['टो', 'मॅ', 'टो'])) {
      phase = LearningPhase.done;
      feedback = 'बरोबर! $tomatoWord';
    } else {
      feedback = 'पुन्हा प्रयत्न करा.';
      _restoreTiles();
    }
    notifyListeners();
  }

  void clearSyllables() {
    if (activity != LearningActivity.syllables ||
        standard == LearningStandard.upper) {
      return;
    }
    _restoreTiles();
    feedback = task;
    notifyListeners();
  }

  void chooseName(String name) {
    if (phase != LearningPhase.playing ||
        activity != LearningActivity.syllables ||
        standard != LearningStandard.upper) {
      return;
    }
    if (name == tomatoWord) {
      phase = LearningPhase.done;
      feedback = 'बरोबर! $tomatoWord';
    } else {
      feedback = 'पुन्हा पहा. हे टोमॅटो आहे.';
    }
    notifyListeners();
  }

  void answerPrice(int rupees) {
    if (phase != LearningPhase.playing || activity != LearningActivity.prices) {
      return;
    }
    final expected = standard == LearningStandard.upper ? 15 : 30;
    if (rupees == expected) {
      phase = LearningPhase.done;
      feedback = standard == LearningStandard.upper
          ? 'बरोबर. ₹15 उरतील.'
          : 'बरोबर. आंबा ₹30.';
    } else {
      feedback = 'पुन्हा वाचा.';
    }
    notifyListeners();
  }

  void chooseSentence(String sentence) {
    if (phase != LearningPhase.playing ||
        activity != LearningActivity.talk ||
        standard == LearningStandard.upper) {
      return;
    }
    if (sentence == correctSentence) {
      phase = LearningPhase.done;
      feedback = 'ही घे. अजून काही हवे आहे का?';
    } else {
      feedback = 'हे वाक्य वेगळे आहे. पुन्हा निवडा.';
    }
    notifyListeners();
  }

  void arrangeWord(int index) {
    if (phase != LearningPhase.playing ||
        activity != LearningActivity.talk ||
        standard != LearningStandard.upper) {
      return;
    }
    if (index < 0 || index >= jumbleUsed.length || jumbleUsed[index]) {
      return;
    }
    jumbleUsed[index] = true;
    arranged.add(jumbleBank[index]);
    if (arranged.length < jumbleAnswer.length) {
      feedback = arranged.join(' ');
      notifyListeners();
      return;
    }
    if (_sameLabels(arranged, jumbleAnswer)) {
      phase = LearningPhase.done;
      feedback = 'ही घे. अजून काही हवे आहे का?';
    } else {
      feedback = 'क्रम पुन्हा जुळवा.';
      _restoreJumble();
    }
    notifyListeners();
  }

  void clearArrangement() {
    if (activity != LearningActivity.talk ||
        standard != LearningStandard.upper) {
      return;
    }
    _restoreJumble();
    feedback = task;
    notifyListeners();
  }

  void _resetRound() {
    collected.clear();
    built.clear();
    arranged.clear();
    tiles
      ..clear()
      ..addAll([
        SyllableTile(0, 'गा'),
        SyllableTile(1, 'टो'),
        SyllableTile(2, 'जर'),
        SyllableTile(3, 'मॅ'),
        SyllableTile(4, 'टो'),
        SyllableTile(5, 'दू'),
      ]);
    jumbleUsed
      ..clear()
      ..addAll(List<bool>.filled(jumbleBank.length, false));
  }

  void _restoreTiles() {
    built.clear();
    for (final tile in tiles) {
      tile.used = false;
    }
  }

  void _restoreJumble() {
    arranged.clear();
    for (var i = 0; i < jumbleUsed.length; i++) {
      jumbleUsed[i] = false;
    }
  }

  bool _sameLabels(List<String> actual, List<String> expected) {
    if (actual.length != expected.length) {
      return false;
    }
    for (var i = 0; i < actual.length; i++) {
      if (actual[i] != expected[i]) {
        return false;
      }
    }
    return true;
  }
}

/// A stall piece whose label follows the lesson, not a fixed English name.
class LearningTarget implements Interactable {
  LearningTarget({
    required this.id,
    required this.session,
    required this.onInteract,
    required this.action,
  });

  @override
  final String id;

  final LiteracySession session;
  final void Function() onInteract;
  final String action;

  @override
  String get displayName => session.aimTitle(id);

  @override
  String get prompt => action;

  @override
  int? get priceAmount => null;

  @override
  bool isInteractable = true;

  @override
  void interact() => onInteract();
}
