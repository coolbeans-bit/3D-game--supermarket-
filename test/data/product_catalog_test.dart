import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ProductCatalog.starter;

  test('the catalog contains the starter products', () {
    expect(catalog.products.map((product) => product.name), [
      'Fresh Milk',
      'Bread',
      'Rice',
      'Orange Juice',
      'Biscuits',
      'Potato Chips',
      'Soap',
      'Shampoo',
    ]);
  });

  test('product ids are unique', () {
    final ids = catalog.products.map((product) => product.id).toSet();
    expect(ids, hasLength(catalog.products.length));
    expect(
      () => ProductCatalog([catalog.require('milk'), catalog.require('milk')]),
      throwsArgumentError,
    );
  });

  test('purchase and selling prices are valid whole units', () {
    for (final product in catalog.products) {
      expect(product.purchasePrice, greaterThan(0));
      expect(product.sellingPrice, greaterThanOrEqualTo(product.purchasePrice));
    }
    expect(catalog.require('milk').sellingPrice, 48);
    expect(catalog.require('milk').purchasePrice, 35);
    expect(catalog.require('milk').barcodeId, 'ASM-1001');
    final barcodes = catalog.products
        .map((product) => product.barcodeId)
        .toSet();
    expect(barcodes, hasLength(catalog.products.length));
  });
}
