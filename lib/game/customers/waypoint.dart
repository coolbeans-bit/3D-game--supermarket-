import 'package:vector_math/vector_math.dart';

/// A point on the floor a customer can walk toward.
class Waypoint {
  Waypoint({
    required this.id,
    required double x,
    required double z,
    this.nextId,
    this.pause = 0,
    this.faceYaw,
    this.reach = false,
    this.productId,
  }) : position = Vector3(x, 0, z);

  final String id;
  final Vector3 position;

  /// Id of the following point, when this waypoint is part of a chain.
  final String? nextId;

  /// Seconds to stand still after arriving. Zero means walk straight on.
  final double pause;

  /// Facing used while [pause] is running. Null keeps the walking facing.
  final double? faceYaw;

  /// Play the reach clip during [pause], the way a shopper takes a product.
  final bool reach;

  /// Catalog id put into the shopper's basket when the pause ends.
  final String? productId;
}
