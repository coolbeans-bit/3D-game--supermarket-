/// How a shopper moves. Types differ by data, not by subclass.
class CustomerType {
  CustomerType({
    required this.id,
    required this.label,
    required this.speed,
    required this.patience,
  }) {
    if (id.isEmpty || label.isEmpty) {
      throw ArgumentError('a customer type needs an id and a label');
    }
    if (speed <= 0 || patience <= 0) {
      throw ArgumentError('speed and patience must be positive');
    }
  }

  final String id;
  final String label;

  /// Meters per second.
  final double speed;

  /// Seconds spent standing at the shopping waypoint.
  final double patience;

  static final regular = CustomerType(
    id: 'regular',
    label: 'Regular',
    speed: 0.95,
    patience: 4,
  );

  static final quickShopper = CustomerType(
    id: 'quick-shopper',
    label: 'Quick Shopper',
    speed: 1.35,
    patience: 2,
  );

  static final slowShopper = CustomerType(
    id: 'slow-shopper',
    label: 'Slow Shopper',
    speed: 0.62,
    patience: 6.5,
  );

  static final roster = <CustomerType>[regular, quickShopper, slowShopper];
}
