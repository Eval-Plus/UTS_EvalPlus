/// Animación de escritura tipo máquina de escribir
/// Ubicación: lib/animations/admin/typewriter_text_animation.dart
library;

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 30),
    this.delay = Duration.zero,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    
    final totalDuration = widget.duration * widget.text.length;
    
    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Iniciar animación después del delay
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _startAnimation();
        }
      });
    } else {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (_hasStarted) return;
    _hasStarted = true;
    
    _controller.forward().then((_) {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _characterCount.value);
        
        return Text(
          displayText,
          style: widget.style,
        );
      },
    );
  }
}