import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/shopping_basket.dart';
import '../../checkout/checkout_session.dart';
import '../../checkout/sale_transaction.dart';
import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Checkout counter, scanner stand, payment pad, and queue marks.
///
/// The scanner stand is the interaction target. The stand is tall enough
/// to meet an eye-level ray. Payment buttons live in the checkout panel.
void addSupermarketCheckout(
  Scene scene,
  InteractionSystem interactions,
  BlockoutPalette palette,
  CheckoutSession checkout, {
  ShoppingBasket? basket,
  void Function()? onAskCashier,
}) {
  for (final span in SupermarketLayout.solids) {
    if (span.role == SpanRole.counter) {
      addSpan(scene, span, name: 'checkout-counter', material: palette.counter);
    }
  }

  final scanner = addBox(
    scene,
    name: 'checkout-scanner',
    center: Vector3(
      SupermarketLayout.scannerCenterX,
      SupermarketLayout.counterHeight + SupermarketLayout.scannerHeight / 2,
      SupermarketLayout.scannerCenterZ,
    ),
    size: Vector3(
      SupermarketLayout.scannerWidth,
      SupermarketLayout.scannerHeight,
      SupermarketLayout.scannerWidth,
    ),
    material: palette.scanner,
    shadowStatic: false,
  );
  addBox(
    scene,
    name: 'checkout-payment',
    center: Vector3(
      SupermarketLayout.paymentCenterX,
      SupermarketLayout.counterHeight + 0.02,
      SupermarketLayout.paymentCenterZ,
    ),
    size: Vector3(0.36, 0.04, 0.28),
    material: palette.payment,
    castsShadows: false,
  );
  for (var i = 0; i < SupermarketLayout.queueMarks.length; i++) {
    final mark = SupermarketLayout.queueMarks[i];
    addBox(
      scene,
      name: 'queue-$i',
      center: Vector3(mark.x, 0.015, mark.z),
      size: Vector3(0.55, 0.02, 0.55),
      material: palette.queue,
      castsShadows: false,
    );
  }

  final ask = onAskCashier;
  if (ask != null) {
    final bell = addBox(
      scene,
      name: 'checkout-ask',
      center: Vector3(
        SupermarketLayout.counterCenterX + 0.55,
        1.15,
        SupermarketLayout.counterCenterZ -
            SupermarketLayout.counterSizeZ / 2 -
            0.22,
      ),
      size: Vector3(0.32, 0.48, 0.28),
      material: palette.payment,
      shadowStatic: false,
    );
    interactions.bind(bell, _AskInteractable(onAsk: ask));
  }

  interactions.bind(
    scanner,
    _CheckoutInteractable(
      checkout: checkout,
      basket: basket,
      onUse: () {
        if (checkout.carry.isHolding) {
          checkout.scanHeldItem();
          return;
        }
        final heldBasket = basket;
        if (heldBasket != null && heldBasket.carried && heldBasket.count > 0) {
          final next = heldBasket.productIds.first;
          if (checkout.scanProductId(next)) {
            heldBasket.takeNext();
          }
          return;
        }
        checkout.open();
      },
    ),
  );
}

class _CheckoutInteractable implements Interactable {
  _CheckoutInteractable({
    required this.checkout,
    required this.onUse,
    this.basket,
  });

  final CheckoutSession checkout;
  final ShoppingBasket? basket;
  final void Function() onUse;

  @override
  String get id => 'checkout';

  @override
  String get displayName => 'Checkout';

  @override
  String get prompt {
    final state = checkout.transaction?.state;
    final canScan =
        state == null ||
        state == TransactionState.idle ||
        state == TransactionState.scanning ||
        state == TransactionState.completed ||
        state == TransactionState.cancelled;
    final heldBasket = basket;
    final basketCount = heldBasket != null && heldBasket.carried
        ? heldBasket.count
        : 0;
    if ((checkout.carry.isHolding || basketCount > 0) && canScan) {
      return 'Scan Product';
    }
    return 'Use Checkout';
  }

  @override
  int? get priceAmount => null;

  @override
  bool get isInteractable => true;

  @override
  void interact() => onUse();
}

/// The bell in front of the cashier. Asking does not scan or score.
class _AskInteractable implements Interactable {
  _AskInteractable({required this.onAsk});

  final void Function() onAsk;

  @override
  String get id => 'cashier-ask';

  @override
  String get displayName => 'कॅशियर';

  @override
  String get prompt => 'कुठे आहे?';

  @override
  int? get priceAmount => null;

  @override
  bool get isInteractable => true;

  @override
  void interact() => onAsk();
}
