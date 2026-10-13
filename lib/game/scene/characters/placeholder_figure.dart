import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../characters/character_appearance.dart';

/// Simple body, head, and one accent. Customers use this today. Chiku can
/// use the same builder when a placeholder mascot is placed in the scene.
void addPlaceholderFigure(
  Node root, {
  required String name,
  required FigureAccent accentKind,
  required PhysicallyBasedMaterial body,
  required PhysicallyBasedMaterial head,
  required PhysicallyBasedMaterial accent,
}) {
  root.add(_part(name, 'body', body, 0.17, 1.1, Vector3(0, 0.55, 0)));
  root.add(_part(name, 'head', head, 0.12, 0.26, Vector3(0, 1.23, 0)));
  switch (accentKind) {
    case FigureAccent.cap:
      root.add(_part(name, 'cap', accent, 0.13, 0.08, Vector3(0, 1.4, 0)));
    case FigureAccent.sash:
      root.add(_part(name, 'sash', accent, 0.18, 0.08, Vector3(0, 0.85, 0)));
    case FigureAccent.ears:
      root.add(
        _part(name, 'ear-left', accent, 0.04, 0.22, Vector3(-0.07, 1.48, 0)),
      );
      root.add(
        _part(name, 'ear-right', accent, 0.04, 0.22, Vector3(0.07, 1.48, 0)),
      );
  }
}

Node _part(
  String name,
  String part,
  PhysicallyBasedMaterial material,
  double radius,
  double height,
  Vector3 position,
) {
  return Node(
      name: '$name-$part',
      mesh: Mesh(
        CylinderGeometry(
          bottomRadius: radius,
          topRadius: radius,
          height: height,
          radialSegments: 10,
        ),
        material,
      ),
    )
    ..position = position
    ..castsShadows = false
    ..shadowStatic = false;
}
