import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButtonWhiteTheme extends StatelessWidget {
  final double blur;
  final double opacity;
  final double radius;
  final Widget child;
  final EdgeInsetsGeometry? padding; 
  final EdgeInsetsGeometry? margin; 
  final BoxBorder? border; 

  const GlassButtonWhiteTheme({
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
                Colors.grey.withOpacity(opacity), // Subtle grey
                const Color.fromARGB(255, 184, 182, 182).withOpacity(opacity * 0.4), // Slightly more transparent
              ],
              stops: [0.3, 1],
              center: Alignment.topLeft,
              radius: 1,
            ),
            border: border ??
                Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), // Light shadow for depth
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}