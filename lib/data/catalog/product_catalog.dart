import '../models/product_definition.dart';

/// The store's product definitions. Stock counts are not kept here.
class ProductCatalog {
  ProductCatalog(List<ProductDefinition> products)
    : _byId = {for (final product in products) product.id: product},
      _byBarcode = {
        for (final product in products) product.barcodeId: product,
      } {
    if (_byId.length != products.length) {
      throw ArgumentError('product ids must be unique');
    }
    if (_byBarcode.length != products.length) {
      throw ArgumentError('barcode ids must be unique');
    }
  }

  final Map<String, ProductDefinition> _byId;
  final Map<String, ProductDefinition> _byBarcode;

  List<ProductDefinition> get products => List.unmodifiable(_byId.values);

  ProductDefinition? lookup(String id) => _byId[id];

  ProductDefinition? lookupBarcode(String barcodeId) => _byBarcode[barcodeId];

  ProductDefinition require(String id) {
    return _byId[id] ?? (throw ArgumentError('unknown product $id'));
  }

  /// Original placeholder goods. Prices are whole currency units.
  static final starter = ProductCatalog([
    ProductDefinition(
      id: 'milk',
      name: 'Fresh Milk',
      barcodeId: 'ASM-1001',
      category: ProductCategory.dairy,
      purchasePrice: 35,
      sellingPrice: 48,
      shelfType: ShelfType.refrigerated,
      maxShelfQuantity: 12,
      shape: ProductShape.bottle,
      color: const ProductColor(0.93, 0.95, 0.97),
    ),
    ProductDefinition(
      id: 'bread',
      name: 'Bread',
      barcodeId: 'ASM-1002',
      category: ProductCategory.bakery,
      purchasePrice: 25,
      sellingPrice: 36,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 10,
      shape: ProductShape.box,
      color: const ProductColor(0.76, 0.55, 0.32),
    ),
    ProductDefinition(
      id: 'rice',
      name: 'Rice',
      barcodeId: 'ASM-1003',
      category: ProductCategory.grocery,
      purchasePrice: 50,
      sellingPrice: 68,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 8,
      shape: ProductShape.bag,
      color: const ProductColor(0.9, 0.88, 0.8),
    ),
    ProductDefinition(
      id: 'orange-juice',
      name: 'Orange Juice',
      barcodeId: 'ASM-1004',
      category: ProductCategory.beverage,
      purchasePrice: 40,
      sellingPrice: 55,
      shelfType: ShelfType.refrigerated,
      maxShelfQuantity: 10,
      shape: ProductShape.carton,
      color: const ProductColor(0.93, 0.55, 0.18),
    ),
    ProductDefinition(
      id: 'biscuits',
      name: 'Biscuits',
      barcodeId: 'ASM-1005',
      category: ProductCategory.grocery,
      purchasePrice: 20,
      sellingPrice: 30,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 12,
      shape: ProductShape.box,
      color: const ProductColor(0.82, 0.62, 0.28),
    ),
    ProductDefinition(
      id: 'potato-chips',
      name: 'Potato Chips',
      barcodeId: 'ASM-1006',
      category: ProductCategory.grocery,
      purchasePrice: 18,
      sellingPrice: 28,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 12,
      shape: ProductShape.bag,
      color: const ProductColor(0.9, 0.78, 0.22),
    ),
    ProductDefinition(
      id: 'soap',
      name: 'Soap',
      barcodeId: 'ASM-1007',
      category: ProductCategory.household,
      purchasePrice: 22,
      sellingPrice: 32,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 12,
      shape: ProductShape.box,
      color: const ProductColor(0.45, 0.7, 0.62),
    ),
    ProductDefinition(
      id: 'shampoo',
      name: 'Shampoo',
      barcodeId: 'ASM-1008',
      category: ProductCategory.household,
      purchasePrice: 45,
      sellingPrice: 62,
      shelfType: ShelfType.dry,
      maxShelfQuantity: 10,
      shape: ProductShape.bottle,
      color: const ProductColor(0.35, 0.62, 0.78),
    ),
  ]);
}
