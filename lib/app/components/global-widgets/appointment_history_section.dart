import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../modules/appointment/models/appointment_model.dart';

/// Shared "Appointment History" section fed by GetCustomerAppointments
/// (CustomerController.customerAppointmentHistory). Shown under the CSL tab
/// screen and the Customers drawer tab → customer details.
///
/// Renders the paged history list with loading / empty states and a
/// load-more row; the header carries a refresh action. Brings its own
/// padding — wrap it in a padding-free card (e.g. `OrganicCard(padding:
/// EdgeInsets.zero, ...)` or `Card(...)`).
class AppointmentHistorySection extends StatelessWidget {
  final RxList<Appointments> history;
  final RxBool isLoading;
  final RxBool hasMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  const AppointmentHistorySection({
    super.key,
    required this.history,
    required this.isLoading,
    required this.hasMore,
    required this.onRefresh,
    required this.onLoadMore,
  });

  /// Same mapping as the status badges in appointment_details_view.
  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "installation in progress":
      case "installation progress":
        return const Color(0xffE98862);
      case "scheduled":
        return const Color(0xff2E888B);
      case "cancelled":
        return Colors.red;
      case "completed":
        return const Color(0xff0CBC8B);
      case "pending":
        return const Color(0xFFFFC107);
      case "closed":
        return const Color(0xFF607D8B);
      case "dispatched":
        return const Color(0xFF42A5F5);
      case "in-route":
      case "in route":
        return const Color(0xFFFF9800);
      case "arrived":
        return const Color(0xFF8BC34A);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// The history rows carry StartDateTime as "yyyy/MM/dd hh:mm a" (same as
  /// GetAppointmentList); fall back to ISO parsing, then to the raw string.
  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return "N/A";
    try {
      DateTime? dt;
      try {
        dt = DateFormat("yyyy/MM/dd hh:mm a").parse(raw);
      } catch (_) {
        dt = DateTime.tryParse(raw);
      }
      if (dt == null) return raw;
      return DateFormat("EEE, MMM d, yyyy • h:mm a").format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// header
          Row(
            children: [
              Expanded(
                child: Text(
                  "Appointment History",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onRefresh(),
                icon: Icon(Icons.refresh_rounded, size: 22.sp),
                color: const Color(0xFF007AFF),
                tooltip: 'Refresh',
              ),
            ],
          ),
          Obx(() {
            if (isLoading.value && history.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (history.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    "No appointment history found",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                ...history.map(_historyTile),
                if (hasMore.value)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: isLoading.value
                        ? Padding(
                            padding: EdgeInsets.all(10.r),
                            child: SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : TextButton.icon(
                            onPressed: () => onLoadMore(),
                            icon: Icon(
                              Icons.expand_more_rounded,
                              size: 18.sp,
                            ),
                            label: Text(
                              "Load More",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _historyTile(Appointments appt) {
    final serviceName = appt.serviceType?.serviceName;
    final statusName = appt.status?.statusName;
    final statusColor = _statusColor(statusName);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  [
                    if (appt.apptID != null) "#${appt.apptID}",
                    if (serviceName != null && serviceName.isNotEmpty)
                      serviceName,
                  ].join("  ·  "),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (statusName != null && statusName.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.event_rounded, size: 15.sp, color: Colors.grey.shade500),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _formatDateTime(appt.startDateTime),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          if (appt.timeSlot != null && appt.timeSlot!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 15.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      appt.timeSlot!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (appt.note != null && appt.note!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 15.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      appt.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
