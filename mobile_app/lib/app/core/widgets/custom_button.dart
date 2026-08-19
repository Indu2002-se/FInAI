import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, text, success, danger }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null && !isLoading;

    Widget buttonChild = isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(theme),
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                SizedBox(width: AppTheme.spacing8),
              ],
              if (icon != null) ...[
                icon!,
                SizedBox(width: AppTheme.spacing8),
              ],
              Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: _getFontSize(),
                  color: _getForegroundColor(theme),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: AppTheme.spacing8),
                trailingIcon!,
              ],
            ],
          );

    return Container(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: variant == ButtonVariant.primary
          ? BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: isDisabled || isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.darkTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            )
          : null,
      child: Material(
        color: variant == ButtonVariant.primary
            ? Colors.transparent
            : _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              border: _getBorder(theme),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(),
              vertical: _getVerticalPadding(),
            ),
            child: buttonChild,
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 13;
      case ButtonSize.medium:
        return 15;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppTheme.spacing16;
      case ButtonSize.medium:
        return AppTheme.spacing20;
      case ButtonSize.large:
        return AppTheme.spacing24;
    }
  }

  double _getVerticalPadding() {
    return 0; // Height is controlled by container
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.darkTeal;
      case ButtonVariant.secondary:
        return AppColors.extraLightGrey;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.success:
        return AppColors.success;
      case ButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.success:
      case ButtonVariant.danger:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.darkGrey;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return AppColors.darkTeal;
    }
  }

  Border? _getBorder(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.outline:
        return Border.all(
          color: AppColors.darkTeal,
          width: 2,
        );
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.text:
      case ButtonVariant.success:
      case ButtonVariant.danger:
        return null;
    }
  }
}
