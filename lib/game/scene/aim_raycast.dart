import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Casts a ray from the camera through render geometry.
///
/// [maxDistance] is supplied by the caller. This function does not choose the
/// interaction range.
SceneRaycastHit? castAimRay({
  required Scene scene,
  required Vector3 origin,
  required Vector3 direction,
  required double maxDistance,
}) {
  return scene.raycast(
    Ray.originDirection(origin, direction),
    maxDistance: maxDistance,
  );
}
