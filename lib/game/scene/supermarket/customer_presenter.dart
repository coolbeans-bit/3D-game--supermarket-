import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../customers/customer.dart';
import '../../customers/customer_type.dart';
import 'blockout_geometry.dart';

/// Placeholder body and head for each shopper. The customer record owns the
/// position; these nodes only follow it.
class CustomerPresenter {
  CustomerPresenter(this.scene) {
    _headMaterial = BlockoutPalette.flat(0.86, 0.74, 0.62, 0.7);
    _bodyMaterials = {
      CustomerType.regular.id: BlockoutPalette.flat(0.62, 0.42, 0.28, 0.72),
      CustomerType.quickShopper.id: BlockoutPalette.flat(0.18, 0.48, 0.55, 0.7),
      CustomerType.slowShopper.id: BlockoutPalette.flat(0.42, 0.36, 0.52, 0.74),
    };
  }

  final Scene scene;
  final Map<String, Node> _roots = {};
  final Vector3 _position = Vector3.zero();
  final Quaternion _rotation = Quaternion.identity();
  final Vector3 _up = Vector3(0, 1, 0);
  late final PhysicallyBasedMaterial _headMaterial;
  late final Map<String, PhysicallyBasedMaterial> _bodyMaterials;

  void sync(Iterable<Customer> customers) {
    final live = <String>{};
    for (final customer in customers) {
      live.add(customer.id);
      final root = _roots.putIfAbsent(customer.id, () => _create(customer));
      _position.setValues(customer.position.x, 0, customer.position.z);
      root.position = _position;
      _rotation.setAxisAngle(_up, customer.yaw);
      root.rotation = _rotation;
    }
    final gone = [
      for (final id in _roots.keys)
        if (!live.contains(id)) id,
    ];
    for (final id in gone) {
      final root = _roots.remove(id);
      if (root != null) {
        scene.remove(root);
      }
    }
  }

  Node _create(Customer customer) {
    final bodyMaterial =
        _bodyMaterials[customer.type.id] ?? _bodyMaterials.values.first;
    final body =
        Node(
            name: '${customer.id}-body',
            mesh: Mesh(
              CylinderGeometry(
                bottomRadius: 0.17,
                topRadius: 0.17,
                height: 1.1,
                radialSegments: 10,
              ),
              bodyMaterial,
            ),
          )
          ..position = Vector3(0, 0.55, 0)
          ..castsShadows = false
          ..shadowStatic = false;
    final head =
        Node(
            name: '${customer.id}-head',
            mesh: Mesh(
              CylinderGeometry(
                bottomRadius: 0.12,
                topRadius: 0.12,
                height: 0.26,
                radialSegments: 10,
              ),
              _headMaterial,
            ),
          )
          ..position = Vector3(0, 1.23, 0)
          ..castsShadows = false
          ..shadowStatic = false;
    final root = Node(name: customer.id)
      ..castsShadows = false
      ..shadowStatic = false;
    root.add(body);
    root.add(head);
    scene.add(root);
    return root;
  }
}
