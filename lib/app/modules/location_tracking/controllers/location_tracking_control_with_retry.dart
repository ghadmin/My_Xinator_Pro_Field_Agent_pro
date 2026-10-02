import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/location_tracking/controllers/location_tracking_controller.dart' show LocationTrackingController;
import 'package:myxinator_pro_field_agent_pro/app/service/location/models/location_tracking_status.dart';


/// Enhanced location tracking control with debugging and retry options
class LocationTrackingControlWithRetry extends StatelessWidget {
  const LocationTrackingControlWithRetry({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationTrackingController>(
      init: LocationTrackingController(),
      builder: (controller) => Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main tracking control
              Row(
                children: [
                  Icon(
                    controller.isTrackingEnabled.value
                        ? Icons.location_on
                        : Icons.location_off,
                    color: controller.isTrackingEnabled.value
                        ? Colors.green
                        : Colors.grey,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Tracking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getStatusText(controller.trackingStatus.value),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.isTrackingEnabled.value,
                    onChanged: (_) async {
                      if (controller.isTrackingEnabled.value) {
                        await controller.stopTracking();
                      } else {
                        await controller.startTracking();
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Error message display
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:Icon( Icons.close),
                        onPressed: () => controller.errorMessage.value = '',
                        iconSize: 16,
                      ),
                    ],
                  ),
                ),

              // Retry button if tracking is not enabled but should be
              if (!controller.isTrackingEnabled.value &&
                  controller.trackingStatus.value == LocationTrackingStatus.stopped)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Retry Start Tracking'),
                    onPressed: () => controller.retryStartTracking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Current location display
              if (controller.currentLocation.value != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.my_location, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lat: ${controller.currentLocation.value!.latitude.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Lng: ${controller.currentLocation.value!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Accuracy: ${controller.currentLocation.value!.accuracy.toStringAsFixed(1)}m',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),

              // Debug information (collapsed by default)
              ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.bug_report, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Debug Info', style: TextStyle(fontSize: 12)),
                  ],
                ),
                tilePadding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 8),
                  _buildDebugRow('Permissions', controller.hasPermissions.value ? "Granted" : "Not Granted"),
                  _buildDebugRow('Tracking', controller.isTrackingEnabled.value ? "Enabled" : "Disabled"),
                  _buildDebugRow('Status', controller.trackingStatus.value.toString()),
                  if (controller.lastLocationTime.value != null)
                    _buildDebugRow('Last Location', controller.lastLocationTime.value.toString()),
                  _buildDebugRow('Errors', controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : "None"),
                ],
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh'),
                      onPressed: () => controller.refreshStatus(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.settings),
                      label: Text('Permissions'),
                      onPressed: () => controller.requestPermissions(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getStatusText(LocationTrackingStatus status) {
    switch (status) {
      case LocationTrackingStatus.stopped:
        return 'Stopped - Tap to enable';
      case LocationTrackingStatus.starting:
        return 'Starting...';
      case LocationTrackingStatus.tracking:
        return 'Active - Tracking your location';
      case LocationTrackingStatus.offline:
        return 'Offline - Queueing locations';
      case LocationTrackingStatus.apiError:
        return 'API Error - Retrying';
      case LocationTrackingStatus.stale:
        return 'Not Syncing - Check connection';
      case LocationTrackingStatus.permissionDenied:
        return 'Permission Denied - Enable in settings';
      case LocationTrackingStatus.gpsDisabled:
        return 'GPS Disabled - Enable location service';
      case LocationTrackingStatus.stoppedByUser:
        return 'Stopped';
    }
  }
}