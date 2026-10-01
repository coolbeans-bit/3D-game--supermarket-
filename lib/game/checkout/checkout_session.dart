import 'package:flutter/foundation.dart';

import '../../data/catalog/product_catalog.dart';
import '../carry/carry_controller.dart';
import 'product_scanner.dart';
import 'sale_transaction.dart';

/// The open sale at the counter. Shelf stock is not changed here.
class CheckoutSession extends ChangeNotifier {
  CheckoutSession({
    required this.catalog,
    required this.carry,
    ProductScanner? scanner,
  }) : scanner = scanner ?? ProductScanner(catalog);

  final ProductCatalog catalog;
  final CarryController carry;
  final ProductScanner scanner;

  /// Called after a scan takes the item out of the player's hands.
  void Function()? onHandsCleared;

  SaleTransaction? _transaction;
  int _nextId = 0;
  int? rejectedAmount;

  SaleTransaction? get transaction => _transaction;

  CompletedSale? lastCompletedSale;

  String? notice;

  bool get isOpen {
    final state = _transaction?.state;
    return state == TransactionState.scanning ||
        state == TransactionState.awaitingPayment;
  }

  bool get showInsufficientCash => rejectedAmount != null;

  void open() {
    final current = _transaction;
    if (current != null &&
        (current.state == TransactionState.scanning ||
            current.state == TransactionState.awaitingPayment)) {
      return;
    }
    _nextId += 1;
    _transaction = SaleTransaction.scanning('sale-$_nextId');
    rejectedAmount = null;
    notice = null;
    notifyListeners();
  }

  /// Scans the carried product. Empty hands leave the sale unchanged.
  bool scanHeldItem() {
    if (!carry.isHolding) {
      return false;
    }
    final held = carry.held;
    if (held == null) {
      return false;
    }
    final product = catalog.lookup(held.id);
    if (product == null) {
      return false;
    }
    final state = _transaction?.state;
    if (state == null ||
        state == TransactionState.idle ||
        state == TransactionState.completed ||
        state == TransactionState.cancelled) {
      open();
    }
    final current = _transaction;
    if (current == null || !scanner.scanProduct(current, product)) {
      return false;
    }
    carry.release();
    onHandsCleared?.call();
    notifyListeners();
    return true;
  }

  void requestPayment() {
    final current = _transaction;
    if (current == null || !current.beginPayment()) {
      return;
    }
    rejectedAmount = null;
    notifyListeners();
  }

  bool tender(int amount) {
    final current = _transaction;
    if (current == null) {
      return false;
    }
    final accepted = current.tender(amount);
    rejectedAmount = accepted ? null : amount;
    notifyListeners();
    return accepted;
  }

  void finish() {
    final current = _transaction;
    if (current == null || !current.complete()) {
      return;
    }
    lastCompletedSale = current.toCompletedSale();
    _transaction = null;
    rejectedAmount = null;
    notice = 'Sale Complete';
    notifyListeners();
  }

  void cancel() {
    final current = _transaction;
    if (current == null || !current.cancel()) {
      return;
    }
    _transaction = null;
    rejectedAmount = null;
    notifyListeners();
  }

  void dismissNotice() {
    if (notice == null) {
      return;
    }
    notice = null;
    notifyListeners();
  }
}
