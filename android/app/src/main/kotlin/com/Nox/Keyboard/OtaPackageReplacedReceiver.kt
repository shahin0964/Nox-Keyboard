package com.Nox.Keyboard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Invoked immediately by Android after an in-place app update finishes installing.
 * Deletes the downloaded OTA APK from cache and notifies the user cleanly.
 */
class OtaPackageReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            OtaUpdateManager(context).onPackageReplaced()
        }
    }
}
