import '../models/detected_transaction.dart';
import 'transaction_parser.dart';

class SmsDatasource {
  Future<bool> hasPermission() async {
    // Permission placeholder - in real native build, checked via permission_handler or platform channel
    return true;
  }

  Future<bool> requestPermission() async {
    return true;
  }

  DetectedTransactionModel? processIncomingSms({
    required String sender,
    required String messageBody,
  }) {
    return TransactionParser.parseMessage(
      body: messageBody,
      sender: sender,
      sourceType: 'SMS',
    );
  }

  List<String> getSampleSmsMessages() {
    return [
      'COMBANK Alert: Rs. 4,500.00 debited from A/C **4589 on 22-Aug-2026 at Keells Super Colombo. Ref: TXN98762. Avail Bal: Rs. 84,200.00',
      'Sampath Bank: Your Card **1234 has been debited by LKR 2,350.00 for payment at PickMe. Ref: SMP54321',
      'HNB Alert: Your A/C *7890 was credited with Rs. 150,000.00 on 22-Aug-2026 from Employer Ltd (Salary). Ref: SAL202608',
      'BOC Notice: Bill payment of Rs. 6,800.00 to CEB Electricity successful from A/C **6789. Ref: BOC991122',
      'eZ Cash: You paid Rs. 1,200.00 to Ceypetco Fuel Station on 22/08/2026. Ref: EZ887766',
    ];
  }
}
