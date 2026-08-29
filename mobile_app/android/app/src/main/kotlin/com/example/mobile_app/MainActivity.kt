package com.example.mobile_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.provider.Settings
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object TransactionCaptureEvents {
    private var sink: EventChannel.EventSink? = null

    fun setSink(eventSink: EventChannel.EventSink?) {
        sink = eventSink
    }

    fun hasSink(): Boolean = sink != null

    fun emit(event: Map<String, String>) {
        android.os.Handler(android.os.Looper.getMainLooper()).post {
            sink?.success(event)
        }
    }

    /** Emit live if Flutter is listening; otherwise persist for later drain. */
    fun emitOrQueue(context: android.content.Context, event: Map<String, String>) {
        if (hasSink()) {
            emit(event)
        } else {
            TransactionEventStore.enqueue(context.applicationContext, event)
        }
    }
}

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.finai.mobile/transaction_capture/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) =
                    TransactionCaptureEvents.setSink(eventSink)

                override fun onCancel(arguments: Any?) =
                    TransactionCaptureEvents.setSink(null)
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
                    "drainPendingEvents" -> {
                        val events = TransactionEventStore.drain(applicationContext)
                        result.success(events)
                    }
                    "getLastSmsSyncMs" ->
                        result.success(TransactionEventStore.getLastSmsSyncMs(applicationContext))
                    "setLastSmsSyncMs" -> {
                        val ms = call.argument<Number>("ms")?.toLong()
                            ?: (call.arguments as? Number)?.toLong()
                            ?: 0L
                        TransactionEventStore.setLastSmsSyncMs(applicationContext, ms)
                        result.success(null)
                    }
                    "readSmsInbox" -> {
                        if (!hasSmsPermission()) {
                            result.success(emptyList<Map<String, String>>())
                            return@setMethodCallHandler
                        }
                        val sinceMs = call.argument<Number>("sinceMs")?.toLong() ?: 0L
                        // First sync: last 365 days only (avoids scanning entire device history)
                        val effectiveSince = if (sinceMs > 0L) {
                            sinceMs
                        } else {
                            System.currentTimeMillis() - 365L * 24 * 60 * 60 * 1000
                        }
                        result.success(readSmsInbox(effectiveSince))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasSmsPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) {
            result.success(true)
            return
        }
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
            8101,
        )
        result.success(false)
    }

    private fun readSmsInbox(sinceMs: Long): List<Map<String, String>> {
        val out = mutableListOf<Map<String, String>>()
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val projection = arrayOf(
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
        )
        val selection = if (sinceMs > 0) "${Telephony.Sms.DATE} > ?" else null
        val selectionArgs = if (sinceMs > 0) arrayOf(sinceMs.toString()) else null
        val sortOrder = "${Telephony.Sms.DATE} ASC"

        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
            if (cursor == null) return out
            val addrIdx = cursor.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIdx = cursor.getColumnIndex(Telephony.Sms.BODY)
            val dateIdx = cursor.getColumnIndex(Telephony.Sms.DATE)
            while (cursor.moveToNext()) {
                val sender = if (addrIdx >= 0) cursor.getString(addrIdx) ?: "Unknown sender" else "Unknown sender"
                val text = if (bodyIdx >= 0) cursor.getString(bodyIdx) ?: "" else ""
                val date = if (dateIdx >= 0) cursor.getLong(dateIdx) else 0L
                if (text.isBlank()) continue
                out.add(
                    mapOf(
                        "sourceType" to "SMS",
                        "sender" to sender,
                        "text" to text,
                        "receivedAtMs" to date.toString(),
                    ),
                )
            }
        } catch (_: SecurityException) {
            // Permission revoked mid-flight
        } finally {
            cursor?.close()
        }
        return out
    }
}
