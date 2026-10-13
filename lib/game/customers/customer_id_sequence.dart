/// Issues `customer-001`, `customer-002`, and so on. Ids are never reused.
class CustomerIdSequence {
  int _nextNumber = 0;
  final Set<String> _issuedIds = {};

  ({String id, int number}) next() {
    _nextNumber += 1;
    final id = 'customer-${_nextNumber.toString().padLeft(3, '0')}';
    reserve(id);
    return (id: id, number: _nextNumber);
  }

  /// Keeps [id] from being issued. Throws if it was already used.
  void reserve(String id) {
    if (!_issuedIds.add(id)) {
      throw StateError('duplicate customer id $id');
    }
  }
}
