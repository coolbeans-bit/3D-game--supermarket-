import 'package:flutter/material.dart';

/// A simple stand-in for Chiku. The finished rabbit model comes later.
class ChikuMark extends StatelessWidget {
  const ChikuMark({super.key, this.size = 54});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('chiku-mark'),
      width: size,
      height: size,
      child: CustomPaint(painter: _ChikuPainter()),
    );
  }
}

class _ChikuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ear = Paint()..color = const Color(0xFFED8C9E);
    final head = Paint()..color = const Color(0xFFF7E6CC);
    final w = size.width;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.32, w * 0.28),
        width: w * 0.22,
        height: w * 0.42,
      ),
      ear,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.68, w * 0.28),
        width: w * 0.22,
        height: w * 0.42,
      ),
      ear,
    );
    canvas.drawCircle(Offset(w * 0.5, w * 0.58), w * 0.34, head);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
