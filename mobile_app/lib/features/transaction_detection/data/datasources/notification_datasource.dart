import '../models/detected_transaction.dart';
import 'transaction_parser.dart';

class NotificationDatasource {
  Future<bool> hasNotificationListenerPermission() async {
    return true;
  }

  Future<bool> requestNotificationListenerPermission() async {
    return true;
  }

  DetectedTransactionModel? processIncomingNotification({
    required String packageName,
    required String title,
    required String notificationText,
  }) {
    final fullText = ' ';
    return TransactionParser.parseMessage(
      body: fullText,
      sourceApp: packageName,
      sender: title,
      sourceType: 'NOTIFICATION',
    );
  }

  List<Map<String, String>> getSampleNotifications() {
    return [
      {
        'package': 'com.combank.digital',
        'title': 'Commercial Bank Digital',
        'text': 'Debit: Rs. 3,200.00 spent at Uber Eats with Card ending in 4455. TxnID: UBR88229',
      },
      {
        'package': 'lk.sampath.payapp',
        'title': 'Sampath WePay',
        'text': 'Payment of LKR 5,400.00 made to Asiri Hospitals. Ref: WEP66778',
      },
      {
        'package': 'com.dialog.myaccount',
        'title': 'Genie',
        'text': 'Payment of Rs. 1,850.00 to Dialog Axiata. TxnID: GNE554433',
      },
    ];
  }
}
