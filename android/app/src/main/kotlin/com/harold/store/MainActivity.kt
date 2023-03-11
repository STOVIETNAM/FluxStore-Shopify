package com.harold.store

import android.content.Context
import android.app.NotificationManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // CLEAR NOTIFICATION. JIRA TICKET FLUXSTORE-624
    override fun onResume() {
        super.onResume()
        closeAllNotifications();
    }

    private fun closeAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }
}