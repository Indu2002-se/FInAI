import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/datasources/native_transaction_capture.dart';
import '../../data/datasources/transaction_parser.dart';
import '../../data/models/detected_transaction.dart';
import '../../data/models/detection_settings.dart';
import '../providers/transaction_detection_provider.dart';

class DetectionSettingsPage extends ConsumerStatefulWidget {
  const DetectionSettingsPage({super.key});

  @override
  ConsumerState<DetectionSettingsPage> createState() =>
      _DetectionSettingsPageState();
}

class _DetectionSettingsPageState extends ConsumerState<DetectionSettingsPage> {
  final TextEditingController _testMessageController = TextEditingController();
  DetectedTransactionModel? _liveParsedResult;

  @override
  void dispose() {
    _testMessageController.dispose();
    super.dispose();
  }

  void _parseLive(String text) {
    if (text.trim().isEmpty) {
      setState(() => _liveParsedResult = null);
      return;
    }
    final parsed = TransactionParser.parseMessage(
      body: text,
      sourceType: 'TEST',
    );
    setState(() => _liveParsedResult = parsed);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(detectionSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Detection Settings'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading settings: ')),
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tealExtraLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkTeal.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security,
                      color: AppColors.darkTeal,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your SMS & notifications are processed 100% locally on this device. Full message text is never uploaded to the server.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTeal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Settings Toggles Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'SMS Transaction Detection',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Scan incoming bank SMS messages for debit/credit alerts',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: settings.smsEnabled,
                        activeColor: AppColors.darkTeal,
                        onChanged: (val) async {
                          if (val &&
                              !await NativeTransactionCapture.requestSmsPermission()) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Allow SMS permission, then turn on detection.',
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                          _updateSettings(settings.copyWith(smsEnabled: val));
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Notification Detection',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Capture transaction alerts from banking and payment apps',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: settings.notificationEnabled,
                        activeColor: AppColors.darkTeal,
                        onChanged: (val) async {
                          if (val) {
                            await NativeTransactionCapture.openNotificationListenerSettings();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Enable FinAI notification access, then return and turn this on.',
                                  ),
                                ),
                              );
                            }
                          }
                          _updateSettings(
                            settings.copyWith(notificationEnabled: val),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Require Confirmation',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Review every detected transaction before adding to expenses/income',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: settings.confirmationRequired,
                        activeColor: AppColors.darkTeal,
                        onChanged: (val) {
                          _updateSettings(
                            settings.copyWith(confirmationRequired: val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Parser Sandbox / Simulator
              const Text(
                'LIVE PARSER SANDBOX',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paste any SMS or notification text to test the regex extraction rules:',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _testMessageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Commercial Bank Alert: Rs. 4,500.00 debited from A/C **4589 at Keells Super...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        onChanged: _parseLive,
                      ),
                      const SizedBox(height: 12),

                      if (_liveParsedResult != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ' • Rs. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _liveParsedResult!.transactionType ==
                                              'DEBIT'
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkTeal,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '% Match',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (_liveParsedResult!.merchant != null)
                                Text(
                                  '• Merchant: ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_liveParsedResult!.suggestedCategory != null)
                                Text(
                                  '• Category: ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_liveParsedResult!.accountReference != null)
                                Text(
                                  '• Account: ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_liveParsedResult!.reference != null)
                                Text(
                                  '• Reference: ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.add_task, size: 16),
                            label: const Text('Ingest as Pending Transaction'),
                            onPressed: () async {
                              final notifier = ref.read(
                                transactionDetectionNotifierProvider.notifier,
                              );
                              final res = await notifier.recordTransaction(
                                _liveParsedResult!,
                              );
                              if (mounted && res != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Transaction added to pending queue!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _testMessageController.clear();
                                setState(() => _liveParsedResult = null);
                              }
                            },
                          ),
                        ),
                      ] else if (_testMessageController.text.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Could not identify an amount or financial keywords in this message.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Supported Banks List
              const Text(
                'SUPPORTED BANKS & WALLETS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'Commercial Bank',
                          'Sampath Bank',
                          'Hatton National Bank (HNB)',
                          'Bank of Ceylon (BOC)',
                          'People\'s Bank',
                          'Nations Trust Bank (NTB)',
                          'DFCC Bank',
                          'Seylan Bank',
                          'FriMi',
                          'Dialog eZ Cash',
                          'Mobitel mCash',
                          'Genie',
                          'HSBC / Standard Chartered',
                        ].map((bank) {
                          return Chip(
                            label: Text(
                              bank,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: AppColors.tealExtraLight,
                            avatar: const Icon(
                              Icons.account_balance,
                              size: 14,
                              color: AppColors.darkTeal,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateSettings(DetectionSettingsModel newSettings) async {
    final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
    await notifier.updateSettings(newSettings);
  }
}
