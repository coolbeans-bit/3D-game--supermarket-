import 'package:asmitra_game/game/world/supermarket/supermarket_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the porch spawn and the three aisles are walkable', () {
    final start = SupermarketLayout.playerStart;
    expect(SupermarketLayout.occupied(start.x, start.z), isFalse);
    expect(SupermarketLayout.occupied(0, 6), isFalse);
    expect(SupermarketLayout.occupied(0, -1), isFalse);
    expect(SupermarketLayout.occupied(-2.25, -1), isFalse);
    expect(SupermarketLayout.occupied(2.25, -1), isFalse);
    expect(SupermarketLayout.occupied(1.5, -9), isFalse);
    expect(SupermarketLayout.occupied(-3.5, -7.11), isFalse);
  });

  test('shelves, the counter, and the staff bench block the player', () {
    expect(SupermarketLayout.occupied(-3.375, -1), isTrue);
    expect(SupermarketLayout.occupied(4.55, 4.75), isTrue);
    expect(SupermarketLayout.occupied(4.3, -11.15), isTrue);
    expect(SupermarketLayout.occupied(-6.1, 0), isTrue);
  });

  test('closed doors block their openings and open doors do not', () {
    final closedEntrance = [
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceClosedLeftX),
      SupermarketLayout.entrancePanelBox(
        SupermarketLayout.entranceClosedRightX,
      ),
    ];
    final openEntrance = [
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenLeftX),
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenRightX),
    ];

    expect(SupermarketLayout.occupied(0, 7.08, closedEntrance), isTrue);
    expect(SupermarketLayout.occupied(0, 7.08, openEntrance), isFalse);
    expect(
      SupermarketLayout.occupied(-3.5, -7.11, [
        SupermarketLayout.storageDoorClosedBox(),
      ]),
      isTrue,
    );
    expect(
      SupermarketLayout.occupied(-3.5, -7.11, [
        SupermarketLayout.storageDoorOpenBox(),
      ]),
      isFalse,
    );
  });
}
