package com.myserviceforce.myxinatorprofieldagentpro

import android.app.*
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import android.Manifest
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

/**
 * Foreground service for background location tracking on Android.
 * This service runs as a foreground service with location type to ensure
 * continuous background operation even when the app is not visible.
 */
class LocationForegroundService : Service() {

    companion object {
        private const val TAG = "LocationForegroundService"
        private const val CHANNEL_ID = "location_tracking_channel"
        private const val NOTIFICATION_ID = 2001

        // Actions
        private const val ACTION_START_TRACKING = "ACTION_START_TRACKING"
        private const val ACTION_STOP_TRACKING = "ACTION_STOP_TRACKING"

        // Location settings (updated to 5 minutes as per FaProTrack spec)
        private const val UPDATE_INTERVAL_IN_MILLISECONDS = 300000L // 5 minutes
        private const val FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS = 150000L // 2.5 minutes
        private const val SMALLEST_DISPLACEMENT_IN_METERS = 100f // 100 meters

        // User data extras
        private const val EXTRA_COMPANY_ID = "company_id"
        private const val EXTRA_USER_ID = "user_id"
        private const val EXTRA_USERNAME = "username"
        private const val EXTRA_EMAIL = "email"

        @JvmStatic
        fun startService(
            context: Context,
            companyId: String,
            userId: String,
            username: String,
            email: String
        ) {
            val intent = Intent(context, LocationForegroundService::class.java).apply {
                action = ACTION_START_TRACKING
                putExtra(EXTRA_COMPANY_ID, companyId)
                putExtra(EXTRA_USER_ID, userId)
                putExtra(EXTRA_USERNAME, username)
                putExtra(EXTRA_EMAIL, email)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        @JvmStatic
        fun stopService(context: Context) {
            val intent = Intent(context, LocationForegroundService::class.java).apply {
                action = ACTION_STOP_TRACKING
            }
            context.startService(intent)
        }

        /**
         * Check if the app has necessary location permissions
         */
        fun hasLocationPermissions(context: Context): Boolean {
            val fineLocation = ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
            val coarseLocation = ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)

            return fineLocation == PackageManager.PERMISSION_GRANTED ||
                   coarseLocation == PackageManager.PERMISSION_GRANTED
        }

        /**
         * Get the last stored location data for Flutter
         */
        fun getLastLocationData(context: Context): String? {
            android.util.Log.d(TAG, "📡 [NATIVE-POLL] Flutter polling for location data...")
            val prefs = context.getSharedPreferences("location_data", Context.MODE_PRIVATE)
            val locationData = prefs.getString("last_location_data", null)

            if (locationData != null) {
                android.util.Log.d(TAG, "✅ [NATIVE-POLL] Location data found: ${locationData.length} chars")
            } else {
                android.util.Log.d(TAG, "⚠️ [NATIVE-POLL] No location data available yet")
            }

            return locationData
        }

        /**
         * Get the last location error for Flutter
         */
        fun getLastLocationError(context: Context): String? {
            val prefs = context.getSharedPreferences("location_data", Context.MODE_PRIVATE)
            return prefs.getString("last_location_error", null)
        }

        /**
         * Clear location data
         */
        fun clearLocationData(context: Context) {
            val prefs = context.getSharedPreferences("location_data", Context.MODE_PRIVATE)
            prefs.edit().clear().apply()
        }
    }

    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null
    private var locationRequest: LocationRequest? = null

    private var companyId: String? = null
    private var userId: String? = null
    private var username: String? = null
    private var email: String? = null

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        android.util.Log.d(TAG, "LocationForegroundService created")

        // Initialize location client
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        // Create notification channel
        createNotificationChannel()

        // Setup location callback with enhanced error handling
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                try {
                    android.util.Log.d(TAG, "🛰️ [NATIVE] Location callback fired!")
                    locationResult.lastLocation?.let { location ->
                        android.util.Log.d(TAG, "📍 [NATIVE] Raw GPS location received: ${location.latitude}, ${location.longitude}")
                        handleLocationUpdate(location)
                    } ?: android.util.Log.w(TAG, "⚠️ [NATIVE] Location result had no last location")
                } catch (e: SecurityException) {
                    android.util.Log.e(TAG, "🔒 [NATIVE] Security exception in location callback: ${e.message}")
                    sendLocationErrorToFlutter("PERMISSION_DENIED", "Location permission denied in callback")
                } catch (e: Exception) {
                    android.util.Log.e(TAG, "❌ [NATIVE] Error processing location in callback: ${e.message}")
                    sendLocationErrorToFlutter("LOCATION_ERROR", "Failed to process location: ${e.message}")
                }
            }

            override fun onLocationAvailability(availability: com.google.android.gms.location.LocationAvailability) {
                if (!availability.isLocationAvailable) {
                    android.util.Log.w(TAG, "⚠️ [NATIVE] Location services unavailable")
                    sendLocationErrorToFlutter("LOCATION_UNAVAILABLE", "Location services currently unavailable")
                } else {
                    android.util.Log.d(TAG, "✅ [NATIVE] Location services available")
                }
            }
        }

        // Create location request
        locationRequest = createLocationRequest()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        android.util.Log.d(TAG, "onStartCommand received")

        when (intent?.action) {
            ACTION_START_TRACKING -> {
                // Extract user data
                companyId = intent.getStringExtra(EXTRA_COMPANY_ID)
                userId = intent.getStringExtra(EXTRA_USER_ID)
                username = intent.getStringExtra(EXTRA_USERNAME)
                email = intent.getStringExtra(EXTRA_EMAIL)

                android.util.Log.d(TAG, "Starting tracking for user: $username ($userId)")

                // Start foreground notification
                startForeground(NOTIFICATION_ID, createNotification())

                // Start location updates
                startLocationUpdates()
                android.util.Log.d(TAG, "✅ [NATIVE] Location tracking fully started and running")
            }
            ACTION_STOP_TRACKING -> {
                android.util.Log.d(TAG, "Stopping tracking")
                stopLocationUpdates()
                stopForeground(true)
                stopSelf()
            }
        }

        // START_STICKY ensures service restarts if killed by system
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        android.util.Log.d(TAG, "LocationForegroundService destroyed")

        stopLocationUpdates()
    }

    private fun createLocationRequest(): LocationRequest {
        return LocationRequest.create().apply {
            interval = UPDATE_INTERVAL_IN_MILLISECONDS
            fastestInterval = FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS
            smallestDisplacement = SMALLEST_DISPLACEMENT_IN_METERS
            priority = Priority.PRIORITY_BALANCED_POWER_ACCURACY
        }
    }

    private fun startLocationUpdates() {
        try {
            android.util.Log.d(TAG, "🚀 [NATIVE] Starting location updates...")
            locationCallback?.let { callback ->
                locationRequest?.let { request ->
                    fusedLocationClient?.requestLocationUpdates(
                        request,
                        callback,
                        Looper.getMainLooper()
                    )
                    android.util.Log.d(TAG, "✅ [NATIVE] Location updates requested successfully")
                    android.util.Log.d(TAG, "⏰ [NATIVE] GPS updates will occur every ${UPDATE_INTERVAL_IN_MILLISECONDS}ms")
                }
            }
        } catch (e: SecurityException) {
            android.util.Log.e(TAG, "❌ [NATIVE] Security exception starting location updates: ${e.message}")
        }
    }

    private fun stopLocationUpdates() {
        locationCallback?.let { callback ->
            fusedLocationClient?.removeLocationUpdates(callback)
            android.util.Log.d(TAG, "Location updates stopped")
        }
    }

    private fun handleLocationUpdate(location: Location) {
        android.util.Log.d(TAG, "Location update: ${location.latitude}, ${location.longitude}, accuracy: ${location.accuracy}")

        // Send location to Flutter via MainActivity
        val locationData = mapOf(
            "company_id" to (companyId ?: ""),
            "user_id" to (userId ?: ""),
            "username" to (username ?: ""),
            "email" to (email ?: ""),
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy,
            "timestamp" to location.time
        )

        android.util.Log.d(TAG, "Location data: $locationData")

        // Send location data to Flutter through MainActivity
        val locationDataWithMetadata = mapOf(
            "company_id" to (companyId ?: ""),
            "user_id" to (userId ?: ""),
            "username" to (username ?: ""),
            "email" to (email ?: ""),
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy,
            "timestamp" to location.time,
            "speed" to location.speed,
            "heading" to location.bearing.toDouble(),
            "altitude" to location.altitude
        )

        sendLocationToFlutter(locationDataWithMetadata)

        // Update notification to show recent location
        updateNotification(location)
    }

    /**
     * Send location data to Flutter application
     */
    private fun sendLocationToFlutter(locationData: Map<String, Any>) {
        try {
            android.util.Log.d(TAG, "📍 [NATIVE] Storing location data for Flutter polling...")

            // Store location data for Flutter to retrieve
            val prefs = getSharedPreferences("location_data", Context.MODE_PRIVATE)
            prefs.edit().apply {
                // Convert Map to JSON string
                val json = org.json.JSONObject(locationData).toString()
                android.util.Log.d(TAG, "📦 [NATIVE] Location JSON: $json")

                // Encode to Base64 (single encoding, not double)
                val encoded = android.util.Base64.encodeToString(json.toByteArray(), android.util.Base64.NO_WRAP)
                android.util.Log.d(TAG, "🔐 [NATIVE] Encoded location data (${encoded.length} chars)")

                putString("last_location_data", encoded)
                putLong("last_location_time", System.currentTimeMillis())
                apply()
            }

            android.util.Log.d(TAG, "✅ [NATIVE] Location data stored successfully for Flutter")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "❌ [NATIVE] Error storing location data: ${e.message}")
            e.printStackTrace()
        }
    }

    /**
     * Send location error to Flutter application with enhanced error details
     */
    private fun sendLocationErrorToFlutter(errorCode: String, errorMessage: String) {
        try {
            android.util.Log.e(TAG, "Location error [$errorCode]: $errorMessage")

            // Store error for Flutter to retrieve
            val prefs = getSharedPreferences("location_data", Context.MODE_PRIVATE)
            val errorData = mapOf(
                "error_code" to errorCode,
                "error_message" to errorMessage,
                "timestamp" to System.currentTimeMillis()
            )

            prefs.edit().apply {
                putString("last_location_error", org.json.JSONObject(errorData).toString())
                apply()
            }

            android.util.Log.d(TAG, "✅ [NATIVE] Error data stored for Flutter: $errorCode")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "❌ [NATIVE] Error sending location error to Flutter: ${e.message}")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Location Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows that your location is being tracked for field management"
                setShowBadge(false)
                setSound(null, null)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Field Agent - Location Tracking")
            .setContentText("Your location is being tracked")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        return notification
    }

    private fun updateNotification(location: Location) {
        val timestamp = android.text.format.DateFormat.format("HH:mm:ss", java.util.Date(location.time))

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Field Agent - Location Tracking")
            .setContentText("Last update: $timestamp (${String.format("%.1f", location.accuracy)}m accuracy)")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        val notificationManager = NotificationManagerCompat.from(this)
        try {
            notificationManager.notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            android.util.Log.e(TAG, "Security exception updating notification: ${e.message}")
        }
    }
}