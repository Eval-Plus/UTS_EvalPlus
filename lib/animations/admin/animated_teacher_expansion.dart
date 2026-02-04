/// Widget animado para expansión de tarjeta de docente
/// Ubicación: lib/animations/admin/animated_teacher_expansion.dart
library;

import 'package:flutter/material.dart';

class AnimatedTeacherExpansion extends StatefulWidget {
  final bool isExpanded;
  final Widget expandedContent;
  final Duration duration;
  final Curve curve;

  const AnimatedTeacherExpansion({
    super.key,
    required this.isExpanded,
    required this.expandedContent,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<AnimatedTeacherExpansion> createState() =>
      _AnimatedTeacherExpansionState();
}

class _AnimatedTeacherExpansionState extends State<AnimatedTeacherExpansion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _opacity;
  late Animation<Offset> _slideOffset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animación de altura
    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Animación de opacidad (comienza un poco después)
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 1.0, curve: widget.curve),
    ));

    // Animación de deslizamiento sutil
    _slideOffset = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1, 1.0, curve: widget.curve),
    ));

    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedTeacherExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: FadeTransition(
              opacity: _opacity,
              child: SlideTransition(
                position: _slideOffset,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.expandedContent,
    );
  }
}
