import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../../data/models/product_definition.dart';
import '../../shelves/store_shelf_plan.dart';
import '../supermarket/blockout_geometry.dart';

/// One factory for every placeholder product mesh. Materials are shared by id.
class ProductVisualFactory {
  final Map<String, PhysicallyBasedMaterial> _materials = {};

  Node place(
    Scene scene, {
    required ProductDefinition product,
    required Vector3 position,
    required String name,
  }) {
    final material = _materials.putIfAbsent(product.id, () {
      return BlockoutPalette.flat(
        product.color.red,
        product.color.green,
        product.color.blue,
        0.55,
      );
    });
    final height = productHeight(product.shape);
    final node = switch (product.shape) {
      ProductShape.bottle => Node(
        name: name,
        mesh: Mesh(
          CylinderGeometry(
            bottomRadius: 0.05,
            topRadius: 0.05,
            height: height,
            radialSegments: 8,
          ),
          material,
        ),
      ),
      ProductShape.box => _box(name, material, height, 0.12, 0.15),
      ProductShape.carton => _box(name, material, height, 0.1, 0.12),
      ProductShape.bag => _box(name, material, height, 0.07, 0.16),
    };
    node
      ..position = position
      ..castsShadows = false
      ..shadowStatic = true;
    scene.add(node);
    return node;
  }
}

Node _box(
  String name,
  PhysicallyBasedMaterial material,
  double height,
  double depth,
  double length,
) {
  return Node(
    name: name,
    mesh: Mesh(CuboidGeometry(Vector3(depth, height, length)), material),
  );
}
