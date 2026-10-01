/// How many of a catalog product are on hand.
///
/// Name, price, and category stay on [ProductDefinition]. This entry only
/// points at that definition.
class ProductStock {
  const ProductStock({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}
