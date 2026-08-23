package com.example.mobile_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class FinAiNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) return
        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString().orEmpty()
        val text = extras.getCharSequence("android.text")?.toString().orEmpty()
        if (title.isBlank() && text.isBlank()) return
        TransactionCaptureEvents.emit(mapOf(
            "sourceType" to "NOTIFICATION",
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to text,
        ))
    }
}
