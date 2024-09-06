import 'package:flutter/material.dart';
import 'package:flutter_magic_checkbox/checkbox_to_line.dart';
import 'package:flutter_magic_checkbox/path_based_square.dart';
import 'dart:math' as math;

import 'package:flutter_magic_checkbox/rotate_rect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SquareUnravelAnimation()

        // Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        //     child: LearningCheckBoxAnimationWidget()
        //     ),
        );
  }
}

class MyCanvas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Simple rectangle painter
class SimplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw a simple rectangle
    canvas.drawRect(Rect.fromLTWH(50, 50, 100, 150), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RotatedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.rotateRect(
      rect: Rect.fromLTWH(50, 50, 100, 150),
      angle: math.pi / 4, // 45 degrees
      paint: paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
