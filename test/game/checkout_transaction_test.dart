import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/carry/carry_controller.dart';
import 'package:asmitra_game/game/carry/product_carry.dart';
import 'package:asmitra_game/game/checkout/checkout_session.dart';
import 'package:asmitra_game/game/checkout/product_scanner.dart';
import 'package:asmitra_game/game/checkout/sale_return.dart';
import 'package:asmitra_game/game/checkout/sale_transaction.dart';
import 'package:asmitra_game/game/shelves/shelf_unit.dart';
import 'package:asmitra_game/game/shelves/store_shelf_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ProductCatalog.starter;
  final scanner = ProductScanner(catalog);
  final milk = catalog.require('milk');
  final bread = catalog.require('bread');
  final biscuits = catalog.require('biscuits');

  SaleTransaction scanningSale() => SaleTransaction.scanning('sale-test');

  SaleTransaction saleOf210() {
    final sale = scanningSale();
    scanner.scanProduct(sale, milk);
    scanner.scanProduct(sale, bread);
    scanner.scanProduct(sale, bread);
    scanner.scanProduct(sale, biscuits);
    scanner.scanProduct(sale, biscuits);
    scanner.scanProduct(sale, biscuits);
    return sale;
  }

  test('an empty transaction has a total of 0', () {
    expect(scanningSale().total, 0);
    expect(scanningSale().lines, isEmpty);
  });

  test('one product scans at its selling price', () {
    final sale = scanningSale();

    expect(scanner.scanProduct(sale, milk), isTrue);

    expect(sale.lines, hasLength(1));
    expect(sale.lines.single.productId, 'milk');
    expect(sale.lines.single.quantity, 1);
    expect(sale.lines.single.unitPrice, 48);
    expect(sale.lines.single.lineTotal, 48);
    expect(sale.total, 48);
  });

  test('the same product scanned twice combines quantity', () {
    final sale = scanningSale();
    scanner.scanProduct(sale, bread);
    scanner.scanProduct(sale, bread);

    expect(sale.lines, hasLength(1));
    expect(sale.lines.single.quantity, 2);
    expect(sale.lines.single.lineTotal, 72);
  });

  test('different products stay on separate lines', () {
    final sale = scanningSale();
    scanner.scanProduct(sale, milk);
    scanner.scanProduct(sale, bread);

    expect(sale.lines.map((line) => line.productId), ['milk', 'bread']);
  });

  test('line total is unit price times quantity', () {
    final sale = scanningSale();
    scanner.scanBarcode(sale, biscuits.barcodeId);
    scanner.scanBarcode(sale, biscuits.barcodeId);
    scanner.scanBarcode(sale, biscuits.barcodeId);

    expect(sale.lines.single.lineTotal, 30 * 3);
    expect(sale.lines.single.lineTotal, 90);
  });

  test('the total is the sum of the line totals', () {
    final sale = saleOf210();

    expect(sale.total, 48 + 72 + 90);
    expect(sale.total, 210);
  });

  test('insufficient cash does not complete the sale', () {
    final sale = saleOf210();
    expect(sale.beginPayment(), isTrue);

    expect(sale.tender(200), isFalse);

    expect(sale.cashReceived, isNull);
    expect(sale.isCompleted, isFalse);
    expect(sale.state, TransactionState.awaitingPayment);
  });

  test('sufficient cash calculates the exact change', () {
    final sale = saleOf210();
    sale.beginPayment();

    expect(sale.tender(500), isTrue);

    expect(sale.change, 500 - 210);
    expect(sale.change, 290);
  });

  test('successful payment completes the transaction', () {
    final sale = saleOf210();
    sale.beginPayment();
    sale.tender(500);

    expect(sale.complete(), isTrue);

    final finished = sale.toCompletedSale();
    expect(sale.isCompleted, isTrue);
    expect(finished!.total, 210);
    expect(finished.cashReceived, 500);
    expect(finished.change, 290);
  });

  test('a cancelled transaction is not completed', () {
    final sale = scanningSale();
    scanner.scanProduct(sale, milk);

    expect(sale.cancel(), isTrue);

    expect(sale.state, TransactionState.cancelled);
    expect(sale.isCompleted, isFalse);
    expect(sale.complete(), isFalse);
  });

  test('an invalid barcode is rejected', () {
    final sale = scanningSale();

    expect(scanner.scanBarcode(sale, 'NOT-A-CODE'), isFalse);

    expect(sale.total, 0);
    expect(sale.lines, isEmpty);
  });

  test('scanning with empty hands does nothing', () {
    final carry = CarryController();
    final session = CheckoutSession(catalog: catalog, carry: carry);
    session.open();

    expect(session.scanHeldItem(), isFalse);

    expect(session.transaction!.total, 0);
    expect(carry.isHolding, isFalse);
  });

  test('a completed transaction rejects more products', () {
    final sale = scanningSale();
    scanner.scanProduct(sale, milk);
    sale.beginPayment();
    sale.tender(100);
    sale.complete();

    expect(sale.addUnit(bread), isFalse);
    expect(scanner.scanProduct(sale, bread), isFalse);

    expect(sale.lines, hasLength(1));
    expect(sale.total, 48);
  });

  test('money stays an exact integer', () {
    final sale = saleOf210();
    sale.beginPayment();
    sale.tender(500);
    sale.complete();

    expect(sale.total, 210);
    expect(sale.change, 290);
    expect(
      sale.lines.map((line) => line.lineTotal).reduce((a, b) => a + b),
      210,
    );
  });

  test('scanning a carried product does not change shelf stock again', () {
    final shelf = ShelfUnit.empty(
      id: 'milk',
      slotsPerLevel: 4,
      shelfType: milk.shelfType,
    )..stockProduct(milk, 8);
    final carry = CarryController();
    final hands = ProductCarry(carry: carry, catalog: catalog);
    final session = CheckoutSession(catalog: catalog, carry: carry);
    hands.pickup(shelf, shelf.slots.first);

    expect(session.scanHeldItem(), isTrue);

    expect(shelf.quantity, 7);
    expect(session.transaction!.total, 48);
    expect(carry.isHolding, isFalse);
  });

  test('cancel gives scanned products back in scan order', () {
    final carry = CarryController();
    final session = CheckoutSession(catalog: catalog, carry: carry);
    final returned = <String>[];
    session.onSaleCancelled = returned.addAll;
    carry.tryHold(const CarriedItem(id: 'milk', label: 'Fresh Milk'));
    session.scanHeldItem();
    carry.tryHold(const CarriedItem(id: 'bread', label: 'Bread'));
    session.scanHeldItem();

    session.cancel();

    expect(returned, ['milk', 'bread']);
    expect(session.isOpen, isFalse);
    expect(session.lastCompletedSale, isNull);
    expect(carry.isHolding, isFalse);
  });

  test('a completed sale does not give the products back', () {
    final carry = CarryController();
    final session = CheckoutSession(catalog: catalog, carry: carry);
    final returned = <String>[];
    session.onSaleCancelled = returned.addAll;
    carry.tryHold(const CarriedItem(id: 'milk', label: 'Fresh Milk'));
    session.scanHeldItem();
    session.requestPayment();
    session.tender(100);
    session.finish();

    expect(returned, isEmpty);
    expect(session.lastCompletedSale!.total, 48);
  });

  test('returned products go back on their own shelf', () {
    final shelves = starterShelves(catalog);
    final milkShelf = shelves.firstWhere(
      (shelf) => shelf.plan.productId == 'milk',
    );
    final before = milkShelf.unit.quantity;
    milkShelf.unit.removeStock(milk, 1);

    final result = returnScannedProducts(
      productIds: const ['milk', 'missing'],
      catalog: catalog,
      shelves: shelves,
    );

    expect(milkShelf.unit.quantity, before);
    expect(result.placed.single.shelfId, milkShelf.plan.id);
    expect(result.unplacedIds, ['missing']);
  });

  test('a full shelf leaves the product unplaced', () {
    final shelf = ShelfUnit.empty(
      id: 'milk-face',
      slotsPerLevel: 1,
      levelCount: 1,
      shelfType: milk.shelfType,
    )..stockProduct(milk, 1);
    final stocked = StockedShelf(
      const StoreShelfPlan(
        id: 'milk-face',
        gondolaName: 'gondola-a',
        side: 1,
        centerZ: 0,
        slotsPerLevel: 1,
        productId: 'milk',
        quantity: 1,
      ),
      shelf,
    );

    final result = returnScannedProducts(
      productIds: const ['milk'],
      catalog: catalog,
      shelves: [stocked],
    );

    expect(result.placed, isEmpty);
    expect(result.unplacedIds, ['milk']);
    expect(shelf.quantity, 1);
  });
}
