import '../../data/models/product_definition.dart';

/// Where a checkout sale is in its life.
enum TransactionState { idle, scanning, awaitingPayment, completed, cancelled }

/// One product row. Money is a whole number of currency units.
class SaleLine {
  const SaleLine({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final int quantity;
  final int unitPrice;

  int get lineTotal => unitPrice * quantity;

  SaleLine addOne() {
    return SaleLine(
      productId: productId,
      quantity: quantity + 1,
      unitPrice: unitPrice,
    );
  }
}

/// A finished cash sale. Later economy code can read this without the UI.
class CompletedSale {
  const CompletedSale({
    required this.id,
    required this.lines,
    required this.total,
    required this.cashReceived,
    required this.change,
  });

  final String id;
  final List<SaleLine> lines;
  final int total;
  final int cashReceived;
  final int change;
}

/// Price math for one sale. It does not know about shelves, widgets, or cash drawers.
class SaleTransaction {
  SaleTransaction.scanning(this.id) : state = TransactionState.scanning;

  final String id;
  TransactionState state;
  final List<SaleLine> _lines = [];
  int? cashReceived;

  List<SaleLine> get lines => List.unmodifiable(_lines);

  int get total => _lines.fold(0, (sum, line) => sum + line.lineTotal);

  int? get change {
    final paid = cashReceived;
    if (paid == null) {
      return null;
    }
    return paid - total;
  }

  bool get isPaid => cashReceived != null && cashReceived! >= total;

  bool get isCompleted => state == TransactionState.completed;

  /// Adds one unit at the product's selling price. Same product ids share a line.
  bool addUnit(ProductDefinition product) {
    if (state != TransactionState.scanning) {
      return false;
    }
    final index = _lines.indexWhere((line) => line.productId == product.id);
    if (index >= 0) {
      _lines[index] = _lines[index].addOne();
    } else {
      _lines.add(
        SaleLine(
          productId: product.id,
          quantity: 1,
          unitPrice: product.sellingPrice,
        ),
      );
    }
    return true;
  }

  bool beginPayment() {
    if (state != TransactionState.scanning || total <= 0) {
      return false;
    }
    state = TransactionState.awaitingPayment;
    cashReceived = null;
    return true;
  }

  /// Accepts [amount] only when it covers the total. Does not finish the sale.
  bool tender(int amount) {
    if (state != TransactionState.awaitingPayment || amount < 0) {
      return false;
    }
    if (amount < total) {
      cashReceived = null;
      return false;
    }
    cashReceived = amount;
    return true;
  }

  bool complete() {
    if (state != TransactionState.awaitingPayment || !isPaid) {
      return false;
    }
    state = TransactionState.completed;
    return true;
  }

  bool cancel() {
    if (state != TransactionState.scanning &&
        state != TransactionState.awaitingPayment) {
      return false;
    }
    state = TransactionState.cancelled;
    return true;
  }

  CompletedSale? toCompletedSale() {
    final paid = cashReceived;
    final changeDue = change;
    if (!isCompleted || paid == null || changeDue == null) {
      return null;
    }
    return CompletedSale(
      id: id,
      lines: List<SaleLine>.of(lines),
      total: total,
      cashReceived: paid,
      change: changeDue,
    );
  }
}
