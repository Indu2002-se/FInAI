import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/report_model.dart';

/// Builds a monthly financial report PDF and opens the system share sheet.
/// Uses pure-Dart `pdf` (no native `printing` plugin) to avoid AGP/Maven issues.
class ReportPdfService {
  Future<void> shareMonthlyReport(MonthlyReportModel report) async {
    final doc = pw.Document();
    final monthLabel = report.month.isEmpty ? 'Current Month' : report.month;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'FinAI Monthly Financial Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(monthLabel, style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _kv('Income', _rs(report.totalIncome)),
          _kv('Expenses', _rs(report.totalExpense)),
          _kv('Net Savings', _rs(report.netSavings)),
          _kv('Savings Rate', '${report.savingsRate.toStringAsFixed(1)}%'),
          _kv(
            'Expense / Income',
            '${report.expenseToIncomeRatio.toStringAsFixed(1)}%',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Budget',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _kv('Allocated', _rs(report.budgetAllocated)),
          _kv('Spent', _rs(report.budgetSpent)),
          _kv('Variance', _rs(report.budgetVariance)),
          if (report.categoryExpenses.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Expense Breakdown',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...report.categoryExpenses.entries.map((e) {
              final pct = report.totalExpense > 0
                  ? (e.value / report.totalExpense) * 100
                  : 0.0;
              return _kv(
                e.key,
                '${_rs(e.value)} (${pct.toStringAsFixed(1)}%)',
              );
            }),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Insights',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _kv('Risk Level', report.riskLevel),
          _kv('Top Risk Driver', report.topRiskDriver),
          if (report.financialHealthScore != null)
            _kv(
              'Financial Health Score',
              report.financialHealthScore!.toStringAsFixed(0),
            ),
          pw.SizedBox(height: 8),
          pw.Text(
            report.aiRecommendation,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final safeMonth = monthLabel.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final fileName = 'finai-monthly-report-$safeMonth.pdf';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'FinAI Monthly Report — $monthLabel',
        text: 'Your FinAI monthly financial report PDF',
      ),
    );
  }

  pw.Widget _kv(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';
}
