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

  static Future<bool> hasSmsPermission() async =>
      await _methods.invokeMethod<bool>('hasSmsPermission') ?? false;

  static Future<void> openNotificationListenerSettings() =>
      _methods.invokeMethod<void>('openNotificationListenerSettings');

  static Future<List<Map<String, dynamic>>> drainPendingEvents() async {
    final raw = await _methods.invokeMethod<List<dynamic>>('drainPendingEvents');
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<int> getLastSmsSyncMs() async =>
      (await _methods.invokeMethod<num>('getLastSmsSyncMs'))?.toInt() ?? 0;

  static Future<void> setLastSmsSyncMs(int ms) =>
      _methods.invokeMethod<void>('setLastSmsSyncMs', {'ms': ms});

  /// Reads SMS inbox messages newer than [sinceMs] (0 = first sync window on Android).
  static Future<List<Map<String, dynamic>>> readSmsInbox({int sinceMs = 0}) async {
    final raw = await _methods.invokeMethod<List<dynamic>>(
      'readSmsInbox',
      {'sinceMs': sinceMs},
    );
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
