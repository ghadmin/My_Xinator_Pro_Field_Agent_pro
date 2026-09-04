package com.myserviceforce.myxinatorprofieldagentpro

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.myserviceforce.myxinatorprofieldagentpro/location"
        private const val EVENT_CHANNEL = "com.myserviceforce.myxinatorprofieldagentpro/location_events"

        // Method names
        private const val METHOD_START_SERVICE = "startLocationService"
        private const val METHOD_STOP_SERVICE = "stopLocationService"
        private const val METHOD_SAVE_STATE = "saveTrackingState"
        private const val METHOD_CLEAR_STATE = "clearTrackingState"
        private const val METHOD_CHECK_PERMISSIONS = "checkPermissions"

        // Argument keys
        private const val ARG_COMPANY_ID = "company_id"
        private const val ARG_USER_ID = "user_id"
        private const val ARG_USERNAME = "username"
        private const val ARG_EMAIL = "email"
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var locationEventSink: io.flutter.plugin.common.EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    // Timeout protection for platform channel calls
    private val platformTimeout = 30000L // 30 seconds
    private val pendingResults = mutableMapOf<String, MethodChannel.Result>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup method channel with timeout protection
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            val callId = "${call.method}_${System.currentTimeMillis()}"
            pendingResults[callId] = result

            android.util.Log.d("MainActivity", "🔧 [ANDROID] Method call: ${call.method} (id: $callId)")

            // Set up timeout for this call
            handler.postDelayed({
                if (pendingResults.containsKey(callId)) {
                    android.util.Log.e("MainActivity", "⏰ [ANDROID] Method ${call.method} timed out (id: $callId)")
                    pendingResults.remove(callId)?.error("TIMEOUT", "Method call timed out after ${platformTimeout/1000}s", null)
                }
            }, platformTimeout)

            // Handle the method call with timeout protection
            try {
                when (call.method) {
                    METHOD_START_SERVICE -> {
                        val companyId = call.argument<String>(ARG_COMPANY_ID)
                        val userId = call.argument<String>(ARG_USER_ID)
                        val username = call.argument<String>(ARG_USERNAME)
                        val email = call.argument<String>(ARG_EMAIL)

                        if (companyId != null && userId != null && username != null && email != null) {
                            LocationForegroundService.startService(
                                this,
                                companyId,
                                userId,
                                username,
                                email
                            )

                            // Save state for boot receiver
                            BootReceiver.saveTrackingState(
                                this,
                                companyId,
                                userId,
                                username,
                                email
                            )

                            completeMethodCall(callId, result, null)
                            android.util.Log.d("MainActivity", "✅ [ANDROID] startLocationService completed (id: $callId)")
                        } else {
                            completeMethodCall(callId, result, null, "INVALID_ARGUMENTS", "Missing required arguments")
                        }
                    }

                    METHOD_STOP_SERVICE -> {
                        LocationForegroundService.stopService(this)
                        BootReceiver.clearTrackingState(this)
                        completeMethodCall(callId, result, null)
                        android.util.Log.d("MainActivity", "✅ [ANDROID] stopLocationService completed (id: $callId)")
                    }

                    METHOD_SAVE_STATE -> {
                        val companyId = call.argument<String>(ARG_COMPANY_ID)
                        val userId = call.argument<String>(ARG_USER_ID)
                        val username = call.argument<String>(ARG_USERNAME)
                        val email = call.argument<String>(ARG_EMAIL)

                        if (companyId != null && userId != null && username != null && email != null) {
                            BootReceiver.saveTrackingState(
                                this,
                                companyId,
                                userId,
                                username,
                                email
                            )
                            completeMethodCall(callId, result, null)
                            android.util.Log.d("MainActivity", "✅ [ANDROID] saveTrackingState completed (id: $callId)")
                        } else {
                            completeMethodCall(callId, result, null, "INVALID_ARGUMENTS", "Missing required arguments")
                        }
                    }

                    METHOD_CLEAR_STATE -> {
                        BootReceiver.clearTrackingState(this)
                        completeMethodCall(callId, result, null)
                        android.util.Log.d("MainActivity", "✅ [ANDROID] clearTrackingState completed (id: $callId)")
                    }

                    METHOD_CHECK_PERMISSIONS -> {
                        // Check location permissions
                        val hasPermissions = LocationForegroundService.hasLocationPermissions(this)
                        completeMethodCall(callId, result, hasPermissions)
                        android.util.Log.d("MainActivity", "✅ [ANDROID] checkPermissions completed (id: $callId)")
                    }

                    "getLastLocationData" -> {
                        // Get the last stored location data
                        val locationData = LocationForegroundService.getLastLocationData(this)
                        completeMethodCall(callId, result, locationData)
                        android.util.Log.d("MainActivity", "✅ [ANDROID] getLastLocationData completed (id: $callId)")
                    }

                    "clearLocationData" -> {
                        // Clear stored location data
                        LocationForegroundService.clearLocationData(this)
                        completeMethodCall(callId, result, null)
                        android.util.Log.d("MainActivity", "✅ [ANDROID] clearLocationData completed (id: $callId)")
                    }

                    else -> {
                        result.notImplemented()
                        pendingResults.remove(callId)
                        android.util.Log.d("MainActivity", "❌ [ANDROID] Method not implemented: ${call.method} (id: $callId)")
                    }
                }
            } catch (e: Exception) {
                completeMethodCall(callId, result, null, "SERVICE_ERROR", "Failed to handle method: ${e.message}")
                android.util.Log.e("MainActivity", "❌ [ANDROID] Error handling method ${call.method}: ${e.message}")
            }
        }

        // Setup event channel for location updates
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                locationEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                locationEventSink = null
            }
        })
    }

    /**
     * Complete a method call and clear its timeout
     */
    private fun completeMethodCall(
        callId: String,
        result: MethodChannel.Result,
        successResult: Any?,
        errorCode: String? = null,
        errorMessage: String? = null
    ) {
        pendingResults.remove(callId)
        handler.removeCallbacksAndMessages(callId)

        when {
            errorCode != null -> {
                result.error(errorCode, errorMessage, null)
                android.util.Log.d("MainActivity", "⚠️ [ANDROID] Method completed with error: $errorCode")
            }
            else -> {
                result.success(successResult)
                android.util.Log.d("MainActivity", "✅ [ANDROID] Method completed successfully")
            }
        }
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        super.onDestroy()
    }

    /**
     * Called by LocationForegroundService when a new location is received
     * This method sends location data to Flutter via event channel
     */
    fun onLocationUpdate(locationData: Map<String, Any>) {
        handler.post {
            try {
                val jsonObject = JSONObject()
                jsonObject.put("company_id", locationData["company_id"])
                jsonObject.put("user_id", locationData["user_id"])
                jsonObject.put("username", locationData["username"])
                jsonObject.put("email", locationData["email"])
                jsonObject.put("latitude", locationData["latitude"])
                jsonObject.put("longitude", locationData["longitude"])
                jsonObject.put("accuracy", locationData["accuracy"])
                jsonObject.put("timestamp", locationData["timestamp"])

                locationEventSink?.success(jsonObject.toString())
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    /**
     * Called by LocationForegroundService when an error occurs
     */
    fun onLocationError(error: String) {
        handler.post {
            locationEventSink?.error("LOCATION_ERROR", error, null)
        }
    }
}
