import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StarRating extends StatefulWidget {
  final double initialRating;
  final bool interactive;
  final double size;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    this.initialRating = 0,
    this.interactive = false,
    this.size = 28,
    this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < _rating.floor();
        final half = !filled && i < _rating;
        return GestureDetector(
          onTap: widget.interactive
              ? () {
                  setState(() => _rating = i + 1.0);
                  widget.onRatingChanged?.call(_rating);
                }
              : null,
          child: _AnimatedStar(
            filled: filled || half,
            half: half && !filled,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  final bool filled;
  final bool half;
  final double size;

  const _AnimatedStar({required this.filled, required this.half, required this.size});

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedStar old) {
    super.didUpdateWidget(old);
    if (widget.filled && !old.filled) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: widget.size,
          color: widget.filled ? AppColors.gold500 : AppColors.carbon600,
        ),
      ),
    );
  }
}
