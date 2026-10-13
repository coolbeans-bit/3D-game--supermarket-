import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../checkpoints/std1_run.dart';
import '../../interaction/interaction_system.dart';
import '../../literacy/literacy_session.dart';
import '../../literacy/market_words.dart';
import 'blockout_geometry.dart';

/// Learning goods and shop boards. They are lesson targets, not shelf stock.
void addMarketFruits(
  Scene scene,
  InteractionSystem interactions,
  LiteracySession session, {
  Std1Run? checkpoint,
}) {
  const goodsSpots = <(String, double, double)>[
    ('word-apple', -5.55, 5.7),
    ('word-carrot', -4.75, 5.7),
    ('word-banana', -3.95, 5.7),
    ('word-mango', -3.15, 5.7),
    ('word-tomato', -2.35, 5.7),
    ('word-milk', -1.55, 5.95),
    ('word-soap', -1.05, 6.05),
  ];
  for (final spot in goodsSpots) {
    final goods = goodsById(spot.$1);
    if (goods == null) {
      continue;
    }
    final parts = _goodsShape(goods.id);
    final root = Node(name: goods.id)
      ..position = Vector3(spot.$2, 0.9, spot.$3);
    root.castsShadows = false;
    root.shadowStatic = false;
    for (final part in parts) {
      part.castsShadows = false;
      part.shadowStatic = false;
      root.add(part);
    }
    scene.add(root);
    final target = LearningTarget(
      id: goods.id,
      session: session,
      action: 'टोपलीत टाका',
      onInteract: () {
        session.collect(goods.id);
        checkpoint?.take(goods.id);
      },
    );
    interactions.bind(root, target);
    for (final part in parts) {
      interactions.bind(part, target);
    }
  }

  const shopSpots = <(String, double)>[
    ('shop-vegetable', -0.3),
    ('shop-fruit', 0.9),
    ('shop-clothes', 2.1),
    ('shop-books', 3.3),
    ('shop-dairy', 4.5),
  ];
  for (final spot in shopSpots) {
    final shop = shopById(spot.$1);
    if (shop == null) {
      continue;
    }
    final node = addBox(
      scene,
      name: shop.id,
      center: Vector3(spot.$2, 1.25, 5.35),
      size: Vector3(0.72, 0.9, 0.08),
      material: BlockoutPalette.flat(shop.red, shop.green, shop.blue, 0.5),
      shadowStatic: false,
      castsShadows: false,
    );
    interactions.bind(
      node,
      LearningTarget(
        id: shop.id,
        session: session,
        action: 'निवडा',
        onInteract: () => session.visitShop(shop.id),
      ),
    );
  }
}

List<Node> _goodsShape(String id) {
  final plate = _disc('plate', 0.2, 0.04, 0.55, 0.36, 0.2, Vector3(0, 0.02, 0));
  return switch (id) {
    'word-apple' => [
      plate,
      _ball('body', 0.15, 0.82, 0.14, 0.12, Vector3(0, 0.2, 0)),
      _stem(Vector3(0, 0.36, 0)),
      _ball('leaf', 0.045, 0.28, 0.62, 0.2, Vector3(0.06, 0.34, 0.02)),
    ],
    'word-carrot' => [
      plate,
      _cone(Vector3(0, 0.22, 0)),
      _ball('leaf-a', 0.05, 0.22, 0.58, 0.18, Vector3(-0.04, 0.4, 0)),
      _ball('leaf-b', 0.045, 0.28, 0.66, 0.2, Vector3(0.04, 0.42, 0.02)),
    ],
    'word-banana' => [
      plate,
      _ball('a', 0.07, 0.95, 0.82, 0.16, Vector3(-0.12, 0.12, 0.02)),
      _ball('b', 0.085, 0.96, 0.84, 0.18, Vector3(-0.03, 0.16, 0)),
      _ball('c', 0.08, 0.94, 0.78, 0.14, Vector3(0.07, 0.15, -0.01)),
      _ball('d', 0.05, 0.72, 0.55, 0.12, Vector3(0.15, 0.11, 0.02)),
    ],
    'word-mango' => [
      plate,
      _ball(
        'body',
        0.13,
        0.95,
        0.58,
        0.1,
        Vector3(0, 0.2, 0),
        scale: Vector3(0.85, 1.25, 0.75),
      ),
      _ball('blush', 0.04, 0.85, 0.28, 0.1, Vector3(0.04, 0.22, 0.08)),
    ],
    'word-tomato' => [
      plate,
      _ball(
        'body',
        0.13,
        0.86,
        0.16,
        0.12,
        Vector3(0, 0.16, 0),
        scale: Vector3(1, 0.82, 1),
      ),
      _ball('cap', 0.05, 0.24, 0.58, 0.18, Vector3(0, 0.28, 0)),
    ],
    'word-milk' => [
      plate,
      _bottle(Vector3(0, 0.22, 0)),
      _disc('band', 0.085, 0.03, 0.35, 0.58, 0.82, Vector3(0, 0.28, 0)),
    ],
    'word-soap' => [
      plate,
      _disc('bar', 0.12, 0.08, 0.95, 0.96, 0.97, Vector3(0, 0.1, 0)),
      _disc('stripe', 0.125, 0.02, 0.25, 0.48, 0.82, Vector3(0, 0.14, 0)),
    ],
    _ => [plate],
  };
}

Node _ball(
  String name,
  double radius,
  double red,
  double green,
  double blue,
  Vector3 at, {
  Vector3? scale,
}) {
  final node = Node(
    name: name,
    mesh: Mesh(
      SphereGeometry(radius: radius, segments: 18, rings: 12),
      BlockoutPalette.flat(red, green, blue, 0.4),
    ),
  )..position = at;
  if (scale != null) {
    node.scale = scale;
  }
  return node;
}

Node _disc(
  String name,
  double radius,
  double height,
  double red,
  double green,
  double blue,
  Vector3 at,
) {
  return Node(
    name: name,
    mesh: Mesh(
      CylinderGeometry(
        bottomRadius: radius,
        topRadius: radius,
        height: height,
        radialSegments: 16,
      ),
      BlockoutPalette.flat(red, green, blue, 0.6),
    ),
  )..position = at;
}

Node _stem(Vector3 at) {
  return Node(
    name: 'stem',
    mesh: Mesh(
      CylinderGeometry(
        bottomRadius: 0.012,
        topRadius: 0.012,
        height: 0.08,
        radialSegments: 6,
      ),
      BlockoutPalette.flat(0.35, 0.22, 0.1, 0.7),
    ),
  )..position = at;
}

Node _cone(Vector3 at) {
  return Node(
    name: 'body',
    mesh: Mesh(
      CylinderGeometry(
        bottomRadius: 0.08,
        topRadius: 0,
        height: 0.36,
        radialSegments: 14,
      ),
      BlockoutPalette.flat(0.93, 0.45, 0.1, 0.45),
    ),
  )..position = at;
}

Node _bottle(Vector3 at) {
  return Node(
    name: 'body',
    mesh: Mesh(
      CapsuleGeometry(
        radius: 0.07,
        height: 0.16,
        radialSegments: 14,
        capRings: 6,
      ),
      BlockoutPalette.flat(0.95, 0.96, 0.97, 0.35),
    ),
  )..position = at;
}
