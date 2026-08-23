package com.example.mobile_app

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object TransactionCaptureEvents {
    private var sink: EventChannel.EventSink? = null

    fun setSink(eventSink: EventChannel.EventSink?) { sink = eventSink }

    fun emit(event: Map<String, String>) {
        android.os.Handler(android.os.Looper.getMainLooper()).post { sink?.success(event) }
    }
}

class MainActivity : FlutterActivity() {
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.finai.mobile/transaction_capture/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) = TransactionCaptureEvents.setSink(eventSink)
                override fun onCancel(arguments: Any?) = TransactionCaptureEvents.setSink(null)
            })
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.finai.mobile/transaction_capture")
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "hasSmsPermission" -> result.success(hasSmsPermission())
                    "openNotificationListenerSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onStart() { super.onStart(); registerSmsReceiver() }
    override fun onStop() { unregisterSmsReceiver(); super.onStop() }

    private fun hasSmsPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) { result.success(true); return }
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS), 8101)
        result.success(false)
    }

    private fun registerSmsReceiver() {
        if (smsReceiver != null || !hasSmsPermission()) return
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action != "android.provider.Telephony.SMS_RECEIVED") return
                val messages = android.provider.Telephony.Sms.Intents.getMessagesFromIntent(intent)
                TransactionCaptureEvents.emit(mapOf(
                    "sourceType" to "SMS",
                    "sender" to (messages.firstOrNull()?.originatingAddress ?: "Unknown sender"),
                    "text" to messages.joinToString("") { it.messageBody ?: "" },
                ))
            }
        }
        val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) registerReceiver(smsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        else registerReceiver(smsReceiver, filter)
    }

    private fun unregisterSmsReceiver() {
        smsReceiver?.let { unregisterReceiver(it) }
        smsReceiver = null
    }
}
