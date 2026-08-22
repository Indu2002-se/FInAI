import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/datasources/sms_datasource.dart';
import '../../data/models/detected_transaction.dart';
import '../providers/transaction_detection_provider.dart';

class DetectedTransactionsPage extends ConsumerStatefulWidget {
  const DetectedTransactionsPage({super.key});

  @override
  ConsumerState<DetectedTransactionsPage> createState() => _DetectedTransactionsPageState();
}

class _DetectedTransactionsPageState extends ConsumerState<DetectedTransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingDetectedTransactionsProvider);
    final allAsync = ref.watch(allDetectedTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Auto-Detected Transactions'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Detection Settings',
            onPressed: () => context.push(RouteNames.detectionSettings),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(pendingDetectedTransactionsProvider);
              ref.invalidate(allDetectedTransactionsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkTeal,
          unselectedLabelColor: AppColors.mediumGrey,
          indicatorColor: AppColors.darkTeal,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Review'),
                  if (pendingAsync.value != null && pendingAsync.value!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pendingAsync.value!.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'All History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(pendingAsync),
          _buildHistoryTab(allAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.darkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.science_outlined),
        label: const Text('Simulate Message'),
        onPressed: _showSimulationDialog,
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildPendingTab(AsyncValue<List<DetectedTransactionModel>> asyncVal) {
    return asyncVal.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading pending transactions: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(pendingDetectedTransactionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.darkTeal.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No Pending Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New bank SMS messages or notifications will appear here for one-tap confirmation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_to_photos_outlined),
                    label: const Text('Test with Sample SMS'),
                    onPressed: _showSimulationDialog,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildTransactionCard(item, isPending: true);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(AsyncValue<List<DetectedTransactionModel>> asyncVal) {
    return asyncVal.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No detected transaction history yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildTransactionCard(item, isPending: false);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(DetectedTransactionModel item, {required bool isPending}) {
    final isDebit = item.transactionType == 'DEBIT';
    final isCredit = item.transactionType == 'CREDIT';
    final typeColor = isDebit ? AppColors.error : (isCredit ? AppColors.success : Colors.blue);
    final typeLabel = isDebit ? 'Debit (Expense)' : (isCredit ? 'Credit (Income)' : 'Transfer');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Source badge, Confidence, Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.sourceType == 'SMS' ? Icons.sms_outlined : Icons.notifications_active_outlined,
                        size: 13,
                        color: AppColors.darkTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.sourceType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.sourceApp != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.sourceApp!,
                      style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount & Merchant
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.merchant ?? (isDebit ? 'Merchant Purchase' : 'Deposit'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.suggestedCategory != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Suggested: ${item.suggestedCategory}',
                          style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${isDebit ? '-' : (isCredit ? '+' : '')}${_currencyFmt.format(item.amount)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Metadata Row: Account, Ref, Confidence
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (item.accountReference != null)
                  _buildMetaTag(Icons.credit_card, item.accountReference!),
                if (item.reference != null)
                  _buildMetaTag(Icons.tag, item.reference!),
                _buildMetaTag(
                  Icons.verified_outlined,
                  '${(item.confidence * 100).toInt()}% Match',
                ),
              ],
            ),

            if (isPending) ...[
              const Divider(height: 24),
              // Action Buttons for Pending item
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDebit ? AppColors.darkTeal : AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(isDebit ? Icons.add_shopping_cart : Icons.add_card, size: 16),
                      label: Text(isDebit ? 'Add Expense' : 'Add Income'),
                      onPressed: () => _confirmDirect(item),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Edit'),
                      onPressed: () => _openReviewScreen(item),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    tooltip: 'Ignore',
                    onPressed: () => _ignoreTransaction(item.id),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${item.status}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.status == 'CONFIRMED'
                          ? AppColors.success
                          : (item.status == 'DUPLICATE' ? AppColors.orange : AppColors.mediumGrey),
                    ),
                  ),
                  if (item.transactionDate != null)
                    Text(
                      item.transactionDate!.length >= 10 ? item.transactionDate!.substring(0, 10) : item.transactionDate!,
                      style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.mediumGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
        ),
      ],
    );
  }

  Future<void> _confirmDirect(DetectedTransactionModel item) async {
    final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
    final payload = ConfirmTransactionPayload(
      amount: item.amount,
      expenseCategory: item.transactionType == 'DEBIT' ? item.suggestedCategory : null,
      incomeCategory: item.transactionType == 'CREDIT' ? item.suggestedCategory : null,
      description: item.merchant,
      paymentMethodOrSource: item.sourceApp ?? item.sourceType,
    );

    final success = await notifier.confirmTransaction(item.id, payload);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.transactionType == 'DEBIT' ? "Expense" : "Income"} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm transaction'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _ignoreTransaction(int id) async {
    final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
    final success = await notifier.ignoreTransaction(id);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ignored')),
      );
    }
  }

  void _openReviewScreen(DetectedTransactionModel item) {
    context.push(
      RouteNames.transactionReview,
      extra: item,
    );
  }

  void _showSimulationDialog() {
    final smsDatasource = SmsDatasource();
    final samples = smsDatasource.getSampleSmsMessages();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simulate Bank Transaction',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a sample bank SMS to test real-time parsing and confirmation flow:',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              const SizedBox(height: 16),
              ...samples.map((msg) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: AppColors.tealExtraLight.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: const Icon(Icons.sms, color: AppColors.darkTeal),
                    title: Text(
                      msg,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.send_rounded, color: AppColors.darkTeal, size: 20),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
                      final sender = msg.split(':')[0].trim();
                      final res = await notifier.simulateSmsMessage(sender, msg);
                      if (mounted) {
                        if (res != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Detected: ${res.transactionType} Rs. ${res.amount.toStringAsFixed(2)} from ${res.merchant ?? sender}'),
                              backgroundColor: AppColors.darkTeal,
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
