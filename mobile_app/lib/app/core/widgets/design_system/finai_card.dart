import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Quick action item for balance card buttons
class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Standard white rounded card for content
class FinaiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color backgroundColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Border? border;

  const FinaiCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppTheme.radiusLarge,
    this.backgroundColor = AppColors.white,
    this.shadows,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppTheme.shadowSoft,
        border: border,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Dark rounded card for financial balance display
class FinaiBalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final String? cardNumber;
  final List<BalanceItem>? items;
  final List<QuickAction>? quickActions;
  final EdgeInsets padding;
  final Color textColor;

  const FinaiBalanceCard({
    Key? key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.cardNumber,
    this.items,
    this.quickActions,
    this.padding = const EdgeInsets.all(24),
    this.textColor = AppColors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.shadowStrong,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card number (if provided)
          if (cardNumber != null) ...[
            Row(
              children: [
                Icon(Icons.credit_card, 
                  color: textColor.withOpacity(0.8),
                  size: 16,
                ),
                SizedBox(width: AppTheme.spacing8),
                Text(cardNumber!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Divider(color: textColor.withOpacity(0.2), height: 1),
            SizedBox(height: AppTheme.spacing12),
          ],

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
          if (items != null && items!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items!
                  .map((item) => _buildBalanceItem(item, textColor))
                  .toList(),
            ),
          ],
          // Quick actions (if provided)
          if (quickActions != null && quickActions!.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacing20),
            _buildQuickActions(quickActions!, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceItem(BalanceItem item, Color textColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(List<QuickAction> actions, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) {
        return GestureDetector(
          onTap: action.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    action.icon,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class BalanceItem {
  final String label;
  final String amount;

  BalanceItem({
    required this.label,
    required this.amount,
  });
}

/// Progress card for savings goals/plans with icon support
class FinaiGoalCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String currentAmount;
  final String targetAmount;
  final double progressPercent;
  final String timeRemaining;
  final VoidCallback? onTap;

  const FinaiGoalCard({
    Key? key,
    required this.title,
    this.icon,
    this.iconColor,
    required this.currentAmount,
    required this.targetAmount,
    required this.progressPercent,
    required this.timeRemaining,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FinaiCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: iconColor ?? AppColors.primaryDark,
                        size: 24,
                      ),
                      SizedBox(width: AppTheme.spacing8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentAmount,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    targetAmount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeRemaining,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 8),
          Text(
            '${(progressPercent * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progressPercent,
        minHeight: 8,
        backgroundColor: AppColors.extraLightGrey,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.success,
        ),
      ),
    );
  }
}
