import 'package:asmitra_game/app/as_mitra_app.dart';
import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/carry/carry_controller.dart';
import 'package:asmitra_game/game/checkout/checkout_session.dart';
import 'package:asmitra_game/game/input/virtual_joystick.dart';
import 'package:asmitra_game/game/interaction/interactable.dart';
import 'package:asmitra_game/game/interaction/interaction_system.dart';
import 'package:asmitra_game/ui/checkout_panel.dart';
import 'package:asmitra_game/ui/interaction_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  testWidgets('Class home leads into the store letter hunt', (tester) async {
    await tester.pumpWidget(const AsMitraApp());

    expect(find.text('चिकूची मराठी'), findsOneWidget);
    expect(find.byKey(const Key('enter-market')), findsOneWidget);
    expect(find.byKey(const Key('move-joystick')), findsNothing);

    await tester.tap(find.byKey(const Key('enter-market')));
    await tester.pump();

    expect(find.text('FIND THIS LETTER'), findsOneWidget);
    expect(find.byKey(const Key('find-letter')), findsOneWidget);
    expect(find.byKey(const Key('find-score')), findsOneWidget);
    expect(find.byKey(const Key('center-reticle')), findsOneWidget);
    expect(find.byKey(const Key('move-joystick')), findsOneWidget);
    expect(find.byKey(const Key('interact-button')), findsNothing);
    expect(find.byKey(const Key('checkout-panel')), findsNothing);
  });

  testWidgets('interaction prompt appears only while a target is aimed', (
    tester,
  ) async {
    final system = InteractionSystem(maxDistance: 2.5);
    var used = 0;
    final key = Object();
    system.bind(
      key,
      BasicInteractable(
        id: 'test-box',
        displayName: 'Test Box',
        prompt: 'INTERACT',
        onInteract: () => used++,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InteractionPrompt(system: system)),
      ),
    );
    expect(find.text('Test Box'), findsNothing);
    expect(find.byKey(const Key('interact-button')), findsNothing);

    system.setAim(hitKey: key, distance: 1);
    await tester.pump();
    expect(find.text('Test Box'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'INTERACT'));
    expect(used, 1);

    system.setAim(hitKey: null, distance: null);
    await tester.pump();
    expect(find.text('Test Box'), findsNothing);
    expect(find.byKey(const Key('interact-button')), findsNothing);
  });

  testWidgets('a product prompt shows the name and temporary price', (
    tester,
  ) async {
    final system = InteractionSystem(maxDistance: 2.5);
    final key = Object();
    system.bind(
      key,
      BasicInteractable(
        id: 'product-milk',
        displayName: 'Fresh Milk',
        prompt: 'Inspect',
        priceAmount: 48,
        onInteract: () {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InteractionPrompt(system: system)),
      ),
    );
    system.setAim(hitKey: key, distance: 1);
    await tester.pump();

    expect(find.text('Fresh Milk'), findsOneWidget);
    expect(find.text('₹48'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Inspect'));
    expect(system.aim?.target.displayName, 'Fresh Milk');
  });

  testWidgets('Joystick up reports forward', (tester) async {
    Vector2 value = Vector2.zero();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VirtualJoystick(onChanged: (input) => value = input),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byKey(const Key('move-joystick')));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, -50));
    await tester.pump();

    expect(value.y, greaterThan(0.5));
    expect(value.x.abs(), lessThan(0.25));
    await gesture.up();
  });

  testWidgets('checkout panel scans, rejects short cash, and completes', (
    tester,
  ) async {
    final carry = CarryController();
    final session = CheckoutSession(
      catalog: ProductCatalog.starter,
      carry: carry,
    );
    addTearDown(carry.dispose);
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CheckoutPanel(session: session)),
      ),
    );
    expect(find.byKey(const Key('checkout-panel')), findsNothing);

    session.open();
    await tester.pump();
    expect(find.text('AS MITRA CHECKOUT'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-scan')));
    await tester.pump();
    expect(session.transaction!.total, 0);

    void scan(String id, String label) {
      carry.tryHold(CarriedItem(id: id, label: label));
      session.scanHeldItem();
    }

    scan('milk', 'Fresh Milk');
    scan('bread', 'Bread');
    scan('bread', 'Bread');
    scan('biscuits', 'Biscuits');
    scan('biscuits', 'Biscuits');
    scan('biscuits', 'Biscuits');
    await tester.pump();

    expect(find.text('Fresh Milk × 1'), findsOneWidget);
    expect(find.text('Bread × 2'), findsOneWidget);
    expect(find.text('Biscuits × 3'), findsOneWidget);
    expect(find.text('₹210'), findsOneWidget);
    expect(carry.isHolding, isFalse);

    await tester.tap(find.byKey(const Key('checkout-pay')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('checkout-cash-200')));
    await tester.pump();
    expect(find.text('INSUFFICIENT CASH'), findsOneWidget);
    expect(session.lastCompletedSale, isNull);

    await tester.tap(find.byKey(const Key('checkout-cash-500')));
    await tester.pump();
    expect(find.text('₹290'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-complete')));
    await tester.pump();
    expect(find.text('Sale Complete'), findsOneWidget);
    expect(session.isOpen, isFalse);
    expect(session.lastCompletedSale!.total, 210);
    expect(session.lastCompletedSale!.change, 290);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancel closes the checkout panel', (tester) async {
    final carry = CarryController();
    final session = CheckoutSession(
      catalog: ProductCatalog.starter,
      carry: carry,
    );
    addTearDown(carry.dispose);
    addTearDown(session.dispose);
    session.open();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CheckoutPanel(session: session)),
      ),
    );
    await tester.tap(find.byKey(const Key('checkout-cancel')));
    await tester.pump();

    expect(find.byKey(const Key('checkout-panel')), findsNothing);
    expect(session.isOpen, isFalse);
    expect(session.lastCompletedSale, isNull);
  });
}
