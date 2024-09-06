import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedRotatedRect extends StatefulWidget {
  const AnimatedRotatedRect({Key? key}) : super(key: key);

  @override
  _AnimatedRotatedRectState createState() => _AnimatedRotatedRectState();
}

class _AnimatedRotatedRectState extends State<AnimatedRotatedRect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      // This makes the animation repeat indefinitely
      ..repeat(reverse: true);

    // Tween anmation from 0 to 45degrees
    _animation = Tween<double>(begin: 0, end: math.pi / 4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: RotatedRectPainter(_animation.value),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class RotatedRectPainter extends CustomPainter {
  final double angle;

  RotatedRectPainter(this.angle);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.rotateRect(
      rect: Rect.fromLTWH(50, 50, 100, 150),
      angle: angle,
      paint: paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  //repaint when angle changes
}

//----- extension
extension RotatedRectDrawer on Canvas {
  void rotateRect({
    required Rect rect,
    required double angle,
    required Paint paint,
  }) {
    // Save the current state of the drawing instructions
    // This allows us to revert changes made within this method
    this.save();

    // Calculate the center of the rectangle
    final centerX = rect.left + rect.width / 2;
    final centerY = rect.top + rect.height / 2;

    // Add a translation instruction
    // This moves the coordinate system origin to the rectangle's center
    this.translate(centerX, centerY);

    // Add a rotation instruction
    // This will affect all subsequent drawing instructions
    this.rotate(angle);

    // Add a rectangle drawing instruction
    // The rectangle is now centered at (0,0) due to the previous translate()
    this.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: rect.width,
        height: rect.height,
      ),
      paint,
    );

    // Restore the original state of drawing instructions
    // This effectively "closes" the group of transformed instructions
    this.restore();
  }
}
