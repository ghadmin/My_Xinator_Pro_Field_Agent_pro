import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/location_tracking/controllers/location_tracking_controller.dart' show LocationTrackingController;

import '../../../service/location/models/location_tracking_status.dart';


/// Simple location tracking control widget that can be added to any page
/// Usage: Just add LocationTrackingControl() to any page in your app
class LocationTrackingControl extends StatelessWidget {
  const LocationTrackingControl({Key? key}) : super(key: key);

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

              // Show error message if present
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
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
                    ],
                  ),
                ),

              // Show last location if available
              if (controller.currentLocation.value != null)
                Container(
                  margin: EdgeInsets.only(top: 12),
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
                        'Lat: ${controller.currentLocation.value!.latitude.toStringAsFixed(6)}, '
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
            ],
          ),
        ),
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