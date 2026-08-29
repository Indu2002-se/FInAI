import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Enhanced scaffold with white card container and floating nav clearance
class FinaiScaffold extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsets contentPadding;
  final bool useCardContainer;

  const FinaiScaffold({
    Key? key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.contentPadding = const EdgeInsets.all(AppTheme.spacing16),
    this.useCardContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main content in scrollable white card
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: AppTheme.spacing90, // Clearance for floating nav
            ),
            child: useCardContainer
                ? Container(
                    margin: EdgeInsets.only(top: AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusXLarge),
                        topRight: Radius.circular(AppTheme.radiusXLarge),
                      ),
                      boxShadow: AppTheme.shadowMedium,
                    ),
                    child: Padding(
                      padding: contentPadding,
                      child: child,
                    ),
                  )
                : Padding(
                    padding: contentPadding,
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }
}
