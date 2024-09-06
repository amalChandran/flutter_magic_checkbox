import 'package:flutter/material.dart';
import 'dart:math' as math;

class LearningCheckBoxAnimationWidget extends StatefulWidget {
  @override
  _LearningCheckBoxAnimationWidgetState createState() =>
      _LearningCheckBoxAnimationWidgetState();
}

class _LearningCheckBoxAnimationWidgetState
    extends State<LearningCheckBoxAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rectUnravelledAnimation;
  late Animation<double> _rectRotatesAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rectUnravelledAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rectRotatesAnimation = Tween<double>(begin: 0, end: -math.pi / 4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.25, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([_animationController]),
          builder: (context, child) {
            return MultiCanvasWidget(
              painters: [
                DrawPathPainter(),
                DrawRectPathPainter(),
                CompositePainter(
                  painters: [
                    DrawRectPathWithPercentagePainter(0.10),
                    DrawRectPathWithPercentagePainter(0.25),
                    DrawRectPathWithPercentagePainter(0.50),
                    DrawRectPathWithPercentagePainter(0.75)
                  ],
                ),
                DrawRectPathWithPercentagePainter(
                    _rectUnravelledAnimation.value),
                DrawRectPathWithPercentageAndRotationPainter(
                    _rectUnravelledAnimation.value,
                    _rectRotatesAnimation.value),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MultiCanvasWidget extends StatelessWidget {
  final List<CustomPainter> painters;

  const MultiCanvasWidget({Key? key, required this.painters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double availableHeight = constraints.maxHeight;
          double canvasHeight = availableHeight / painters.length;

          return Column(
            children: List.generate(
              painters.length,
              (index) => SizedBox(
                height: canvasHeight,
                width: double.infinity,
                child: CustomPaint(
                  painter: painters[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyCustomPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DrawPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * .25, size.height * .5);
    path.lineTo(size.width * .75, size.height * .5);

    canvas.drawPath(path, paint);

    drawText(size, canvas, 'Line drawn using path');
  }

  void drawText(Size size, Canvas canvas, String text) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate position
    final xCenter = (size.width - textPainter.width) * .5;
    final yCenter = (size.height - textPainter.height) * .75;
    final offset = Offset(xCenter, yCenter);

    // Draw text
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DrawRectPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width * .75, size.height * .75);
    path.lineTo(size.width * .75, size.height * .25);
    path.lineTo(size.width * .25, size.height * .25);
    path.lineTo(size.width * .25, size.height * .75);
    path.close();

    canvas.drawPath(path, paint);

    drawText(size, canvas, 'Rectangle drawn using path');
  }

  void drawText(Size size, Canvas canvas, String text) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate position
    final xCenter = (size.width - textPainter.width) * .5;
    final yCenter = (size.height - textPainter.height) * .95;
    final offset = Offset(xCenter, yCenter);

    // Draw text
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompositePainter extends CustomPainter {
  final List<CustomPainter> painters;

  CompositePainter({required this.painters});

  @override
  void paint(Canvas canvas, Size size) {
    final int count = painters.length;
    final double width = size.width / count;

    for (int i = 0; i < count; i++) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(i * width, 0, width, size.height));
      canvas.translate(i * width, 0);
      painters[i].paint(canvas, Size(width, size.height));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DrawRectPathWithPercentagePainter extends CustomPainter {
  final double unravelValue;
  DrawRectPathWithPercentagePainter(this.unravelValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width * .75, size.height * .75);
    path.lineTo(size.width * .75, size.height * .25);
    path.lineTo(size.width * .25, size.height * .25);
    path.lineTo(size.width * .25, size.height * .75);
    path.close();

    //and before we draw the full path we only draw a percentage of it.
    // Gets a percentage of the path. unravelValue = 0 returns the full path.
    //unravelValue = 0.5 returns the half path and so on.
    final pathMetrics = path.computeMetrics().last;
    final extractPath = pathMetrics.extractPath(
      pathMetrics.length * unravelValue,
      pathMetrics.length,
    );

    canvas.drawPath(extractPath, paint);

    drawText(size, canvas, '${(100 * unravelValue).toInt()}%');
  }

  void drawText(Size size, Canvas canvas, String text) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate position
    final xCenter = (size.width - textPainter.width) * .5;
    final yCenter = (size.height - textPainter.height) * .95;
    final offset = Offset(xCenter, yCenter);

    // Draw text
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DrawRectPathWithPercentageAndRotationPainter extends CustomPainter {
  final double unravelValue;
  final double rotationValue;
  DrawRectPathWithPercentageAndRotationPainter(
      this.unravelValue, this.rotationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Define the percentage of the size you want the square to occupy
    double squarePercentage = 0.15; // 50% of the canvas size

    // Calculate the side length of the square
    double sideLength = size.width * squarePercentage;

    // Calculate the starting point (top-left corner) of the square
    double startX = (size.width + sideLength) / 2;
    double startY = (size.height + sideLength) / 2;

    // Draw the square starting from bottom right, moving counterclockwise
    path.moveTo(startX, startY); // Bottom right
    path.lineTo(startX, startY - sideLength); // Top right
    path.lineTo(startX - sideLength, startY - sideLength); // Top left
    path.lineTo(startX - sideLength, startY); // Bottom left
    path.close(); // Back to bottom right

    final rotatedPath = path.rotateFromCenter(rotationValue);

    //and before we draw the full path we only draw a percentage of it.
    // Gets a percentage of the path. unravelValue = 0 returns the full path.
    //unravelValue = 0.5 returns the half path and so on.
    final pathMetrics = rotatedPath.computeMetrics().last;
    final extractPath = pathMetrics.extractPath(
      pathMetrics.length * unravelValue,
      pathMetrics.length,
    );

    canvas.drawPath(extractPath, paint);

    drawText(size, canvas,
        'unravel : ${(100 * unravelValue).toInt()}% | rotation: ${(rotationValue * (180 / math.pi)).toInt()}Degrees');
  }

  void drawText(Size size, Canvas canvas, String text) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate position
    final xCenter = (size.width - textPainter.width) * .5;
    final yCenter = (size.height - textPainter.height) * .95;
    final offset = Offset(xCenter, yCenter);

    // Draw text
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(
          covariant DrawRectPathWithPercentageAndRotationPainter oldDelegate) =>
      oldDelegate.rotationValue != rotationValue ||
      oldDelegate.unravelValue != unravelValue;
}

class PathPainter extends CustomPainter {
  final double unravelValue;

  PathPainter(this.unravelValue);

  final bluePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    drawRectWithPath(size, canvas);
//drawtext on canvas

    final textSpan = TextSpan(
      text: 'Flutter',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(0, 0),
    );
  }

  void drawRectWithPath(Size size, Canvas canvas) {
    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();

    // Gets a percentage of the path. unravelValue = 0 returns the full path.
    //unravelValue = 0.5 returns the half path and so on.
    final pathMetrics = path.computeMetrics().last;
    final extractPath = pathMetrics.extractPath(
      pathMetrics.length * unravelValue,
      pathMetrics.length,
    );

    // Draw the animated part of the path
    canvas.drawPath(extractPath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) =>
      oldDelegate.unravelValue != unravelValue;
}

//------------------------------------------------------------------------------
// Extension
//------------------------------------------------------------------------------

extension RotatedPathDrawer on Canvas {
  void rotatePath({
    required Path path,
    required double angle,
    required Paint paint,
  }) {
    // Save the current state of the drawing instructions
    this.save();

    // Calculate the center of the path's bounding box
    final bounds = path.getBounds();
    final centerX = bounds.left + bounds.width / 2;
    final centerY = bounds.top + bounds.height / 2;

    // Add a translation instruction
    this.translate(centerX, centerY);

    // Add a rotation instruction
    this.rotate(angle);

    // Translate back to adjust for the rotation around the center
    this.translate(-centerX, -centerY);

    // Draw the rotated path
    this.drawPath(path, paint);

    // Restore the original state of drawing instructions
    this.restore();
  }
}

extension PathExtensions on Path {
  Path rotateFromCenter(double angle) {
    final Rect bounds = getBounds();
    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy;

    final Matrix4 matrix = Matrix4.identity()
      ..translate(centerX, centerY)
      ..rotateZ(angle)
      ..translate(-centerX, -centerY);

    return transform(matrix.storage);
  }
}
