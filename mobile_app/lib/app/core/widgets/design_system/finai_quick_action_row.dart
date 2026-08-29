import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Quick action item for action rows
class QuickActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}

/// Row of 4 quick action buttons
class FinaiQuickActionRow extends StatelessWidget {
  final List<QuickActionItem> actions;
  final double spacing;

  const FinaiQuickActionRow({
    Key? key,
    required this.actions,
    this.spacing = AppTheme.spacing12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(
      actions.length <= 4,
      'Maximum 4 quick actions allowed in a row',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _buildQuickActionButton(action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionButton(QuickActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.backgroundColor ?? AppColors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSoft,
            ),
            child: Center(
              child: Icon(
                action.icon,
                color: action.iconColor ?? AppColors.primaryDark,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            action.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
