import 'package:flutter/material.dart';

class ScaleTap extends StatefulWidget {
  const ScaleTap({
    super.key,
    required this.onTap,
    required this.child,
    this.scale = 0.97,
    this.duration = const Duration(milliseconds: 130),
    this.semanticsLabel,
  });

  final VoidCallback onTap;
  final Widget child;
  final double scale;
  final Duration duration;
  final String? semanticsLabel;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
