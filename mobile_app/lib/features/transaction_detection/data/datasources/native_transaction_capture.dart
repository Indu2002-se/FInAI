import 'package:flutter/services.dart';

class NativeTransactionCapture {
  NativeTransactionCapture._();

  static const _methods = MethodChannel('com.finai.mobile/transaction_capture');
  static const _events = EventChannel(
    'com.finai.mobile/transaction_capture/events',
  );

  static Stream<Map<String, dynamic>> get events => _events
      .receiveBroadcastStream()
      .where((event) => event is Map)
      .map((event) => Map<String, dynamic>.from(event as Map));

  static Future<bool> requestSmsPermission() async =>
      await _methods.invokeMethod<bool>('requestSmsPermission') ?? false;

  static Future<void> openNotificationListenerSettings() =>
      _methods.invokeMethod<void>('openNotificationListenerSettings');
}
