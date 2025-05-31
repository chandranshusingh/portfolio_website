import 'package:flutter/material.dart';
import '../utils/error_handler.dart'; // Import ErrorHandler

/// A floating action button that appears when scrolling down and scrolls to top when pressed
class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showThreshold;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.showThreshold = 300,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> with SingleTickerProviderStateMixin {
  // Only one AnimationController is created and disposed, so SingleTickerProviderStateMixin is correct here.
  bool _showButton = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    // Use ErrorHandler.safeDisposeController for robust disposal
    ErrorHandler.safeDisposeController(_controller, name: 'ScrollToTopButtonController');
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.scrollController.offset >= widget.showThreshold;
    if (shouldShow != _showButton) {
      setState(() => _showButton = shouldShow);
      if (shouldShow) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
} 