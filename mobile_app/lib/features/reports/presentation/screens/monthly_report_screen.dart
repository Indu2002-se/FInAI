import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/widgets/stat_row.dart';
import '../../data/models/report_model.dart';
import '../../data/services/report_pdf_service.dart';
import '../providers/report_provider.dart';

/// Screen 28: Monthly Financial Report — live API + PDF export
class MonthlyReportScreen extends ConsumerWidget {
  final String? month;

  const MonthlyReportScreen({super.key, this.month});

  static const _categoryColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider(month));

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
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MONTHLY REPORT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          reportAsync.maybeWhen(
            data: (report) => IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.black87, size: 20),
              tooltip: 'Download PDF',
              onPressed: () => _downloadPdf(context, report),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load report: $err',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(monthlyReportProvider(month)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (report) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _formatMonthLabel(report.month),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StatRow(
                  items: [
                    StatItem(
                      label: 'Income',
                      value: _rs(report.totalIncome),
                      color: Colors.green[700],
                    ),
                    StatItem(
                      label: 'Expenses',
                      value: _rs(report.totalExpense),
                      color: Colors.red[700],
                    ),
                    StatItem(
                      label: 'Savings',
                      value: _rs(report.netSavings),
                      color: Colors.blue[700],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'EXPENSE BREAKDOWN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (report.categoryExpenses.isEmpty)
                  Text(
                    'No category expenses for this month.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  )
                else
                  ...report.categoryExpenses.entries.toList().asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final category = entry.value.key;
                      final amount = entry.value.value;
                      final pct = report.totalExpense > 0
                          ? (amount / report.totalExpense) * 100
                          : 0.0;
                      final color = _categoryColors[
                          index % _categoryColors.length][700]!;
                      return _buildCategoryItem(category, amount, pct, color);
                    },
                  ),
                const SizedBox(height: 24),
                const Text(
                  'INSIGHTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.riskLevel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.aiRecommendation,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      if (report.topRiskDriver.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Top risk driver: ${report.topRiskDriver}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _downloadPdf(context, report),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, MonthlyReportModel report) async {
    try {
      await ReportPdfService().shareMonthlyReport(report);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create PDF: $e')),
      );
    }
  }

  String _formatMonthLabel(String month) {
    if (month.isEmpty) return 'CURRENT MONTH';
    try {
      final parsed = DateFormat('yyyy-MM').parse(month);
      return DateFormat('MMMM yyyy').format(parsed).toUpperCase();
    } catch (_) {
      return month.toUpperCase();
    }
  }

  String _rs(double amount) => 'Rs.${amount.toStringAsFixed(0)}';

  Widget _buildCategoryItem(
    String category,
    double amount,
    double percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _rs(amount),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
