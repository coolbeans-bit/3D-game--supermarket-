import 'package:flutter/widgets.dart';

/// Right-side drag surface. [dx] and [dy] are pixel deltas, y positive down.
class LookController extends StatelessWidget {
  const LookController({super.key, required this.onLook, this.onLookEnd});

  final void Function(double dx, double dy) onLook;
  final VoidCallback? onLookEnd;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerMove: (event) => onLook(event.delta.dx, event.delta.dy),
      onPointerUp: (_) => onLookEnd?.call(),
      onPointerCancel: (_) => onLookEnd?.call(),
      child: const SizedBox.expand(),
    );
  }
}
