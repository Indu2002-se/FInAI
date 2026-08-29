import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/datasources/native_transaction_capture.dart';
import '../providers/transaction_detection_provider.dart';

class TransactionDetectionBanner extends ConsumerWidget {
  const TransactionDetectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAllow = ref.watch(needsSmsAllowPromptProvider);
    final pendingCount = ref.watch(pendingCountProvider);

    if (needsAllow) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.sms_outlined, color: AppColors.orange, size: 22),
              SizedBox(width: AppTheme.spacing12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allow Messages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Grant SMS access to detect bank debit and credit alerts',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Allow',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () async {
                  final granted =
                      await NativeTransactionCapture.requestSmsPermission();
                  final ok = granted ||
                      await NativeTransactionCapture.hasSmsPermission();
                  ref.invalidate(smsPermissionGrantedProvider);
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'SMS permission is required to detect bank messages.',
                        ),
                      ),
                    );
                    return;
                  }
                  final imported = await ref
                      .read(transactionDetectionNotifierProvider.notifier)
                      .enableSmsAndSyncInbox();
                  ref.invalidate(smsPermissionGrantedProvider);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        imported > 0
                            ? 'Message detection is on. Found $imported debit/credit SMS.'
                            : 'Message detection is on.',
                      ),
                    ),
                  );
                  context.push(RouteNames.detectedTransactions);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sms_failed_outlined,
                  color: Colors.white, size: 22),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingCount New Transaction${pendingCount > 1 ? "s" : ""} Detected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bank SMS & notifications ready for confirmation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkTeal,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => context.push(RouteNames.detectedTransactions),
            ),
          ],
        ),
      ),
    );
  }
}
