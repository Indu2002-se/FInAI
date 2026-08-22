import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/detected_transaction.dart';

class TransactionParser {
  static final List<String> bankSenders = [
    'COMBANK', 'SAMPATH', 'HNB', 'BOC', 'PEOPLES', 'NTB', 'FRIMI',
    'EZCASH', 'MCASH', 'GENIE', 'DFCC', 'SEYLAN', 'NDB', 'AMANA', 'HSBC',
    'STANDARD CHARTERED', 'PAN ASIA', 'UNION BANK', 'CARGILLS BANK'
  ];

  static DetectedTransactionModel? parseMessage({
    required String body,
    String? sender,
    String? sourceApp,
    String sourceType = 'SMS',
  }) {
    if (body.trim().isEmpty) return null;

    final cleanText = body.trim();
    final lowerText = cleanText.toLowerCase();

    // 1. Direction classification
    String transactionType = 'UNKNOWN';
    if (_isTransfer(lowerText)) {
      transactionType = 'TRANSFER';
    } else if (_isDebit(lowerText)) {
      transactionType = 'DEBIT';
    } else if (_isCredit(lowerText)) {
      transactionType = 'CREDIT';
    }

    // Amount extraction
    final amount = _extractAmount(cleanText);
    if (amount == null || amount <= 0) {
      return null;
    }

    // 2. Merchant / Source extraction
    final merchant = _extractMerchant(cleanText, transactionType);

    // 3. Masked Account extraction
    final accountRef = _extractAccountReference(cleanText);

    // 4. Reference extraction
    final reference = _extractReference(cleanText);

    // 5. Date & Time
    final transactionDate = DateTime.now().toIso8601String();

    // 6. Category classification
    final suggestedCategory = _suggestCategory(merchant ?? cleanText, transactionType);

    // 7. Calculate confidence
    double confidence = 0.0;
    if (amount > 0) confidence += 0.30;
    if (transactionType != 'UNKNOWN') confidence += 0.25;
    if (merchant != null && merchant.isNotEmpty) confidence += 0.20;
    if (accountRef != null && accountRef.isNotEmpty) confidence += 0.15;
    if (reference != null && reference.isNotEmpty) confidence += 0.10;
    confidence = (confidence * 100).roundToDouble() / 100.0;

    // 8. Hash raw text for deduplication
    final rawTextHash = _generateHash('${sender ?? ""}_${amount.toStringAsFixed(2)}_$cleanText');

    return DetectedTransactionModel(
      id: 0,
      sourceType: sourceType,
      sourceApp: sourceApp ?? sender,
      sourceSender: sender,
      amount: amount,
      transactionType: transactionType,
      merchant: merchant,
      accountReference: accountRef,
      transactionDate: transactionDate,
      reference: reference,
      rawTextHash: rawTextHash,
      confidence: confidence,
      status: 'PENDING',
      suggestedCategory: suggestedCategory,
    );
  }

  static bool _isTransfer(String text) {
    return text.contains('fund transfer') ||
        text.contains('transferred to') ||
        text.contains('transferred from') ||
        text.contains('ft to') ||
        text.contains('own account transfer') ||
        text.contains('third party transfer') ||
        text.contains('cefts');
  }

  static bool _isDebit(String text) {
    return text.contains('debited') ||
        text.contains('paid') ||
        text.contains('spent') ||
        text.contains('purchase') ||
        text.contains('withdrawn') ||
        text.contains('withdrew') ||
        text.contains('payment of') ||
        text.contains('deducted') ||
        text.contains('bill payment') ||
        text.contains('sent to') ||
        text.contains('dr.');
  }

  static bool _isCredit(String text) {
    return text.contains('credited') ||
        text.contains('received') ||
        text.contains('deposited') ||
        text.contains('deposit of') ||
        text.contains('added to') ||
        text.contains('refund') ||
        text.contains('cashback') ||
        text.contains('salary') ||
        text.contains('cr.');
  }

  static double? _extractAmount(String text) {
    final patterns = [
      RegExp(r'(?:Rs\.?|LKR|USD|[$])\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:amount|for|value)(?:\s*(?:of|is|:))?\s*(?:Rs\.?|LKR)?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'\b([\d,]+\.\d{2})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final rawStr = match.group(1)?.replaceAll(',', '');
        if (rawStr != null) {
          final val = double.tryParse(rawStr);
          if (val != null && val > 0) return val;
        }
      }
    }
    return null;
  }

  static String? _extractMerchant(String text, String type) {
    final patterns = [
      RegExp(r"(?:at|merchant:?)\s+([A-Za-z0-9\s.,'&-]{2,30})", caseSensitive: false),
      RegExp(r"(?:paid to|transferred to|to)\s+([A-Za-z0-9\s.,'&-]{2,30})", caseSensitive: false),
      RegExp(r"(?:from)\s+([A-Za-z0-9\s.,'&-]{2,30})", caseSensitive: false),
    ];

    final stopWords = ['on ', 'ref', 'val', 'avail', 'date', 'bal', 'lkr', 'rs'];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        String m = match.group(1)?.trim() ?? '';
        for (final stop in stopWords) {
          final idx = m.toLowerCase().indexOf(stop);
          if (idx > 0) {
            m = m.substring(0, idx).trim();
          }
        }
        if (m.length > 1 && !m.toLowerCase().startsWith('rs') && !m.toLowerCase().startsWith('lkr')) {
          return m.replaceAll(RegExp(r'[\.\,\s]+$'), '');
        }
      }
    }

    if (type == 'DEBIT') return 'Card/POS Merchant';
    if (type == 'CREDIT') return 'Bank Deposit';
    if (type == 'TRANSFER') return 'Fund Transfer';
    return null;
  }

  static String? _extractAccountReference(String text) {
    final patterns = [
      RegExp(r'(?:A/C|Account|Acc|Card|ending in)\s*(?:No\.?)?\s*([xX\*\d]{3,16})', caseSensitive: false),
      RegExp(r'\b([xX\*]+\d{4})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final acc = match.group(1)?.trim();
        if (acc != null && acc.isNotEmpty) {
          return acc;
        }
      }
    }
    return null;
  }

  static String? _extractReference(String text) {
    final patterns = [
      RegExp(r'(?:Ref(?:\s*No|:)?|Txn\s*ID:?|Reference:?)\s*([A-Za-z0-9]{4,20})', caseSensitive: false),
      RegExp(r'\b(TXN[A-Za-z0-9]+)\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final ref = match.group(1)?.trim();
        if (ref != null && ref.isNotEmpty) {
          return ref;
        }
      }
    }
    return null;
  }

  static String _suggestCategory(String text, String transactionType) {
    final lower = text.toLowerCase();

    if (transactionType == 'CREDIT') {
      if (lower.contains('salary') || lower.contains('payroll') || lower.contains('wage')) return 'SALARY';
      if (lower.contains('dividend') || lower.contains('interest') || lower.contains('yield')) return 'INVESTMENT';
      if (lower.contains('freelance') || lower.contains('upwork') || lower.contains('fiverr')) return 'FREELANCE';
      if (lower.contains('business') || lower.contains('sale')) return 'BUSINESS';
      return 'OTHER';
    }

    if (lower.contains('keells') ||
        lower.contains('cargills') ||
        lower.contains('supermarket') ||
        lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('eats') ||
        lower.contains('bakery') ||
        lower.contains('cafe') ||
        lower.contains('pizza') ||
        lower.contains('kfc') ||
        lower.contains('mcdonald')) {
      return 'FOOD';
    }

    if (lower.contains('ceb') ||
        lower.contains('electricity') ||
        lower.contains('water') ||
        lower.contains('dialog') ||
        lower.contains('mobitel') ||
        lower.contains('slt') ||
        lower.contains('airtel') ||
        lower.contains('hutch') ||
        lower.contains('telecom') ||
        lower.contains('utility')) {
      return 'UTILITIES';
    }

    if (lower.contains('uber') ||
        lower.contains('pickme') ||
        lower.contains('petrol') ||
        lower.contains('fuel') ||
        lower.contains('ceypetco') ||
        lower.contains('ioc') ||
        lower.contains('lafs') ||
        lower.contains('railway') ||
        lower.contains('highway') ||
        lower.contains('transport')) {
      return 'TRANSPORTATION';
    }

    if (lower.contains('hospital') ||
        lower.contains('pharmacy') ||
        lower.contains('asiri') ||
        lower.contains('nawaloka') ||
        lower.contains('durdans') ||
        lower.contains('lanka hospitals') ||
        lower.contains('clinic') ||
        lower.contains('medical') ||
        lower.contains('health')) {
      return 'HEALTHCARE';
    }

    if (lower.contains('school') ||
        lower.contains('university') ||
        lower.contains('institute') ||
        lower.contains('tuition') ||
        lower.contains('course') ||
        lower.contains('udemy') ||
        lower.contains('coursera') ||
        lower.contains('education')) {
      return 'EDUCATION';
    }

    if (lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('cinema') ||
        lower.contains('movie') ||
        lower.contains('theatre') ||
        lower.contains('game') ||
        lower.contains('steam') ||
        lower.contains('entertainment')) {
      return 'ENTERTAINMENT';
    }

    return 'OTHER';
  }

  static String _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
