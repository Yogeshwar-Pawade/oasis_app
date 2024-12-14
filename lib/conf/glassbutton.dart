import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final double blur;
  final double opacity;
  final double radius;
  final Widget child;
  final EdgeInsetsGeometry? padding; // Optional padding for content
  final EdgeInsetsGeometry? margin; // Optional margin for external spacing
  final BoxBorder? border; // Optional border customization

  const GlassButton({
    Key? key,
    required this.blur,
    required this.opacity,
    required this.radius,
    required this.child,
    this.padding,
    this.margin,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.transparent,
              ],
              stops: [0.0, 1.0],
              center: Alignment.topLeft,
              radius: 2,
            ),
            border: border ??
                Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
            borderRadius: BorderRadius.circular(radius),
            // Removed boxShadow property
          ),
          child: child,
        ),
      ),
    );
  }
}