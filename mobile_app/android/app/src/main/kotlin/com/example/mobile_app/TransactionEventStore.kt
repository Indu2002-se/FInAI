package com.example.mobile_app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** Persists SMS/notification capture events while Flutter is not listening. */
object TransactionEventStore {
    private const val PREFS = "finai_transaction_capture"
    private const val KEY_EVENTS = "pending_events"
    private const val KEY_LAST_SMS_SYNC = "last_sms_sync_ms"
    private const val MAX_EVENTS = 500

    fun enqueue(context: Context, event: Map<String, String>) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val arr = JSONArray(prefs.getString(KEY_EVENTS, "[]"))
        val obj = JSONObject()
        event.forEach { (k, v) -> obj.put(k, v) }
        if (!obj.has("receivedAtMs")) {
            obj.put("receivedAtMs", System.currentTimeMillis().toString())
        }
        arr.put(obj)
        while (arr.length() > MAX_EVENTS) {
            arr.remove(0)
        }
        prefs.edit().putString(KEY_EVENTS, arr.toString()).apply()
    }

    fun drain(context: Context): List<Map<String, String>> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val arr = JSONArray(prefs.getString(KEY_EVENTS, "[]"))
        val out = mutableListOf<Map<String, String>>()
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            val map = mutableMapOf<String, String>()
            obj.keys().forEach { key -> map[key] = obj.optString(key, "") }
            out.add(map)
        }
        prefs.edit().putString(KEY_EVENTS, "[]").apply()
        return out
    }

    fun getLastSmsSyncMs(context: Context): Long =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getLong(KEY_LAST_SMS_SYNC, 0L)

    fun setLastSmsSyncMs(context: Context, ms: Long) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putLong(KEY_LAST_SMS_SYNC, ms)
            .apply()
    }
}
