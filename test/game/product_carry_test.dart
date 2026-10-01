import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/data/models/product_definition.dart';
import 'package:asmitra_game/data/models/product_stock.dart';
import 'package:asmitra_game/game/carry/carry_controller.dart';
import 'package:asmitra_game/game/carry/product_carry.dart';
import 'package:asmitra_game/game/shelves/shelf_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ProductCatalog.starter;
  final milk = catalog.require('milk');
  final bread = catalog.require('bread');

  ShelfUnit shelfFor(
    ProductDefinition product, {
    int slots = 4,
    int levels = 3,
  }) {
    return ShelfUnit.empty(
      id: product.id,
      slotsPerLevel: slots,
      levelCount: levels,
      shelfType: product.shelfType,
    );
  }

  ProductCarry start() {
    return ProductCarry(carry: CarryController(), catalog: catalog);
  }

  test('picking up one product decreases shelf quantity by one', () {
    final shelf = shelfFor(milk)..stockProduct(milk, 8);
    final slot = shelf.slots.first;
    final actions = start();

    expect(actions.pickup(shelf, slot), isTrue);

    expect(shelf.quantity, 7);
    expect(shelf.visualCount, 7);
    expect(slot.isEmpty, isTrue);
    expect(actions.carry.held!.quantity, 1);
  });

  test('picking up from an empty shelf is rejected', () {
    final shelf = shelfFor(milk);
    final actions = start();

    expect(actions.pickup(shelf, shelf.slots.first), isFalse);

    expect(shelf.quantity, 0);
    expect(actions.carry.isHolding, isFalse);
  });

  test('player cannot hold two products', () {
    final milkShelf = shelfFor(milk)..stockProduct(milk, 8);
    final breadShelf = shelfFor(bread)..stockProduct(bread, 6);
    final actions = start();

    expect(actions.pickup(milkShelf, milkShelf.slots.first), isTrue);
    expect(actions.pickup(breadShelf, breadShelf.slots.first), isFalse);

    expect(actions.carry.state, CarryState.holding);
    expect(actions.carry.held!.id, 'milk');
    expect(breadShelf.quantity, 6);
    expect(milkShelf.quantity, 7);
  });

  test('a compatible shelf accepts the held product', () {
    final source = shelfFor(milk)..stockProduct(milk, 8);
    final empty = shelfFor(milk, slots: 2, levels: 1);
    final actions = start();
    actions.pickup(source, source.slots.first);

    expect(empty.canPlace(milk), isTrue);
    expect(actions.place(empty), isNotNull);

    expect(empty.quantity, 1);
    expect(empty.stock!.productId, 'milk');
    expect(actions.carry.state, CarryState.empty);
  });

  test('an incompatible shelf rejects the held product', () {
    final milkShelf = shelfFor(milk)..stockProduct(milk, 8);
    final breadShelf = shelfFor(bread)..stockProduct(bread, 6);
    final actions = start();
    actions.pickup(milkShelf, milkShelf.slots.first);

    expect(actions.canPlaceOn(breadShelf), isFalse);
    expect(actions.place(breadShelf), isNull);

    expect(breadShelf.quantity, 6);
    expect(breadShelf.stock!.productId, 'bread');
    expect(actions.carry.held!.id, 'milk');
  });

  test('a full shelf rejects placement', () {
    final source = shelfFor(bread)..stockProduct(bread, 4);
    final full = shelfFor(bread, slots: 2, levels: 1)..stockProduct(bread, 2);
    final actions = start();
    actions.pickup(source, source.slots.first);

    expect(actions.place(full), isNull);

    expect(full.quantity, 2);
    expect(actions.carry.isHolding, isTrue);
  });

  test('successful placement increases shelf quantity by one', () {
    final shelf = shelfFor(milk)..stockProduct(milk, 8);
    final actions = start();
    actions.pickup(shelf, shelf.slots.first);

    expect(actions.place(shelf), isNotNull);

    expect(shelf.quantity, 8);
  });

  test('pickup followed by placement restores the original quantity', () {
    final shelf = shelfFor(milk)..stockProduct(milk, 8);
    final actions = start();

    expect(actions.pickup(shelf, shelf.slots.first), isTrue);
    expect(shelf.quantity, 7);
    expect(actions.place(shelf), isNotNull);

    expect(shelf.quantity, 8);
    expect(shelf.visualCount, 8);
    expect(actions.carry.held, isNull);
  });

  test('product id stays the same during pickup', () {
    final shelf = shelfFor(milk)..stockProduct(milk, 8);
    final actions = start();
    actions.pickup(shelf, shelf.slots.first);

    expect(actions.carry.held!.id, milk.id);
    expect(actions.heldDefinition, same(milk));
    expect(shelf.stock!.productId, milk.id);
  });

  test('invalid product ids are left untouched', () {
    final shelf = shelfFor(bread)..stockProduct(bread, 2);
    shelf.slots.first.productId = 'not-a-product';
    shelf.stock = const ProductStock(productId: 'not-a-product', quantity: 2);
    final actions = start();

    expect(actions.pickup(shelf, shelf.slots.first), isFalse);
    expect(shelf.quantity, 2);
    expect(actions.carry.isHolding, isFalse);

    actions.carry.tryHold(
      const CarriedItem(id: 'not-a-product', label: 'Missing'),
    );
    expect(actions.place(shelf), isNull);
    expect(shelf.quantity, 2);
    expect(shelf.stock!.productId, 'not-a-product');
    expect(actions.carry.held!.id, 'not-a-product');
  });
}
