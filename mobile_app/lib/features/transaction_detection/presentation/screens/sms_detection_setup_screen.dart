import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/datasources/native_transaction_capture.dart';
import '../providers/transaction_detection_provider.dart';

/// Shown once per new account so the user can allow SMS debit/credit detection.
class SmsDetectionSetupScreen extends ConsumerStatefulWidget {
  const SmsDetectionSetupScreen({super.key, this.userKey});

  final String? userKey;

  static String prefsKeyForUser(String userKey) =>
      'sms_detection_setup_done_${userKey.toLowerCase()}';

  static Future<bool> hasCompletedForUser(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKeyForUser(userKey)) ?? false;
  }

  static Future<void> markCompletedForUser(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKeyForUser(userKey), true);
  }

  @override
  ConsumerState<SmsDetectionSetupScreen> createState() =>
      _SmsDetectionSetupScreenState();
}

class _SmsDetectionSetupScreenState
    extends ConsumerState<SmsDetectionSetupScreen> {
  bool _busy = false;

  String get _userKey {
    final fromRoute = widget.userKey?.trim();
    if (fromRoute != null && fromRoute.isNotEmpty) return fromRoute;
    return 'unknown';
  }

  Future<void> _markDone() =>
      SmsDetectionSetupScreen.markCompletedForUser(_userKey);

  Future<void> _continueNext() async {
    if (!mounted) return;
    context.go(RouteNames.onboardingWelcome);
  }

  Future<void> _onAllow() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final granted = await NativeTransactionCapture.requestSmsPermission();
      if (!mounted) return;

      final hasPermission =
          granted || await NativeTransactionCapture.hasSmsPermission();

      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please tap Allow on the system permission dialog to detect bank SMS.',
            ),
          ),
        );
        // Stay on this screen so they can try again.
        return;
      }

      final imported = await ref
          .read(transactionDetectionNotifierProvider.notifier)
          .enableSmsAndSyncInbox();

      await _markDone();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imported > 0
                ? 'Detected $imported debit/credit SMS. New bank messages will appear automatically.'
                : 'SMS access allowed. Debit/credit messages will appear when banks send them.',
          ),
        ),
      );

      // Always continue into the onboarding wizard after Allow.
      await _continueNext();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not finish SMS setup: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      try {
        final current = await ref.read(detectionSettingsProvider.future);
        await ref
            .read(transactionDetectionNotifierProvider.notifier)
            .updateSettings(current.copyWith(smsEnabled: false));
      } catch (_) {}
      await _markDone();
      await _continueNext();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.tealExtraLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 44,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Allow SMS detection?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'FinAI will ask for SMS permission, then detect debit and credit bank alerts already on your phone and new ones as they arrive.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 28),
              const _BenefitRow(
                icon: Icons.arrow_downward,
                text: 'Detect debit / payment SMS',
              ),
              const SizedBox(height: 10),
              const _BenefitRow(
                icon: Icons.arrow_upward,
                text: 'Detect credit / deposit SMS',
              ),
              const SizedBox(height: 10),
              const _BenefitRow(
                icon: Icons.touch_app_outlined,
                text: 'Confirm each one as expense or income',
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _busy ? null : _onAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Allow SMS Access',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _onSkip,
                child: Text(
                  'Not now',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.darkTeal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// After signup / incomplete-profile login: show SMS allow screen once per account.
Future<void> goAfterSignupAuth(
  BuildContext context, {
  required bool profileComplete,
  required String userKey,
}) async {
  if (profileComplete) {
    context.go(RouteNames.dashboard);
    return;
  }

  final setupDone =
      await SmsDetectionSetupScreen.hasCompletedForUser(userKey);
  if (!context.mounted) return;
  if (!setupDone) {
    context.go(
      '${RouteNames.smsDetectionSetup}?user=${Uri.encodeComponent(userKey)}',
    );
    return;
  }
  context.go(RouteNames.onboardingWelcome);
}
