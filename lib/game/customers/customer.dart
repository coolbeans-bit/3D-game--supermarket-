import 'package:vector_math/vector_math.dart';

import '../world/collision_box.dart';
import 'customer_movement.dart';
import 'customer_type.dart';
import 'shopping_list.dart';
import 'waypoint.dart';

/// Where a shopper is on the first visit loop.
///
/// Finding a product, taking it, and joining the checkout queue are later
/// states. They can be added here without replacing the customer record.
enum CustomerState { entering, shopping, leaving, exited }

/// One shopper. Rendering and Flutter widgets stay outside this type.
class Customer {
  Customer({
    required this.id,
    required this.type,
    required this.shoppingList,
    required Vector3 position,
    required this.enteringPath,
    required this.leavingPath,
    this.shoppingPath = const [],
  }) : speed = type.speed,
       patience = type.patience,
       position = position.clone(),
       state = CustomerState.entering {
    if (id.isEmpty) {
      throw ArgumentError('a customer needs an id');
    }
    if (enteringPath.isEmpty || leavingPath.isEmpty) {
      throw ArgumentError('a customer needs an enter path and an exit path');
    }
  }

  final String id;
  final CustomerType type;
  final double speed;
  final double patience;
  final List<ShoppingListEntry> shoppingList;
  final Vector3 position;
  final List<Waypoint> enteringPath;
  final List<Waypoint> shoppingPath;
  final List<Waypoint> leavingPath;

  CustomerState state;
  double yaw = 0;
  double waitRemaining = 0;
  double actionRemaining = 0;
  bool reaching = false;
  int legIndex = 0;

  /// Catalog ids this shopper has already taken off a shelf.
  final List<String> picked = [];

  String get stateLabel => switch (state) {
    CustomerState.entering => 'ENTERING',
    CustomerState.shopping => 'SHOPPING',
    CustomerState.leaving => 'LEAVING',
    CustomerState.exited => 'EXITED',
  };
}

/// Advances one shopper by [dt] seconds.
void advanceCustomer({
  required Customer customer,
  required double dt,
  required double limit,
  List<CollisionBox> obstacles = const [],
}) {
  switch (customer.state) {
    case CustomerState.entering:
      _follow(
        customer,
        customer.enteringPath,
        dt,
        limit,
        obstacles,
        onFinished: () {
          customer.state = CustomerState.shopping;
          customer.waitRemaining = customer.patience;
          customer.reaching = false;
          customer.actionRemaining = 0;
          customer.legIndex = 0;
        },
      );
    case CustomerState.shopping:
      if (customer.shoppingPath.isEmpty) {
        customer.waitRemaining -= dt;
        customer.reaching = false;
        if (customer.waitRemaining <= 0) {
          customer.state = CustomerState.leaving;
          customer.legIndex = 0;
        }
        break;
      }
      _follow(
        customer,
        customer.shoppingPath,
        dt,
        limit,
        obstacles,
        onFinished: () {
          customer.state = CustomerState.leaving;
          customer.reaching = false;
          customer.actionRemaining = 0;
          customer.legIndex = 0;
        },
      );
    case CustomerState.leaving:
      _follow(
        customer,
        customer.leavingPath,
        dt,
        limit,
        obstacles,
        onFinished: () {
          customer.state = CustomerState.exited;
        },
      );
    case CustomerState.exited:
      break;
  }
}

void _follow(
  Customer customer,
  List<Waypoint> path,
  double dt,
  double limit,
  List<CollisionBox> obstacles, {
  required void Function() onFinished,
}) {
  if (customer.legIndex >= path.length) {
    onFinished();
    return;
  }
  final point = path[customer.legIndex];
  if (customer.actionRemaining > 0) {
    customer.actionRemaining -= dt;
    customer.reaching = point.reach;
    final face = point.faceYaw;
    if (face != null) {
      customer.yaw = face;
    }
    if (customer.actionRemaining > 0) {
      return;
    }
    customer.reaching = false;
    _keep(customer, point);
    customer.legIndex += 1;
    if (customer.legIndex >= path.length) {
      onFinished();
    }
    return;
  }
  final step = stepToward(
    position: customer.position,
    target: point.position,
    speed: customer.speed,
    dt: dt,
    limit: limit,
    obstacles: obstacles,
  );
  customer.yaw = step.yaw;
  customer.reaching = false;
  if (!step.arrived) {
    return;
  }
  if (point.pause > 0) {
    customer.actionRemaining = point.pause;
    customer.reaching = point.reach;
    final face = point.faceYaw;
    if (face != null) {
      customer.yaw = face;
    }
    return;
  }
  customer.legIndex += 1;
  if (customer.legIndex >= path.length) {
    onFinished();
  }
}

void _keep(Customer customer, Waypoint point) {
  final productId = point.productId;
  if (productId == null || customer.picked.contains(productId)) {
    return;
  }
  customer.picked.add(productId);
}
