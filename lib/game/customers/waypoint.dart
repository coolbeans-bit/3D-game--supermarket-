import 'package:vector_math/vector_math.dart';

/// A point on the floor a customer can walk toward.
class Waypoint {
  Waypoint({
    required this.id,
    required double x,
    required double z,
    this.nextId,
  }) : position = Vector3(x, 0, z);

  final String id;
  final Vector3 position;

  /// Id of the following point, when this waypoint is part of a chain.
  final String? nextId;
}
