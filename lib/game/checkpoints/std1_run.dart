import 'package:flutter/foundation.dart';

/// One colour question for the first checkpoint.
class ColourAsk {
  const ColourAsk({
    required this.prompt,
    required this.choices,
    required this.answer,
  });

  final String prompt;
  final List<String> choices;
  final String answer;
}

enum Std1Checkpoint { colour, object, letter, shop, done }

/// Std 1 market: colours, then objects, then letters, then a paid list.
class Std1Run extends ChangeNotifier {
  static const int passColours = 4;

  static const List<ColourAsk> colourQuiz = [
    ColourAsk(
      prompt: 'पांढरा रंग कोणता?',
      choices: ['🥛 दूध', '🍎 सफरचंद', '🍌 केळी'],
      answer: '🥛 दूध',
    ),
    ColourAsk(
      prompt: 'लाल फळ कोणते?',
      choices: ['🍌 केळी', '🍎 सफरचंद', '🥕 गाजर'],
      answer: '🍎 सफरचंद',
    ),
    ColourAsk(
      prompt: 'पिवळे फळ कोणते?',
      choices: ['🍌 केळी', '🥛 दूध', '🍅 टोमॅटो'],
      answer: '🍌 केळी',
    ),
    ColourAsk(
      prompt: 'केशरी भाजी कोणती?',
      choices: ['🥕 गाजर', '🍎 सफरचंद', '🥛 दूध'],
      answer: '🥕 गाजर',
    ),
    ColourAsk(
      prompt: 'लाल भाजी कोणती?',
      choices: ['🍅 टोमॅटो', '🍌 केळी', '🥛 दूध'],
      answer: '🍅 टोमॅटो',
    ),
    ColourAsk(
      prompt: 'पिवळसर फळ कोणते?',
      choices: ['🥭 आंबा', '🥛 दूध', '🧼 साबण'],
      answer: '🥭 आंबा',
    ),
  ];

  static const List<String> objectOrder = [
    'word-apple',
    'word-soap',
    'word-banana',
    'word-milk',
    'word-mango',
    'word-carrot',
  ];

  static const List<(String, String)> letters = [
    ('स', 'word-apple'),
    ('क', 'word-banana'),
    ('ग', 'word-carrot'),
    ('द', 'word-milk'),
    ('ट', 'word-tomato'),
    ('आ', 'word-mango'),
  ];

  static const List<String> shopList = [
    'word-apple',
    'word-banana',
    'word-carrot',
  ];

  static const Map<String, int> prices = {
    'word-apple': 20,
    'word-banana': 15,
    'word-carrot': 10,
    'word-milk': 25,
    'word-mango': 30,
    'word-tomato': 12,
    'word-soap': 18,
  };

  Std1Checkpoint checkpoint = Std1Checkpoint.colour;
  int points = 0;
  int index = 0;
  int colourHits = 0;
  int colourEarned = 0;
  bool colourFailed = false;
  String feedback = 'आधी रंग ओळखा.';
  int money = 50;
  final List<String> cart = [];

  ColourAsk? get colourAsk =>
      checkpoint == Std1Checkpoint.colour && index < colourQuiz.length
      ? colourQuiz[index]
      : null;

  String? get wantedObject =>
      checkpoint == Std1Checkpoint.object && index < objectOrder.length
      ? objectOrder[index]
      : null;

  (String, String)? get wantedLetter =>
      checkpoint == Std1Checkpoint.letter && index < letters.length
      ? letters[index]
      : null;

  int get shopCost => shopList.fold(0, (sum, id) => sum + (prices[id] ?? 0));

  static String nameOf(String id) {
    return switch (id) {
      'word-apple' => 'सफरचंद',
      'word-soap' => 'साबण',
      'word-banana' => 'केळी',
      'word-milk' => 'दूध',
      'word-mango' => 'आंबा',
      'word-carrot' => 'गाजर',
      'word-tomato' => 'टोमॅटो',
      _ => id,
    };
  }

  void answerColour(String choice) {
    final ask = colourAsk;
    if (ask == null || colourFailed) {
      return;
    }
    if (choice == ask.answer) {
      points += 10;
      colourEarned += 10;
      colourHits += 1;
      feedback = 'बरोबर. +10 गुण';
    } else {
      feedback = 'पुन्हा पहा. उत्तर ${ask.answer} आहे.';
    }
    index += 1;
    if (index >= colourQuiz.length) {
      if (colourHits >= passColours) {
        checkpoint = Std1Checkpoint.object;
        index = 0;
        cart.clear();
        feedback = 'रंग पूर्ण. आता वस्तू टोपलीत टाका.';
      } else {
        colourFailed = true;
        feedback = 'गुण $colourHits/6. चार हवेत. पुन्हा खेळ.';
      }
    }
    notifyListeners();
  }

  void retryColours() {
    if (!colourFailed) {
      return;
    }
    points -= colourEarned;
    colourEarned = 0;
    colourHits = 0;
    index = 0;
    colourFailed = false;
    feedback = 'आधी रंग ओळखा.';
    notifyListeners();
  }

  /// Puts a market thing in the cart when it matches the current task.
  bool take(String id) {
    switch (checkpoint) {
      case Std1Checkpoint.object:
        final wanted = wantedObject;
        if (wanted == null) {
          return false;
        }
        if (id != wanted) {
          feedback = 'हे वेगळे आहे. ${nameOf(wanted)} शोधा.';
          notifyListeners();
          return false;
        }
        cart.add(id);
        points += 10;
        index += 1;
        feedback = index >= objectOrder.length
            ? 'सगळे टोपलीत. खरेदी करा.'
            : '${nameOf(id)} टोपलीत. +10';
        notifyListeners();
        return true;
      case Std1Checkpoint.letter:
        final wanted = wantedLetter;
        if (wanted == null) {
          return false;
        }
        if (id != wanted.$2) {
          feedback = '${wanted.$1} ने सुरू होणारी वस्तू शोधा.';
          notifyListeners();
          return false;
        }
        points += 10;
        index += 1;
        feedback = '${nameOf(id)} बरोबर.';
        if (index >= letters.length) {
          checkpoint = Std1Checkpoint.shop;
          cart.clear();
          index = 0;
          feedback = 'यादी गोळा करा. तुझ्याकडे ₹$money आहेत.';
        }
        notifyListeners();
        return true;
      case Std1Checkpoint.shop:
        if (!shopList.contains(id) || cart.contains(id)) {
          feedback = 'ही वस्तू यादीत नाही.';
          notifyListeners();
          return false;
        }
        cart.add(id);
        feedback = '${nameOf(id)} टोपलीत. ${cart.length}/${shopList.length}';
        notifyListeners();
        return true;
      case Std1Checkpoint.colour:
      case Std1Checkpoint.done:
        return false;
    }
  }

  void buyObjects() {
    if (checkpoint != Std1Checkpoint.object || index < objectOrder.length) {
      return;
    }
    points += 10;
    checkpoint = Std1Checkpoint.letter;
    index = 0;
    feedback = 'खरेदी झाली. आता अक्षर पाहा.';
    notifyListeners();
  }

  void buyList() {
    if (checkpoint != Std1Checkpoint.shop || cart.length != shopList.length) {
      return;
    }
    if (shopCost > money) {
      feedback = 'पैसे कमी आहेत. यादी ₹$shopCost आहे.';
      notifyListeners();
      return;
    }
    money -= shopCost;
    points += 20;
    checkpoint = Std1Checkpoint.done;
    feedback = 'खरेदी पूर्ण. उरले ₹$money.';
    notifyListeners();
  }
}
