import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum CardVariant { default_, elevated, outlined, gradient }

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String>? lines;
  final String? rightText;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final CardVariant variant;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Widget? footer;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.lines,
    this.rightText,
    this.onTap,
    this.trailing,
    this.leading,
    this.variant = CardVariant.outlined,
    this.backgroundColor,
    this.padding,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: variant == CardVariant.gradient
            ? AppColors.cardGradient
            : null,
        color: variant != CardVariant.gradient
            ? (backgroundColor ?? AppColors.white)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: variant == CardVariant.outlined
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: variant == CardVariant.elevated
            ? AppTheme.shadowCard
            : variant == CardVariant.gradient
                ? AppTheme.shadowSoft
                : null,
      ),
      child: Material(
        // color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: padding ??
                EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      SizedBox(width: AppTheme.spacing12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (rightText != null)
                      Text(
                        rightText!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.mediumGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (trailing != null) trailing!,
                    if (onTap != null && rightText == null && trailing == null)
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.mediumGrey,
                        size: 20,
                      ),
                  ],
                ),
                if (lines != null && lines!.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacing12),
                  ...lines!.map((line) => Padding(
                        padding: EdgeInsets.only(
                          bottom: AppTheme.spacing8,
                        ),
                        child: Text(
                          line,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkGrey,
                            height: 1.5,
                          ),
                        ),
                      )),
                ],
                if (footer != null) ...[
                  SizedBox(height: AppTheme.spacing12),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Specialized Info Cards
class SuccessCard extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? icon;

  const SuccessCard({
    super.key,
    required this.title,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      lines: message != null ? [message!] : null,
      backgroundColor: AppColors.successLight,
      leading: icon ??
          Container(
            padding: EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.white,
              size: 20,
            ),
          ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? icon;

  const ErrorCard({
    super.key,
    required this.title,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      lines: message != null ? [message!] : null,
      backgroundColor: AppColors.errorLight,
      leading: icon ??
          Container(
            padding: EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
          ),
    );
  }
}

class WarningCard extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? icon;

  const WarningCard({
    super.key,
    required this.title,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      lines: message != null ? [message!] : null,
      backgroundColor: AppColors.warningLight,
      leading: icon ??
          Container(
            padding: EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.warning_amber,
              color: AppColors.white,
              size: 20,
            ),
          ),
    );
  }
}
