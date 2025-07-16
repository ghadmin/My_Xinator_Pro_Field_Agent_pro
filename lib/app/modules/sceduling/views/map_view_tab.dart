import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewTab extends StatelessWidget {
  const MapViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _mapControlPanel(),
        Expanded(child: _osmMap()),
      ],
    );
  }

  Widget _mapControlPanel() {
    return Container(
      color: Colors.blueGrey.shade700,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Date Picker and Buttons
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Date",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () {
                    // showDatePicker()
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Reload"),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Optimize + Custom Marker
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("Optimize Route"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Add Custom Marker"),
              ),
              ToggleButtons(
                isSelected: const [true, false],
                onPressed: (index) {
                  // handle toggle
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("Map"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("Satellite"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Status Indicators
          Row(
            children: const [
              _StatusDot(color: Colors.orange, label: "Pending"),
              SizedBox(width: 10),
              _StatusDot(color: Colors.grey, label: "Dispatched"),
              SizedBox(width: 10),
              _StatusDot(color: Colors.blue, label: "In Route"),
              SizedBox(width: 10),
              _StatusDot(color: Colors.green, label: "Arrived"),
            ],
          ),
          const SizedBox(height: 10),

          // Row 4: Dropdown
          const Text(
            "Work Order Status",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            value: "All Statuses",
            items: const [
              DropdownMenuItem(
                  value: "All Statuses", child: Text("All Statuses")),
              DropdownMenuItem(value: "Pending", child: Text("Pending")),
              DropdownMenuItem(value: "Arrived", child: Text("Arrived")),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _osmMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(40.7128, -74.0060), // New York
        initialZoom: 10,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: LatLng(40.7128, -74.0060),
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
