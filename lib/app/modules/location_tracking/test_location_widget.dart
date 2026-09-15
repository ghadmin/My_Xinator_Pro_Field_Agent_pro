import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/location/models/location_tracking_status.dart';
import 'controllers/location_tracking_controller.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple test widget to verify location tracking is working
class LocationTrackingTestWidget extends StatelessWidget {
  final LocationTrackingController controller = Get.put(LocationTrackingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracking Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Obx(() => Card(
              child: ListTile(
                leading: Icon(
                  controller.isTrackingEnabled.value ? Icons.location_on : Icons.location_off,
                  color: controller.isTrackingEnabled.value ? Colors.green : Colors.grey,
                ),
                title: Text('Location Tracking'),
                subtitle: Text(_getStatusText(controller.trackingStatus.value)),
                trailing: Switch(
                  value: controller.isTrackingEnabled.value,
                  onChanged: (_) => controller.toggleTracking(),
                ),
              ),
            )),

            // Error Message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Error: ${controller.errorMessage.value}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              return SizedBox();
            }),

            // Current Location
            Obx(() {
              final location = controller.currentLocation.value;
              if (location != null) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Location:'),
                        SizedBox(height: 8),
                        Text('Lat: ${location.latitude}, Lng: ${location.longitude}'),
                        Text('Accuracy: ${location.accuracy.toStringAsFixed(1)}m'),
                        Text('Time: ${location.recordedAt}'),
                      ],
                    ),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No location data yet'),
                ),
              );
            }),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.refreshStatus(),
                    child: Text('Refresh Status'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.requestPermissions(),
                    child: Text('Check Permissions'),
                  ),
                ),
              ],
            ),

            // Debug Info
            Obx(() => Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Permissions: ${controller.hasPermissions.value ? "Granted" : "Not Granted"}'),
                    Text('Tracking: ${controller.isTrackingEnabled.value ? "Enabled" : "Disabled"}'),
                    Text('Status: ${_getStatusText(controller.trackingStatus.value)}'),
                    if (controller.lastLocationTime.value != null)
                      Text('Last Location: ${controller.lastLocationTime.value}'),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getStatusText(LocationTrackingStatus status) {
    switch (status) {
      case LocationTrackingStatus.stopped:
        return 'Stopped';
      case LocationTrackingStatus.starting:
        return 'Starting...';
      case LocationTrackingStatus.tracking:
        return 'Active';
      case LocationTrackingStatus.offline:
        return 'Offline - Queueing';
      case LocationTrackingStatus.apiError:
        return 'API Error';
      case LocationTrackingStatus.stale:
        return 'Not Syncing';
      case LocationTrackingStatus.permissionDenied:
        return 'Permission Denied';
      case LocationTrackingStatus.gpsDisabled:
        return 'GPS Disabled';
      case LocationTrackingStatus.stoppedByUser:
        return 'Stopped';
    }
  }
}