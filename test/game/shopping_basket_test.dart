import 'package:asmitra_game/game/carry/shopping_basket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('putting the basket down keeps its items on that spot', () {
    final basket = ShoppingBasket()..take();
    expect(basket.stow('milk'), isTrue);

    basket.putDown(x: 1.2, z: -0.4, yaw: 0.5);

    expect(basket.carried, isFalse);
    expect(basket.isOnFloor, isTrue);
    expect(basket.dropX, 1.2);
    expect(basket.dropZ, -0.4);
    expect(basket.dropYaw, 0.5);
    expect(basket.productIds, ['milk']);

    basket.take();

    expect(basket.carried, isTrue);
    expect(basket.isOnFloor, isFalse);
    expect(basket.productIds, ['milk']);
  });
}
