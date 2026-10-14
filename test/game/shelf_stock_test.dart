import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/shelves/shelf_slot.dart';
import 'package:asmitra_game/game/shelves/shelf_unit.dart';
import 'package:asmitra_game/game/shelves/store_shelf_plan.dart';
import 'package:asmitra_game/game/world/supermarket/supermarket_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ProductCatalog.starter;
  final milk = catalog.require('milk');

  test('an empty shelf has no stock and no product visuals', () {
    final shelf = ShelfUnit.empty(id: 'empty', slotsPerLevel: 4);
    expect(shelf.quantity, 0);
    expect(shelf.visualCount, 0);
    expect(shelf.stock, isNull);
  });

  test('stocking fills the matching number of slots from the top', () {
    final shelf = ShelfUnit.empty(id: 'milk-face', slotsPerLevel: 4);
    shelf.stockProduct(milk, 8);

    expect(shelf.quantity, 8);
    expect(shelf.visualCount, 8);
    expect(shelf.stock!.productId, 'milk');
    expect(shelf.stock!.quantity, 8);
    expect(catalog.require(shelf.stock!.productId).name, 'Fresh Milk');
    expect(catalog.require(shelf.stock!.productId).sellingPrice, 48);
    expect(shelf.slots.take(4).every((slot) => slot.level == 2), isTrue);
    expect(shelf.slots.take(8).every((slot) => slot.quantity == 1), isTrue);
    expect(shelf.slots.skip(8).every((slot) => slot.isEmpty), isTrue);
  });

  test('removing stock updates the quantity and the visuals', () {
    final shelf = ShelfUnit.empty(id: 'milk-face', slotsPerLevel: 4);
    shelf.stockProduct(milk, 8);
    shelf.removeStock(milk, 3);

    expect(shelf.quantity, 5);
    expect(shelf.visualCount, 5);
    expect(shelf.stock!.productId, 'milk');
  });

  test('quantity cannot be negative or above capacity', () {
    final shelf = ShelfUnit.empty(id: 'milk-face', slotsPerLevel: 4);
    shelf.stockProduct(milk, 8);

    expect(() => shelf.stockProduct(milk, -1), throwsArgumentError);
    expect(() => shelf.stockProduct(milk, 13), throwsArgumentError);
    expect(() => shelf.removeStock(milk, 9), throwsArgumentError);
    expect(shelf.quantity, 8);

    final tiny = ShelfUnit.empty(id: 'tiny', slotsPerLevel: 1, levelCount: 1);
    expect(() => tiny.stockProduct(milk, 2), throwsArgumentError);
  });

  test('starter shelves match the aisle plan', () {
    final shelves = starterShelves(catalog);
    expect(shelves.map((shelf) => shelf.plan.productId), [
      'milk',
      'bread',
      'rice',
      'biscuits',
      'potato-chips',
      'soap',
      'shampoo',
      'orange-juice',
      'banana',
      'onion',
      'tomato',
      'chilli',
      'oil',
      'tea',
      'eggs',
      'butter',
      'jam',
      'jaggery',
      'noodles',
      'chickpeas',
      'water',
      'mango',
    ]);
    for (final shelf in shelves) {
      expect(shelf.unit.quantity, shelf.plan.quantity);
      expect(shelf.unit.visualCount, shelf.plan.quantity);
      expect(shelf.unit.stock!.productId, shelf.plan.productId);
    }
  });

  test('faces on one gondola side leave a gap and stay on the board', () {
    final boardMin =
        SupermarketLayout.shelfCenterZ -
        SupermarketLayout.shelfLength / 2 +
        0.2;
    final boardMax =
        SupermarketLayout.shelfCenterZ +
        SupermarketLayout.shelfLength / 2 -
        0.2;
    final bySide = <String, List<StoreShelfPlan>>{};
    for (final plan in StoreShelfPlan.plans) {
      bySide
          .putIfAbsent('${plan.gondolaName}:${plan.side}', () => [])
          .add(plan);
    }
    for (final plans in bySide.values) {
      final spans = [for (final plan in plans) _span(plan)]
        ..sort((a, b) => a.$1.compareTo(b.$1));
      for (final span in spans) {
        expect(span.$1, greaterThanOrEqualTo(boardMin));
        expect(span.$2, lessThanOrEqualTo(boardMax));
      }
      for (var i = 1; i < spans.length; i++) {
        expect(spans[i].$1, greaterThan(spans[i - 1].$2));
      }
    }
  });
}

(double, double) _span(StoreShelfPlan plan) {
  final half = (plan.slotsPerLevel - 1) / 2 * ShelfMetrics.slotPitch + 0.1;
  return (plan.centerZ - half, plan.centerZ + half);
}
