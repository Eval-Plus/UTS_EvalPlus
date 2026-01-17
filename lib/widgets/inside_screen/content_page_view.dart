/// Widget para el PageView de contenidos con animaciones
/// Ubicación: lib/widgets/inside_screen/content_page_view.dart

import 'package:flutter/material.dart';

class ContentPageView extends StatelessWidget {
  final PageController pageController;
  final List<Widget> contents;
  final ValueChanged<int> onPageChanged;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const ContentPageView({
    super.key,
    required this.pageController,
    required this.contents,
    required this.onPageChanged,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: contents,
          ),
        ),
      ),
    );
  }
}
