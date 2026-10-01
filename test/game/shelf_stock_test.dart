import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/shelves/shelf_unit.dart';
import 'package:asmitra_game/game/shelves/store_shelf_plan.dart';
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
    ]);
    for (final shelf in shelves) {
      expect(shelf.unit.quantity, shelf.plan.quantity);
      expect(shelf.unit.visualCount, shelf.plan.quantity);
      expect(shelf.unit.stock!.productId, shelf.plan.productId);
    }
  });
}
