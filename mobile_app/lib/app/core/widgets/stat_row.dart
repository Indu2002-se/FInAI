import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StatItem {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
  final String? trend; // e.g., "+5.2%"
  final bool? trendIsPositive;

  StatItem({
    required this.label,
    required this.value,
    this.color,
    this.icon,
    this.trend,
    this.trendIsPositive,
  });
}

class StatRow extends StatelessWidget {
  final List<StatItem> items;
  final bool showDividers;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const StatRow({
    super.key,
    required this.items,
    this.showDividers = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Row(
        children: _buildStatItems(theme),
      ),
    );
  }

  List<Widget> _buildStatItems(ThemeData theme) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      widgets.add(
        Expanded(
          child: _StatItemWidget(item: item, theme: theme),
        ),
      );

      // Add divider between items
      if (showDividers && i < items.length - 1) {
        widgets.add(
          Container(
            width: 1,
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
            color: AppColors.border,
          ),
        );
      }
    }

    return widgets;
  }
}

class _StatItemWidget extends StatelessWidget {
  final StatItem item;
  final ThemeData theme;

  const _StatItemWidget({
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Container(
            padding: EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: (item.color ?? AppColors.darkTeal).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              item.icon,
              color: item.color ?? AppColors.darkTeal,
              size: 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing8),
        ],
        Text(
          item.value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: item.color ?? AppColors.darkGrey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing4),
        Text(
          item.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mediumGrey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.trend != null) ...[
          SizedBox(height: AppTheme.spacing4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
              vertical: AppTheme.spacing4,
            ),
            decoration: BoxDecoration(
              color: item.trendIsPositive == true
                  ? AppColors.successLight
                  : item.trendIsPositive == false
                      ? AppColors.errorLight
                      : AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.trendIsPositive == true
                      ? Icons.trending_up
                      : item.trendIsPositive == false
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  size: 12,
                  color: item.trendIsPositive == true
                      ? AppColors.success
                      : item.trendIsPositive == false
                          ? AppColors.error
                          : AppColors.mediumGrey,
                ),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  item.trend!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: item.trendIsPositive == true
                        ? AppColors.success
                        : item.trendIsPositive == false
                            ? AppColors.error
                            : AppColors.mediumGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Simplified Single Stat Card
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool? trendIsPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
    this.trendIsPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Material(
        // color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null)
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: (color ?? AppColors.darkTeal).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      color: color ?? AppColors.darkTeal,
                      size: 24,
                    ),
                  ),
                SizedBox(height: AppTheme.spacing12),
                Text(
                  value,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color ?? AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (trend != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: trendIsPositive == true
                              ? AppColors.successLight
                              : trendIsPositive == false
                                  ? AppColors.errorLight
                                  : AppColors.extraLightGrey,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trendIsPositive == true
                                  ? Icons.trending_up
                                  : trendIsPositive == false
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                              size: 12,
                              color: trendIsPositive == true
                                  ? AppColors.success
                                  : trendIsPositive == false
                                      ? AppColors.error
                                      : AppColors.mediumGrey,
                            ),
                            SizedBox(width: AppTheme.spacing4),
                            Text(
                              trend!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: trendIsPositive == true
                                    ? AppColors.success
                                    : trendIsPositive == false
                                        ? AppColors.error
                                        : AppColors.mediumGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
