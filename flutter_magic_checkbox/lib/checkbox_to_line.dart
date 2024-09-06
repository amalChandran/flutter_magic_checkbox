import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SquareUnravelAnimation extends StatefulWidget {
  @override
  _SquareUnravelAnimationState createState() => _SquareUnravelAnimationState();
}

class _SquareUnravelAnimationState extends State<SquareUnravelAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _unravelAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _lineAnimation;
  bool _isChecked = false;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        print("_controller status : $status");
        if (status == AnimationStatus.completed && !_isChecked) {
          _confettiController.reset();
          _confettiController.forward();
          print("_confettiController.forward()");
        }
      });

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )
      ..addStatusListener((status) {
        print("_confettiController status : $status");
      })
      ..addListener(() {
        print("Confetti animation value: ${_confettiAnimation.value}");
      });

    _rotationAnimation = Tween<double>(begin: 0, end: math.pi / 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.25, curve: Curves.easeInOut),
      ),
    );

    _unravelAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _confettiAnimation =
        // Tween<double>(begin: 0, end: 1).animate(_confettiController);

        Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _confettiController,
        curve: Interval(0.0, 1.0, curve: Curves.easeOutCirc),
      ),
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 1.0, curve: Curves.easeInCirc),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimationProgress(double progress) {
    _controller.value = progress.clamp(0.0, 1.0);
    setState(() {
      _dragProgress = progress;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double dragDistance = details.primaryDelta ?? 0;
    double totalWidth = context.size?.width ?? 300;
    double progress = _dragProgress + (dragDistance / totalWidth);

    _updateAnimationProgress(progress.clamp(0.0, 1.0));
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    final double flingVelocity = details.primaryVelocity! / 300;
    const double threshold = 0.2; // Adjust this value to change sensitivity

    if (flingVelocity.abs() > 1 || _dragProgress.abs() > threshold) {
      double targetValue;
      if (_isChecked) {
        targetValue =
            flingVelocity < 0 || _dragProgress < 1 - threshold ? 0.0 : 1.0;
      } else {
        targetValue =
            flingVelocity > 0 || _dragProgress > threshold ? 1.0 : 0.0;
      }

      _controller
          .animateTo(targetValue,
              duration: Duration(milliseconds: 300), curve: Curves.easeOut)
          .then((_) {
        setState(() {
          _isChecked = targetValue == 1.0;
          _dragProgress = targetValue;
        });
      });
    } else {
      // If the drag was very small, revert to the original state
      _controller.animateTo(_isChecked ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _confettiController]),
          builder: (context, child) {
            return SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    //a stacked layout
                    GestureDetector(
                      onTap: () {
                        if (_isChecked) {
                          _controller.reverse();
                        } else {
                          _controller.reset();
                          _controller.forward();
                        }
                        _isChecked = !_isChecked;
                      },
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _rotationAnimation,
                          _unravelAnimation,
                          _confettiAnimation
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(24, 24),
                            painter: SquareUnravelPainter(
                                _rotationAnimation.value,
                                _unravelAnimation.value,
                                _confettiAnimation.value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          const Row(
                            children: [
                              SizedBox(width: 16),
                              Text(
                                "Do a very important task",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue,
                                  // fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                          AnimatedBuilder(
                            animation: Listenable.merge([_lineAnimation]),
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(double.infinity, 24),
                                painter:
                                    AnimatedLinePainter(_lineAnimation.value),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          },
        ));
  }
}

class SquareUnravelPainter extends CustomPainter {
  final double rotationValue;
  final double unravelValue;
  final double confettiValue;

  SquareUnravelPainter(
      this.rotationValue, this.unravelValue, this.confettiValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 249, 250, 250)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tickPaint = Paint()
      ..color = Color.fromARGB(255, 68, 242, 11)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Apply rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(
        -math.pi / 4 * rotationValue); // Rotate 45 degrees counter-clockwise
    canvas.translate(-center.dx, -center.dy);

    final tickPath = Path();
    tickPath.moveTo(0, size.height / 2);
    tickPath.lineTo(0, size.height);
    tickPath.lineTo(size.width, size.height);
    canvas.drawPath(tickPath, tickPaint);

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();

    if (unravelValue < 1) {
      // Animate the path traversal
      final pathMetrics = path.computeMetrics().last;
      final extractPath = pathMetrics.extractPath(
        pathMetrics.length * unravelValue,
        pathMetrics.length,
      );

      // Draw the animated part of the path
      canvas.drawPath(extractPath, paint..color = Colors.blue);
    }

    canvas.restore();
    drawConfetti(canvas, size, confettiValue);
  }

  void drawConfetti(Canvas canvas, Size size, double confettiValue) {
    print("Drawing confetti with value: $confettiValue");
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 10;
    final maxRadius = size.width * 2 * confettiValue; //size.width / 2;
    final particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = i * (2 * pi / particleCount);
      final color = Color.fromARGB(255, 68, 242, 11);

      final particleRadius = confettiValue * maxRadius;
      final particleX = centerX + cos(angle) * particleRadius;
      final particleY = centerY + sin(angle) * particleRadius;

      final particleSize = 5 * (1 - (confettiValue - 0.5).abs() * 2);

      if (particleSize > 0) {
        final paint = Paint()..color = color.withOpacity(1 - confettiValue);
        canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SquareUnravelPainter oldDelegate) =>
      oldDelegate.rotationValue != rotationValue ||
      oldDelegate.unravelValue != unravelValue ||
      oldDelegate.confettiValue != confettiValue;
}

class AnimatedLinePainter extends CustomPainter {
  final double animationValue;

  AnimatedLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (animationValue > 0) {
      const maxShiftAmount = 16;
      const shiftCurve = Curves.easeInOut;

      // Calculate shift amount using a smooth curve
      double shiftAmount =
          maxShiftAmount * shiftCurve.transform(animationValue);

      // Calculate start and end positions
      double startX = shiftAmount * animationValue;
      double endX = size.width * animationValue + startX;

      final start = Offset(startX, size.height / 2);
      final end = Offset(endX, size.height / 2);

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedLinePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
