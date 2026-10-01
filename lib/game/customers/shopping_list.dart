import 'dart:math';

import '../../data/catalog/product_catalog.dart';

/// One intended purchase. The catalog still owns the product definition.
class ShoppingListEntry {
  const ShoppingListEntry({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}

/// How many lines and units a generated list may contain.
class ShoppingListLimits {
  const ShoppingListLimits({
    this.minLines = 1,
    this.maxLines = 3,
    this.minQuantity = 1,
    this.maxQuantity = 2,
  });

  final int minLines;
  final int maxLines;
  final int minQuantity;
  final int maxQuantity;
}

/// Builds a shopping list from the live catalog.
///
/// The same [random] seed produces the same list. Customers do not remove
/// shelf stock; the list is only what they intend to buy later.
List<ShoppingListEntry> generateShoppingList({
  required ProductCatalog catalog,
  required Random random,
  ShoppingListLimits limits = const ShoppingListLimits(),
}) {
  final products = catalog.products;
  if (products.isEmpty || limits.maxLines <= 0) {
    return const [];
  }
  final minLines = limits.minLines.clamp(0, products.length).toInt();
  final maxLines = limits.maxLines.clamp(minLines, products.length).toInt();
  final lineCount = minLines + random.nextInt(maxLines - minLines + 1);
  final shuffled = [...products]..shuffle(random);
  final minQuantity = limits.minQuantity < 1 ? 1 : limits.minQuantity;
  final maxQuantity = limits.maxQuantity < minQuantity
      ? minQuantity
      : limits.maxQuantity;
  return [
    for (final product in shuffled.take(lineCount))
      ShoppingListEntry(
        productId: product.id,
        quantity: minQuantity + random.nextInt(maxQuantity - minQuantity + 1),
      ),
  ];
}
