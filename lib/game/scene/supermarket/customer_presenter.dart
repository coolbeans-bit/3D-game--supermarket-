import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../../data/catalog/product_catalog.dart';
import '../../customers/customer.dart';
import '../../customers/customer_type.dart';
import '../humans/human_figure.dart';
import '../humans/human_outfit.dart';
import '../products/product_visual_factory.dart';
import 'carried_basket.dart';

/// One walking person per customer record.
///
/// The customer record owns the path. These figures only follow it, and
/// carry a basket that fills as they take products.
class CustomerPresenter {
  CustomerPresenter(
    this.scene,
    this.people, {
    this.basketTemplate,
    this.products,
    this.catalog,
  });

  final Scene scene;
  final HumanLibrary people;
  final Node? basketTemplate;
  final ProductVisualFactory? products;
  final ProductCatalog? catalog;
  final Map<String, HumanFigure> _people = {};
  final Map<String, Vector3> _previous = {};
  final Map<String, bool> _reaching = {};
  final Map<String, CarriedBasket> _baskets = {};

  void sync(Iterable<Customer> customers, double deltaSeconds) {
    final live = <String>{};
    final dt = deltaSeconds <= 0 ? 0.0 : deltaSeconds;
    for (final customer in customers) {
      live.add(customer.id);
      final figure = _people.putIfAbsent(customer.id, () => _create(customer));
      final previous = _previous.putIfAbsent(
        customer.id,
        () => customer.position.clone(),
      );
      final moved = customer.position.distanceTo(previous);
      previous.setFrom(customer.position);
      if (customer.reaching && _reaching[customer.id] != true) {
        figure.playReach();
      }
      _reaching[customer.id] = customer.reaching;
      figure.sync(
        feet: customer.position,
        yaw: customer.yaw,
        speed: dt == 0 ? 0 : moved / dt,
        deltaSeconds: deltaSeconds,
      );
      _basketFor(customer)?.place(
        customer.position,
        customer.yaw,
        customer.picked,
      );
    }
    final gone = [
      for (final id in _people.keys)
        if (!live.contains(id)) id,
    ];
    for (final id in gone) {
      _people.remove(id)?.remove();
      _baskets.remove(id)?.remove();
      _previous.remove(id);
      _reaching.remove(id);
    }
  }

  CarriedBasket? _basketFor(Customer customer) {
    final template = basketTemplate;
    final factory = products;
    final book = catalog;
    if (template == null || factory == null || book == null) {
      return null;
    }
    return _baskets.putIfAbsent(
      customer.id,
      () => CarriedBasket(
        scene: scene,
        factory: factory,
        catalog: book,
        template: template,
        label: customer.id,
        scale: 1,
      ),
    );
  }

  HumanFigure _create(Customer customer) {
    final kind = HumanLibrary.bodyFor(customer.id);
    final body = people.spawn(kind);
    return HumanFigure(
      scene: scene,
      model: body.node,
      name: customer.id,
      idleName: body.idle,
      walkName: body.walk,
      reachName: body.reach,
      scale: _scaleFor(customer.type.id, kind),
      outfit: kind == HumanLibrary.woman
          ? HumanOutfit.forId(customer.id)
          : null,
    );
  }

  double _scaleFor(String typeId, String kind) {
    // The men are authored about two and a half times taller than the woman.
    // The same wrapper scale makes them fill the room, with the camera
    // looking up through their legs.
    final base = kind == HumanLibrary.woman ? 0.86 : 0.33;
    return switch (typeId) {
      _ when typeId == CustomerType.quickShopper.id => base * 1.06,
      _ when typeId == CustomerType.slowShopper.id => base * 0.96,
      _ => base,
    };
  }
}
