import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/supermarket/supermarket_layout.dart';
import '../humans/human_figure.dart';
import '../humans/human_outfit.dart';

/// The person behind the checkout counter.
///
/// He stands on the staff side, facing the queue, and stays inside the
/// counter's collision so the player cannot walk through him.
class CashierPresenter {
  CashierPresenter(this.scene, this.people);

  final Scene scene;
  final HumanLibrary people;
  HumanFigure? _figure;

  void place() {
    final body = people.spawn(HumanLibrary.cashier);
    dressCashier(body.node);
    _figure = HumanFigure(
      scene: scene,
      model: body.node,
      name: 'cashier',
      idleName: body.idle,
      walkName: body.walk,
      reachName: body.reach,
      scale: 0.34,
    );
  }

  void sync(double deltaSeconds) {
    _figure?.sync(
      feet: Vector3(SupermarketLayout.counterCenterX, 0, _standZ),
      yaw: 0,
      speed: 0,
      deltaSeconds: deltaSeconds,
    );
  }

  /// Just past the counter top, still inside the padded counter box.
  static const double _standZ =
      SupermarketLayout.counterCenterZ +
      SupermarketLayout.counterSizeZ / 2 +
      0.18;
}
