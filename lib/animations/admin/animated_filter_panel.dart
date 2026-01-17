/// Widget animado para el panel de filtros
/// Ubicación: lib/animations/admin/animated_filter_panel.dart

import 'package:flutter/material.dart';

class AnimatedFilterPanel extends StatefulWidget {
  final bool showFilters;
  final Widget filtersContent;
  final Duration duration;
  final Curve curve;

  const AnimatedFilterPanel({
    super.key,
    required this.showFilters,
    required this.filtersContent,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedFilterPanel> createState() => _AnimatedFilterPanelState();
}

class _AnimatedFilterPanelState extends State<AnimatedFilterPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 1.0, curve: widget.curve),
    ));

    if (widget.showFilters) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showFilters != oldWidget.showFilters) {
      if (widget.showFilters) {
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
            child: Opacity(
              opacity: _opacity.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.filtersContent,
    );
  }
}
