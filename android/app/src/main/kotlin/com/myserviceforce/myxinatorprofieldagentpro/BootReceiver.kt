package com.myserviceforce.myxinatorprofieldagentpro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Broadcast receiver that listens for device boot completed events.
 * Restarts location tracking service if it was active before reboot.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "location_tracking_prefs"
        private const val PREF_TRACKING_ENABLED = "tracking_enabled"
        private const val PREF_COMPANY_ID = "company_id"
        private const val PREF_USER_ID = "user_id"
        private const val PREF_USERNAME = "username"
        private const val PREF_EMAIL = "email"

        /**
         * Save tracking state for restoration after reboot
         */
        fun saveTrackingState(
            context: Context,
            companyId: String,
            userId: String,
            username: String,
            email: String
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putBoolean(PREF_TRACKING_ENABLED, true)
                putString(PREF_COMPANY_ID, companyId)
                putString(PREF_USER_ID, userId)
                putString(PREF_USERNAME, username)
                putString(PREF_EMAIL, email)
                apply()
            }
            Log.d(TAG, "Tracking state saved for user: $username")
        }

        /**
         * Clear tracking state (called on logout)
         */
        fun clearTrackingState(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().clear().apply()
            Log.d(TAG, "Tracking state cleared")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {

            Log.d(TAG, "Boot completed, checking if location tracking should be restored")

            // Check if tracking was enabled before reboot
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val trackingEnabled = prefs.getBoolean(PREF_TRACKING_ENABLED, false)

            if (trackingEnabled) {
                // Get user data
                val companyId = prefs.getString(PREF_COMPANY_ID, null)
                val userId = prefs.getString(PREF_USER_ID, null)
                val username = prefs.getString(PREF_USERNAME, null)
                val email = prefs.getString(PREF_EMAIL, null)

                // Only restart if we have valid user data
                if (companyId != null && userId != null && username != null && email != null) {
                    Log.d(TAG, "Restarting location tracking for user: $username")

                    // Start the location tracking service
                    LocationForegroundService.startService(
                        context,
                        companyId,
                        userId,
                        username,
                        email
                    )
                } else {
                    Log.w(TAG, "Cannot restart tracking - incomplete user data")
                }
            } else {
                Log.d(TAG, "Location tracking was not enabled before reboot")
            }
        }
    }
}