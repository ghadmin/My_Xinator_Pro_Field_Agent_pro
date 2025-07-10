import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:xinator_fsm_pro/app/modules/sceduling/views/map_view_tab.dart';

class SchedulingView extends StatelessWidget {
  const SchedulingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dispatch Calendar"),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to CEC Appointments
              },
              child: Text(
                "CEC Appointments",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: const Color.fromARGB(255, 0, 69, 126),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            isScrollable: true,
            tabs: [
              Tab(text: "Date View"),
              Tab(text: "Resource View"),
              Tab(text: "List View"),
              Tab(text: "Map View"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DateViewTab(),
            _ViewIcon(icon: Icons.people_outline, label: "Resource View"),
            _ViewIcon(icon: Icons.list_alt, label: "List View"),
            MapViewTab(),
          ],
        ),
      ),
    );
  }
}

// 👉 Full detailed screen in the first tab (Date View)
class _DateViewTab extends StatelessWidget {
  const _DateViewTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filterControls(theme),
            const SizedBox(height: 12),
            _dateNavigation(theme),
            const SizedBox(height: 12),
            _calendarArea(theme),
            const SizedBox(height: 20),
            _unassignedAppointmentsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _filterControls(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _dropdown(label: "View", items: ["Day", "Week"], theme: theme),
        _dropdown(
            label: "Filter",
            items: ["All Service", "IT Support"],
            theme: theme),
        _datePicker(),
      ],
    );
  }

  Widget _dateNavigation(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
        Text(
          "Mon, Jul 7",
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
        TextButton(
            onPressed: () {},
            child: Text("Today",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ))),
      ],
    );
  }

  Widget _calendarArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
          child: Text("Calendar View Placeholder",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ))),
    );
  }

  Widget _unassignedAppointmentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Unassigned Appointments",
            style: theme.textTheme.bodySmall
                ?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _dropdown(
            label: "Status", items: ["All Status", "Pending"], theme: theme),
        const SizedBox(height: 8),
        _dropdown(
            label: "Services",
            items: ["All Services", "IT Support"],
            theme: theme),
        const SizedBox(height: 8),
        _dropdown(
            label: "Province",
            items: ["All Provinces/Territories"],
            theme: theme),
        const SizedBox(height: 8),
        _dropdown(label: "Postal", items: ["All Postal Codes"], theme: theme),
      ],
    );
  }

  Widget _dropdown(
      {required String label,
      required List<String> items,
      required ThemeData theme}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: items.first,
      onChanged: (value) {},
      items: items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp, fontWeight: FontWeight.bold))))
          .toList(),
    );
  }

  Widget _datePicker() {
    return SizedBox(
      width: 160,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: "Date",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () {
          // Show date picker
        },
      ),
    );
  }
}

// 👉 Simple icon screen for other tabs
class _ViewIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ViewIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Colors.blue),
          const SizedBox(height: 10),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
