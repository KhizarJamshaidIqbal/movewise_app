import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
    : super(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Create combined animations for a more dynamic effect
    var curve = Curves.easeOutCubic;
    var curveTween = CurveTween(curve: curve);

    var begin = const Offset(1.0, 0.0);
    var end = Offset.zero;
    var slideTween = Tween(begin: begin, end: end).chain(curveTween);

    var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(
          CurveTween(curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
        )
        .animate(animation);

    var scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).chain(CurveTween(curve: curve)).animate(animation);

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(scale: scaleAnimation, child: child),
      ),
    );
  }
}
