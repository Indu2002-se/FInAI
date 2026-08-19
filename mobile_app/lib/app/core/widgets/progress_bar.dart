import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProgressBarWidget extends StatelessWidget {
  final String? label;
  final double progress; // 0.0 to 1.0
  final String? valueLabel;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;
  final bool animated;

  const ProgressBarWidget({
    super.key,
    this.label,
    required this.progress,
    this.valueLabel,
    this.color,
    this.backgroundColor,
    this.height = 10,
    this.showPercentage = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? _getColorForProgress(progress);
    final bgColor = backgroundColor ?? AppColors.extraLightGrey;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                if (showPercentage)
                  Text(
                    valueLabel ?? '$percentage%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: animated
                ? TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: progress),
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                progressColor,
                                progressColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(height / 2),
                            boxShadow: [
                              BoxShadow(
                                color: progressColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(double progress) {
    if (progress >= 0.8) return AppColors.error;
    if (progress >= 0.6) return AppColors.warning;
    return AppColors.success;
  }
}

// Circular Progress Widget
class CircularProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final String? centerText;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.label,
    this.centerText,
    this.size = 120,
    this.strokeWidth = 12,
    this.color,
    this.backgroundColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? AppColors.darkTeal;
    final bgColor = backgroundColor ?? AppColors.extraLightGrey;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: strokeWidth,
                      valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      strokeWidth: strokeWidth,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center text
                  if (showPercentage || centerText != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerText ?? '$percentage%',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        if (label != null) ...[
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            label!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
