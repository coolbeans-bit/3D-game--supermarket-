import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../characters/character_appearance.dart';
import '../../customers/customer.dart';
import '../../customers/customer_appearance.dart';
import '../../customers/customer_type.dart';
import '../characters/placeholder_figure.dart';
import 'blockout_geometry.dart';

/// Placeholder body and head for each shopper. The customer record owns the
/// position; these nodes only follow it.
class CustomerPresenter {
  CustomerPresenter(this.scene) {
    for (final type in CustomerType.roster) {
      final look = appearanceFor(type);
      _bodies[type.id] = _paint(look.body);
      _accents[type.id] = _paint(look.accent);
    }
    _headMaterial = _paint(appearanceFor(CustomerType.regular).head);
  }

  final Scene scene;
  final Map<String, Node> _roots = {};
  final Vector3 _position = Vector3.zero();
  final Quaternion _rotation = Quaternion.identity();
  final Vector3 _up = Vector3(0, 1, 0);
  late final PhysicallyBasedMaterial _headMaterial;
  final Map<String, PhysicallyBasedMaterial> _bodies = {};
  final Map<String, PhysicallyBasedMaterial> _accents = {};

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
    final look = appearanceFor(customer.type);
    final root = Node(name: customer.id)
      ..castsShadows = false
      ..shadowStatic = false;
    addPlaceholderFigure(
      root,
      name: customer.id,
      accentKind: look.accentKind,
      body: _bodies[customer.type.id] ?? _bodies.values.first,
      head: _headMaterial,
      accent: _accents[customer.type.id] ?? _accents.values.first,
    );
    scene.add(root);
    return root;
  }
}

PhysicallyBasedMaterial _paint(RgbColor color) {
  return BlockoutPalette.flat(color.r, color.g, color.b, 0.72);
}
