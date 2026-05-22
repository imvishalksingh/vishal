import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SpringyScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;
  final double scaleUp;

  const SpringyScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.97,
    this.scaleUp = 1.04,
  });

  @override
  State<SpringyScaleButton> createState() => _SpringyScaleButtonState();
}

class _SpringyScaleButtonState extends State<SpringyScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Scale begins at 1.0
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 2.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSpringAnimation(double target) {
    // Stiffness = 400, Damping = 15 as requested in skill.md.txt
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 400.0,
      damping: 15.0,
    );
    final simulation = SpringSimulation(
      spring,
      _controller.value, // start
      target, // end
      _controller.velocity, // current velocity
    );
    _controller.animateWith(simulation);
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _runSpringAnimation(widget.scaleDown);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _runSpringAnimation(_isHovered ? widget.scaleUp : 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _runSpringAnimation(_isHovered ? widget.scaleUp : 1.0);
  }

  void _onHover(bool hovered) {
    setState(() => _isHovered = hovered);
    if (!_isPressed) {
      _runSpringAnimation(hovered ? widget.scaleUp : 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value,
                child: child,
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
