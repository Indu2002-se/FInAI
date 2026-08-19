import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

/// Screen 10: Profile Screen
/// Wireframe: User info card + Edit Profile button + Financial summary + Logout
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.maybeWhen(
      authenticated: (user) => _buildProfileContent(context, ref, user),
      orElse: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not logged in'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  context.go(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.arrow_back,
              // color: Colors.black87,
              size: 16,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            // color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info card
              InfoCard(
                title: user?.firstName != null && user?.lastName != null
                    ? '${user!.firstName} ${user.lastName}'
                    : 'User Name',
                lines: [
                  user?.email ?? 'email@example.com',
                  'Colombo, Sri Lanka',
                ],
              ),
              const SizedBox(height: 16),
              // Edit profile button
              CustomButton(
                text: 'Edit Profile',
                variant: ButtonVariant.outline,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Profile feature coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Financial summary card
              InfoCard(
                title: 'Financial Profile Summary',
                lines: const [
                  'Monthly Income: Rs. 150,000',
                  'Savings: Rs. 45,000',
                  'Financial Health Score: 78 / 100',
                ],
              ),
              const SizedBox(height: 24),
              // Divider
              const Divider(height: 1),
              const SizedBox(height: 24),
              // Logout button
              CustomButton(
                text: 'Logout',
                variant: ButtonVariant.outline,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RouteNames.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation
      bottomNavigationBar: const BottomNavigation(currentIndex: 4),
    );
  }
}
