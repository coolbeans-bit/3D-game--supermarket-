import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

/// Lower-left movement stick. Reports x = right and y = forward, each -1 to 1.
class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({super.key, required this.onChanged});

  final ValueChanged<Vector2> onChanged;

  static const double size = 140;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  static const double _knobRadius = 28;
  static const double _deadZone = 0.12;

  Offset _knob = Offset.zero;

  double get _travel => VirtualJoystick.size / 2 - _knobRadius;

  void _setStick(Offset local) {
    final center = const Offset(
      VirtualJoystick.size / 2,
      VirtualJoystick.size / 2,
    );
    var delta = local - center;
    final length = delta.distance;
    if (length > _travel && length > 0) {
      delta = delta / length * _travel;
    }
    setState(() => _knob = delta);

    final scale = delta / _travel;
    final stick = Vector2(scale.dx, -scale.dy);
    widget.onChanged(stick.length < _deadZone ? Vector2.zero() : stick);
  }

  void _reset() {
    setState(() => _knob = Offset.zero);
    widget.onChanged(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('move-joystick'),
      onPanStart: (details) => _setStick(details.localPosition),
      onPanUpdate: (details) => _setStick(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: SizedBox(
        width: VirtualJoystick.size,
        height: VirtualJoystick.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC1B5E20),
            border: Border.all(color: const Color(0xFFFFE082), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Transform.translate(
              offset: _knob,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF6E8),
                  boxShadow: [
                    BoxShadow(color: Color(0x44000000), blurRadius: 6),
                  ],
                ),
                child: SizedBox(
                  width: _knobRadius * 2,
                  height: _knobRadius * 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
