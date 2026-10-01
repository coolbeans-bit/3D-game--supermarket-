import 'package:vector_math/vector_math.dart';

/// Where a carried mesh sits relative to the first-person camera.
///
/// [forwardMeters] is in front of the eye. [rightMeters] shifts the mesh
/// across the view; a negative value sits on the right of the reticle.
/// [belowMeters] drops it under the reticle. [visualScale] only affects
/// the carried mesh.
class HeldItemAnchor {
  const HeldItemAnchor({
    this.forwardMeters = 0.52,
    this.rightMeters = -0.16,
    this.belowMeters = 0.2,
    this.visualScale = 1.25,
  });

  final double forwardMeters;
  final double rightMeters;
  final double belowMeters;
  final double visualScale;

  Vector3 worldPosition({required Vector3 eye, required Vector3 target}) {
    final forward = target - eye;
    final length = forward.length;
    if (length > 1e-8) {
      forward.scale(1 / length);
    }
    final right = forward.cross(Vector3(0, 1, 0));
    if (right.length2 < 1e-8) {
      right.setValues(1, 0, 0);
    } else {
      right.normalize();
    }
    final up = right.cross(forward)..normalize();
    return eye +
        (forward * forwardMeters) +
        (right * rightMeters) -
        (up * belowMeters);
  }
}
