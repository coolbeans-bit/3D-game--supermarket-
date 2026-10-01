/// How a placeholder product is drawn. Sizes live with the visual factory.
enum ProductShape { bottle, box, carton, bag }

/// Where a product is meant to be stored. The blockout still uses gondolas.
enum ShelfType { dry, refrigerated }

enum ProductCategory { dairy, bakery, grocery, beverage, household }

/// RGB color in the 0–1 range for a flat placeholder material.
class ProductColor {
  const ProductColor(this.red, this.green, this.blue);

  final double red;
  final double green;
  final double blue;
}

/// What a product is. Prices are whole currency units, not a formatted symbol.
class ProductDefinition {
  ProductDefinition({
    required this.id,
    required this.name,
    required this.barcodeId,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.shelfType,
    required this.maxShelfQuantity,
    required this.shape,
    required this.color,
  }) {
    if (id.isEmpty || name.isEmpty || barcodeId.isEmpty) {
      throw ArgumentError('product id, name, and barcode are required');
    }
    if (purchasePrice <= 0 || sellingPrice <= 0) {
      throw ArgumentError('prices must be positive whole currency units');
    }
    if (sellingPrice < purchasePrice) {
      throw ArgumentError('selling price cannot be below purchase price');
    }
    if (maxShelfQuantity <= 0) {
      throw ArgumentError('max shelf quantity must be positive');
    }
  }

  final String id;
  final String name;

  /// Game barcode. This is not a phone-camera scan.
  final String barcodeId;

  final ProductCategory category;
  final int purchasePrice;
  final int sellingPrice;
  final ShelfType shelfType;
  final int maxShelfQuantity;
  final ProductShape shape;
  final ProductColor color;
}
