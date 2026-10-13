import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Floors, exterior shell, porch, and ceiling for the blockout.
void addSupermarketRoom(Scene scene, BlockoutPalette palette) {
  addFloor(
    scene,
    name: 'shop-floor',
    width: SupermarketLayout.shopMaxX - SupermarketLayout.shopMinX,
    depth: SupermarketLayout.shopMaxZ - SupermarketLayout.storageMinZ,
    center: Vector3(0, 0, -2.5),
    material: palette.floor,
  );
  addFloor(
    scene,
    name: 'porch-floor',
    width: SupermarketLayout.porchHalfWidth * 2,
    depth: 4.7,
    center: Vector3(0, 0, 9.7),
    material: palette.porch,
  );
  addBox(
    scene,
    name: 'storage-floor',
    center: Vector3(-2.3, 0.012, -9.55),
    size: Vector3(7.4, 0.02, 4.7),
    material: palette.storageFloor,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'staff-floor',
    center: Vector3(3.75, 0.012, -9.55),
    size: Vector3(4.3, 0.02, 4.7),
    material: palette.staffFloor,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'entrance-threshold',
    center: Vector3(0, 0.015, 7.2),
    size: Vector3(2.3, 0.02, 0.4),
    material: palette.threshold,
    castsShadows: false,
  );

  var index = 0;
  for (final span in SupermarketLayout.solids) {
    if (span.role == SpanRole.wall) {
      addSpan(scene, span, name: 'wall-$index', material: palette.wall);
      index++;
    } else if (span.role == SpanRole.curb) {
      addSpan(scene, span, name: 'curb-$index', material: palette.curb);
      index++;
    }
  }

  addBox(
    scene,
    name: 'entrance-header',
    center: Vector3(0, 2.6, 7.11),
    size: Vector3(2.4, 0.8, SupermarketLayout.wallThickness),
    material: palette.frame,
  );
  addBox(
    scene,
    name: 'entrance-canopy',
    center: Vector3(0, 2.82, 9.6),
    size: Vector3(6.4, 0.08, 4.2),
    material: palette.canopy,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'entrance-canopy-band',
    center: Vector3(0, 2.74, 9.6),
    size: Vector3(6.4, 0.05, 0.42),
    material: palette.canopyBand,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'shop-ceiling',
    center: Vector3(0, 3.06, 0),
    size: Vector3(12.5, 0.08, 14.4),
    material: palette.ceiling,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'storage-ceiling',
    center: Vector3(0, 3.06, -9.55),
    size: Vector3(12.5, 0.08, 5.3),
    material: palette.ceiling,
    castsShadows: false,
  );
}
