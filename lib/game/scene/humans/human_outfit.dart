import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Clothes, hair, and shoes for one person.
///
/// The rig is shared. Each spawned copy gets its own materials so a
/// recolor stays on that person.
class HumanOutfit {
  HumanOutfit({
    required this.clothes,
    required this.hair,
    required this.shoes,
    required this.skin,
    this.belt,
  });

  final Vector4 clothes;
  final Vector4 hair;
  final Vector4 shoes;
  final Vector4 skin;
  final Vector4? belt;

  static final shoppers = <HumanOutfit>[
    HumanOutfit(
      clothes: Vector4(0.38, 0.07, 0.08, 1),
      hair: Vector4(0.05, 0.04, 0.04, 1),
      shoes: Vector4(0.10, 0.06, 0.04, 1),
      skin: Vector4(0.62, 0.42, 0.24, 1),
    ),
    HumanOutfit(
      clothes: Vector4(0.72, 0.58, 0.40, 1),
      hair: Vector4(0.16, 0.07, 0.03, 1),
      shoes: Vector4(0.12, 0.07, 0.04, 1),
      skin: Vector4(0.78, 0.58, 0.40, 1),
    ),
    HumanOutfit(
      clothes: Vector4(0.10, 0.24, 0.52, 1),
      hair: Vector4(0.05, 0.04, 0.04, 1),
      shoes: Vector4(0.06, 0.06, 0.07, 1),
      skin: Vector4(0.48, 0.30, 0.18, 1),
    ),
    HumanOutfit(
      clothes: Vector4(0.55, 0.22, 0.05, 1),
      hair: Vector4(0.22, 0.08, 0.03, 1),
      shoes: Vector4(0.08, 0.05, 0.04, 1),
      skin: Vector4(0.66, 0.40, 0.26, 1),
    ),
    HumanOutfit(
      clothes: Vector4(0.28, 0.10, 0.36, 1),
      hair: Vector4(0.08, 0.04, 0.03, 1),
      shoes: Vector4(0.05, 0.05, 0.06, 1),
      skin: Vector4(0.55, 0.36, 0.22, 1),
    ),
    HumanOutfit(
      clothes: Vector4(0.06, 0.30, 0.28, 1),
      hair: Vector4(0.14, 0.06, 0.03, 1),
      shoes: Vector4(0.07, 0.05, 0.04, 1),
      skin: Vector4(0.74, 0.52, 0.34, 1),
    ),
  ];

  static HumanOutfit forId(String id) {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return shoppers[hash % shoppers.length];
  }
}

/// Navy shirt and a yellow tie on the suited man behind the counter.
///
/// His source file is Quaternius' public-domain man in a suit. A separate
/// supermarket-cashier character that we are allowed to ship was not available.
void dressCashier(Node model) {
  final shirt = Vector4(0.07, 0.16, 0.42, 1);
  final tie = Vector4(0.78, 0.58, 0.08, 1);
  _visit(model, (node) {
    final mesh = node.mesh;
    if (mesh == null) {
      return;
    }
    for (final primitive in mesh.primitives) {
      final material = primitive.material;
      if (material is! PhysicallyBasedMaterial) {
        continue;
      }
      if (material.name == 'Shirt') {
        primitive.material = _surface(shirt, 0.62);
      } else if (material.name.contains('Tie')) {
        primitive.material = _surface(tie, 0.4);
      }
    }
  });
}

/// Recolors the dress, belt, hair, and shoes on a spawned person.
void applyOutfit(Node model, HumanOutfit outfit) {
  _visit(model, (node) {
    final mesh = node.mesh;
    if (mesh == null) {
      return;
    }
    for (final primitive in mesh.primitives) {
      final material = primitive.material;
      if (material is! PhysicallyBasedMaterial) {
        continue;
      }
      final color = material.baseColorFactor;
      if (_isClothes(color)) {
        primitive.material = _surface(outfit.clothes, 0.72);
      } else if (_isBelt(color) && outfit.belt != null) {
        primitive.material = _surface(outfit.belt!, 0.45);
      } else if (_isSkin(color)) {
        primitive.material = _surface(outfit.skin, 0.65);
      } else if (_isHairOrShoes(color)) {
        if (node.name.contains('Head')) {
          primitive.material = _surface(outfit.hair, 0.55);
        } else if (node.name.contains('Feet')) {
          primitive.material = _surface(outfit.shoes, 0.8);
        }
      }
    }
  });
}

PhysicallyBasedMaterial _surface(Vector4 color, double rough) {
  return PhysicallyBasedMaterial()
    ..baseColorFactor = color
    ..roughnessFactor = rough
    ..metallicFactor = 0.02;
}

bool _isClothes(Vector4 color) {
  return color.g > color.r && color.g > color.b && color.g > 0.08 && color.r < 0.25;
}

bool _isBelt(Vector4 color) {
  return color.r > 0.3 && color.r > color.g && color.g > color.b;
}

bool _isSkin(Vector4 color) {
  return color.r > 0.45 && color.g > 0.25 && color.b > 0.12 && color.r > color.g;
}

bool _isHairOrShoes(Vector4 color) {
  return color.r > 0.05 &&
      color.r < 0.25 &&
      color.r > color.g * 4 &&
      color.b < 0.05;
}

void _visit(Node node, void Function(Node node) visit) {
  visit(node);
  for (final child in node.children) {
    _visit(child, visit);
  }
}
