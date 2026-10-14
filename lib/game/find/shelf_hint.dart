import '../../data/catalog/product_catalog.dart';
import '../customers/shelf_stand.dart';

/// What the cashier says when the player asks where the current letter is.
///
/// One matching product is enough. Any product that starts with the letter
/// scores, so the cashier points at a real shelf instead of listing the aisle.
String whereIsLetter(ProductCatalog catalog, String letter) {
  final matches = catalog.withFirstLetter(letter);
  if (matches.isEmpty) {
    return 'मला $letter ने सुरू होणारी वस्तू सापडत नाही.';
  }
  final product = matches.first;
  final stand = standForProduct(product.id);
  final place = switch (stand?.aisle) {
    0 => 'डाव्या भिंतीजवळ',
    1 => 'पहिल्या रांगेत',
    2 => 'मधल्या रांगेत',
    3 => 'उजव्या रांगेत',
    _ => 'दुकानात',
  };
  return '$letter साठी ${product.marathiName} $place आहे.';
}
