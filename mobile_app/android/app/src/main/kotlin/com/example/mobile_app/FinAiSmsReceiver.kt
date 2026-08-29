package com.example.mobile_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * Manifest-registered SMS receiver so messages are captured when the app is
 * backgrounded or closed. Events are queued locally and also emitted live if Flutter is listening.
 */
class FinAiSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        if (messages.isEmpty()) return

        val event = mapOf(
            "sourceType" to "SMS",
            "sender" to (messages.firstOrNull()?.originatingAddress ?: "Unknown sender"),
            "text" to messages.joinToString("") { it.messageBody ?: "" },
            "receivedAtMs" to System.currentTimeMillis().toString(),
        )
        TransactionCaptureEvents.emitOrQueue(context.applicationContext, event)
    }
}
