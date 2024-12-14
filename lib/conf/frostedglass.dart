import 'dart:ui';
import 'package:flutter/material.dart';

class Glassmorphism extends StatelessWidget {
  final double blur;
  final double opacity;
  final double radius;
  final Widget child;

  const Glassmorphism({
    Key? key,
    required this.blur,
    required this.opacity,
    required this.radius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.black.withOpacity(0.02),
                Colors.transparent.withOpacity(0.05),
              ],
              stops: [0.0, 0.5, 1.0],
              center: Alignment.topLeft,
              radius: 2,
            ),
            border: Border(
              top: BorderSide(
                width: 2,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.14),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
