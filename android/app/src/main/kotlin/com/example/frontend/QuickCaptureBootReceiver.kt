package com.example.frontend

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log

class QuickCaptureBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        val preferences = context.getSharedPreferences(
            QuickCaptureBubbleService.PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        )
        if (!preferences.getBoolean(QuickCaptureBubbleService.KEY_RESTORE_ON_BOOT, false)) {
            return
        }
        val canOverlay =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                Settings.canDrawOverlays(context)
        if (!canOverlay) {
            Log.w(TAG, "Boot restore skipped: overlay permission missing")
            return
        }
        val serviceIntent = Intent(
            context,
            QuickCaptureBubbleService::class.java,
        ).apply {
            action = QuickCaptureBubbleService.ACTION_START_OR_UPDATE
        }
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }.onFailure {
            Log.w(TAG, "Boot restore skipped: service start failed")
        }
    }

    private companion object {
        const val TAG = "QuickCapture"
    }
}
