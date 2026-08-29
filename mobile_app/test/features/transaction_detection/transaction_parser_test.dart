import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/transaction_detection/data/datasources/transaction_parser.dart';
import 'package:mobile_app/features/transaction_detection/data/models/detection_settings.dart';

void main() {
  group('DetectionSettingsModel tests', () {
    test('default smsEnabled should be false for new users', () {
      final model = DetectionSettingsModel(id: 0);
      expect(model.smsEnabled, isFalse);
    });

    test('fromJson should default smsEnabled to false when null or absent', () {
      final model = DetectionSettingsModel.fromJson({'id': 1});
      expect(model.smsEnabled, isFalse);
    });

    test('fromJson should parse smsEnabled correctly when explicitly true', () {
      final model = DetectionSettingsModel.fromJson({'id': 1, 'smsEnabled': true});
      expect(model.smsEnabled, isTrue);
    });
  });

  group('TransactionParser tests', () {
    test('should parse COMBANK debit message and prioritize transaction amount over balance', () {
      const sms =
          'COMBANK Alert: Rs. 4,500.00 debited from A/C **4589 on 22-Aug-2026 at Keells Super Colombo. Ref: TXN98762. Avail Bal: Rs. 84,200.00';
      final parsed = TransactionParser.parseMessage(body: sms, sender: 'COMBANK');

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, equals('DEBIT'));
      expect(parsed.amount, equals(4500.00));
      expect(parsed.accountReference, equals('**4589'));
      expect(parsed.suggestedCategory, equals('FOOD'));
    });

    test('should parse Sampath Bank debit message accurately', () {
      const sms =
          'Sampath Bank: Your Card **1234 has been debited by LKR 2,350.00 for payment at PickMe. Ref: SMP54321';
      final parsed = TransactionParser.parseMessage(body: sms, sender: 'SAMPATH');

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, equals('DEBIT'));
      expect(parsed.amount, equals(2350.00));
      expect(parsed.suggestedCategory, equals('TRANSPORTATION'));
    });

    test('should parse HNB credit salary message accurately', () {
      const sms =
          'HNB Alert: Your A/C *7890 was credited with Rs. 150,000.00 on 22-Aug-2026 from Employer Ltd (Salary). Ref: SAL202608';
      final parsed = TransactionParser.parseMessage(body: sms, sender: 'HNB');

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, equals('CREDIT'));
      expect(parsed.amount, equals(150000.00));
      expect(parsed.suggestedCategory, equals('SALARY'));
    });

    test('should parse BOC utility payment accurately', () {
      const sms =
          'BOC Notice: Bill payment of Rs. 6,800.00 to CEB Electricity successful from A/C **6789. Ref: BOC991122';
      final parsed = TransactionParser.parseMessage(body: sms, sender: 'BOC');

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, equals('DEBIT'));
      expect(parsed.amount, equals(6800.00));
      expect(parsed.suggestedCategory, equals('UTILITIES'));
    });

    test('should ignore OTP and security verification codes', () {
      const otp1 = 'Your OTP for transaction of Rs. 5,000 is 839201. Do not share with anyone.';
      const otp2 = 'Use verification code 459102 to complete your debit card transaction.';

      expect(TransactionParser.parseMessage(body: otp1, sender: 'BANK'), isNull);
      expect(TransactionParser.parseMessage(body: otp2, sender: 'BANK'), isNull);
    });

    test('should ignore non-financial messages', () {
      const promo = 'Enjoy 20% discount this weekend at your nearest shopping mall with your bank card!';
      expect(TransactionParser.parseMessage(body: promo, sender: 'BANK'), isNull);
    });

    test('should preserve original transactionDate when passed', () {
      final customDate = DateTime(2026, 8, 15, 14, 30);
      const sms = 'Rs. 1,000.00 debited from card ending in 5678 at Fuel Station';
      final parsed = TransactionParser.parseMessage(
        body: sms,
        sender: 'BANK',
        transactionDate: customDate,
      );

      expect(parsed, isNotNull);
      expect(parsed!.transactionDate, equals(customDate.toIso8601String()));
    });
  });
}
