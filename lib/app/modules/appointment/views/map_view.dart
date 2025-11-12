// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class RouteMapScreen extends StatefulWidget {
//   final String destinationAddress;

//   const RouteMapScreen({required this.destinationAddress, super.key});

//   @override
//   State<RouteMapScreen> createState() => _RouteMapScreenState();
// }

// class _RouteMapScreenState extends State<RouteMapScreen> {
//   GoogleMapController? _controller;
//   LatLng? _currentLocation;
//   LatLng? _destinationLocation;
//   Set<Polyline> _polylines = {};
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _initLocations();
//   }

//   Future<void> _initLocations() async {
//     try {
//       // ✅ Ask for permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.deniedForever) {
//         setState(() => _error = "Location permission permanently denied");
//         return;
//       }
//       log("permssion granted $permission");
//       // ✅ Get current location
//       final pos = await Geolocator.getCurrentPosition(
//           locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
//       _currentLocation = LatLng(pos.latitude, pos.longitude);

//       // ✅ Geocode destination address
//       final locations = await locationFromAddress(widget.destinationAddress)
//           .timeout(const Duration(seconds: 10), onTimeout: () => []);

//       if (locations.isEmpty) {
//         setState(() => _error = "Could not find location for given address.");
//         return;
//       }

//       final dest = locations.first;
//       _destinationLocation = LatLng(dest.latitude, dest.longitude);

//       // ✅ Draw simple route line
//       _drawRoute(_currentLocation!, _destinationLocation!);

//       setState(() {});
//     } catch (e) {
//       setState(() {
//         _error = "Error loading map: $e";
//       });
//     }
//   }

//   void _drawRoute(LatLng origin, LatLng destination) {
//     log("message: Drawing route from $origin to $destination");
//     final polyline = Polyline(
//       polylineId: const PolylineId("route"),
//       color: Colors.blue,
//       width: 5,
//       points: [origin, destination],
//     );
//     _polylines = {polyline};
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Route Map")),
//         body: Center(child: Text(_error!)),
//       );
//     }

//     if (_currentLocation == null || _destinationLocation == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Route Map")),
//       body: GoogleMap(
//         initialCameraPosition:
//             CameraPosition(target: _currentLocation!, zoom: 12),
//         onMapCreated: (controller) => _controller = controller,
//         myLocationEnabled: true,
//         markers: {
//           Marker(
//               markerId: const MarkerId("origin"),
//               position: _currentLocation!,
//               infoWindow: const InfoWindow(title: "You are here")),
//           Marker(
//               markerId: const MarkerId("destination"),
//               position: _destinationLocation!,
//               infoWindow: InfoWindow(title: widget.destinationAddress)),
//         },
//         polylines: _polylines,
//       ),
//     );
//   }
// }
