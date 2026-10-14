import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/catalog/product_catalog.dart';
import '../../data/models/product_definition.dart';

/// One "find this letter" prompt. Picking up a matching product scores.
class LetterRound extends ChangeNotifier {
  LetterRound({
    required ProductCatalog catalog,
    Random? random,
    String? startLetter,
  }) : _catalog = catalog,
       _random = random ?? Random() {
    if (catalog.products.isEmpty) {
      throw ArgumentError('a letter round needs products');
    }
    _letter = startLetter ?? _pick(avoid: null);
    if (catalog.withFirstLetter(_letter).isEmpty) {
      throw ArgumentError('no product starts with $_letter');
    }
  }

  final ProductCatalog _catalog;
  final Random _random;

  late String _letter;
  int score = 0;
  int mistakes = 0;
  int streak = 0;
  bool? lastMatched;
  String? notice;

  /// Last answer from the cashier. Cleared when the letter is found.
  String? whereHint;

  String get letter => _letter;

  /// Stores what the cashier just said about the current letter.
  void rememberHint(String hint) {
    whereHint = hint;
    notifyListeners();
  }

  /// True when the picked-up product starts with the current letter.
  /// A match advances to a new letter. A miss keeps the same letter.
  bool checkPickup(ProductDefinition product) {
    final matched = product.firstLetter == _letter;
    lastMatched = matched;
    notice = product.marathiName;
    if (matched) {
      score += 1;
      streak += 1;
      whereHint = null;
      _letter = _pick(avoid: _letter);
    } else {
      mistakes += 1;
      streak = 0;
    }
    notifyListeners();
    return matched;
  }

  String _pick({required String? avoid}) {
    final letters = <String>{
      for (final product in _catalog.products) product.firstLetter,
    }.toList();
    final choices = [
      for (final letter in letters)
        if (letter != avoid) letter,
    ];
    final pool = choices.isEmpty ? letters : choices;
    return pool[_random.nextInt(pool.length)];
  }
}
