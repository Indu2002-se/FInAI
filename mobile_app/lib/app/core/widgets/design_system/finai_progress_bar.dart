import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Custom progress bar with percentage display
class FinaiProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final BorderRadius borderRadius;
  final bool showPercentage;
  final TextStyle? percentageStyle;
  final Duration animationDuration;

  const FinaiProgressBar({
    Key? key,
    required this.value,
    this.height = 8,
    this.backgroundColor = AppColors.extraLightGrey,
    this.progressColor = AppColors.success,
    BorderRadius? borderRadius,
    this.showPercentage = false,
    this.percentageStyle,
    this.animationDuration = const Duration(milliseconds: 500),
  })  : borderRadius = borderRadius ??
            const BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: percentageStyle ??
                Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ],
    );
  }
}

/// Circular progress indicator with percentage
class FinaiCircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final String? label;
  final TextStyle? labelStyle;

  const FinaiCircularProgress({
    Key? key,
    required this.value,
    this.size = 120,
    this.progressColor = AppColors.success,
    this.backgroundColor = AppColors.extraLightGrey,
    this.strokeWidth = 8,
    this.label,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: labelStyle ??
                    Theme.of(context).textTheme.displaySmall,
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label!,
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated number counter
class FinaiNumberCounter extends StatefulWidget {
  final double endValue;
  final Duration duration;
  final TextStyle textStyle;
  final String suffix;
  final String prefix;

  const FinaiNumberCounter({
    Key? key,
    required this.endValue,
    this.duration = const Duration(milliseconds: 1000),
    required this.textStyle,
    this.suffix = '',
    this.prefix = '',
  }) : super(key: key);

  @override
  State<FinaiNumberCounter> createState() => _FinaiNumberCounterState();
}

class _FinaiNumberCounterState extends State<FinaiNumberCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: widget.endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toStringAsFixed(0)}${widget.suffix}',
          style: widget.textStyle,
        );
      },
    );
  }
}
