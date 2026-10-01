import '../../data/catalog/product_catalog.dart';
import '../../data/models/product_definition.dart';
import 'sale_transaction.dart';

/// Turns a game barcode into a catalog product and a transaction line.
///
/// It does not read the phone camera and it does not build widgets.
class ProductScanner {
  ProductScanner(this.catalog);

  final ProductCatalog catalog;

  ProductDefinition? identify(String barcodeId) {
    return catalog.lookupBarcode(barcodeId);
  }

  /// Checks the product's barcode, looks it up, then adds one unit.
  bool scanProduct(SaleTransaction transaction, ProductDefinition product) {
    final match = identify(product.barcodeId);
    if (match == null || match.id != product.id) {
      return false;
    }
    return transaction.addUnit(match);
  }

  bool scanBarcode(SaleTransaction transaction, String barcodeId) {
    final match = identify(barcodeId);
    if (match == null) {
      return false;
    }
    return transaction.addUnit(match);
  }
}
