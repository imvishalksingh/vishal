import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class BouncyButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;

  const BouncyButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.elevation = 2.0,
  }) : assert(child != null || label != null, 'Must provide either a child widget or a label string');

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
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
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 400.0,
      damping: 15.0,
    );
    final simulation = SpringSimulation(
      spring,
      _controller.value,
      target,
      _controller.velocity,
    );
    _controller.animateWith(simulation);
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _runSpringAnimation(0.97);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _runSpringAnimation(_isHovered ? 1.04 : 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _runSpringAnimation(_isHovered ? 1.04 : 1.0);
  }

  void _onHover(bool hovered) {
    setState(() => _isHovered = hovered);
    if (!_isPressed) {
      _runSpringAnimation(hovered ? 1.04 : 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color ?? Theme.of(context).primaryColor;
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
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withOpacity(0.2),
                    blurRadius: widget.elevation * 4,
                    offset: Offset(0, widget.elevation * 2),
                  ),
                ],
              ),
              child: widget.child ?? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
