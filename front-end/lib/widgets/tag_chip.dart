// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:docflow/config/app_theme.dart';

class TagChip extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  const TagChip({
    super.key,
    required this.label,
    this.onTap,
    this.selected = false,
  });

  @override
  State<TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _pressed || widget.selected;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kAccent : kAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: active ? Colors.white : kAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
