import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/time_slot_model.dart';

import '../controllers/create_appointment_controller.dart';

class CreateAppointmentView extends GetView<CreateAppointmentController> {
  const CreateAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Appointment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.currentStep.value > 0) {
              controller.backToCalendar();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content based on current step
              _buildStepContent(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildCalendarStep(theme);
      case 1:
        return _buildFormStep(theme);
      default:
        return _buildCalendarStep(theme);
    }
  }

  Widget _buildCalendarStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Choose an available date for your appointment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 20.h),
        _buildCalendarWidget(theme),
      ],
    );
  }

  Widget _buildCalendarWidget(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  controller.focusedDay.value = DateTime(
                    controller.focusedDay.value.year,
                    controller.focusedDay.value.month - 1,
                  );
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(controller.focusedDay.value),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  controller.focusedDay.value = DateTime(
                    controller.focusedDay.value.year,
                    controller.focusedDay.value.month + 1,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => SizedBox(
                    width: 40.w,
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),

          // Calendar days
          _buildCalendarDays(theme),
        ],
      ),
    );
  }

  Widget _buildCalendarDays(ThemeData theme) {
    final now = controller.focusedDay.value;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final startDayOffset = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    List<Widget> days = [];

    // Empty cells for days before first day of month
    for (int i = 0; i < startDayOffset; i++) {
      days.add(SizedBox(width: 40.w, height: 40.h));
    }

    // Days of the month
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(now.year, now.month, day);
      final isSelected =
          controller.selectedDay.value != null &&
          controller.selectedDay.value!.year == date.year &&
          controller.selectedDay.value!.month == date.month &&
          controller.selectedDay.value!.day == day;

      final isToday =
          DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == day;

      final isPastDay = date.isBefore(
        DateTime.now().subtract(Duration(days: 1)),
      );

      days.add(
        GestureDetector(
          onTap: isPastDay
              ? null
              : () {
                  controller.onDaySelected(date, date);
                },
          child: Container(
            width: 40.w,
            height: 40.h,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? theme.primaryColor : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: theme.primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isPastDay
                      ? Colors.grey.shade400
                      : Colors.black87,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Wrap(spacing: 4.w, runSpacing: 4.h, children: days),
        if (controller.selectedDay.value != null)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: ElevatedButton(
              onPressed: () {
                // If dates haven't been set yet (user didn't click a specific date),
                // set them using current day with default times
                if (controller.selectedStartDate.value == null) {
                  final today = controller.selectedDay.value ?? DateTime.now();
                  controller.selectedStartDate.value = DateTime(
                    today.year,
                    today.month,
                    today.day,
                    12, // 12:00 PM (noon)
                    0,
                  );
                  controller.selectedEndDate.value = DateTime(
                    today.year,
                    today.month,
                    today.day,
                    12, // 12:00 PM (noon)
                    30, // 12:30 PM
                  );
                }
                controller.currentStep.value = 1;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                minimumSize: Size(double.infinity, 45.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Continue to Appointment Details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment Information Section
        _buildAppointmentInfoForm(theme),

        SizedBox(height: 24.h),

        // Status & Scheduling Section
        _buildSectionHeader('Status & Scheduling', theme, Icons.schedule),
        SizedBox(height: 16.h),
        _buildStatusForm(theme),

        SizedBox(height: 24.h),

        // Any Details Section
        _buildSectionHeader('Any Details', theme, Icons.note),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: controller.notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any notes or comments here...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ),

        SizedBox(height: 24.h),

        // Customer Information Section
        _buildSectionHeader('Customer Information', theme, Icons.person),
        SizedBox(height: 16.h),
        _buildCustomerInfoForm(theme),

        SizedBox(height: 24.h),

        // Sites & Locations Section
        _buildSectionHeader('Sites & Locations', theme, Icons.location_on),
        SizedBox(height: 16.h),
        _buildSitesForm(theme),

        SizedBox(height: 32.h),

        // Submit button
        ElevatedButton(
          onPressed: controller.submitAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Create Appointment',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    ThemeData theme,
    IconData icon, {
    VoidCallback? onAddPressed,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 4.w),
        if (onAddPressed != null)
          GestureDetector(
            onTap: onAddPressed,
            child: Icon(Icons.add, color: theme.primaryColor, size: 20.sp),
          ),
      ],
    );
  }

  Widget _buildAppointmentInfoForm(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildClickableDateField(
                'Start Date',
                controller.getFormattedStartDate(),
                theme,
                isStartDate: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildClickableDateField(
                'End Date',
                controller.getFormattedEndDate(),
                theme,
                isStartDate: false,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Optional: Appointment Time Slot (for reference only)
        _buildDropdownField(
          'Calendar',
          controller.calendars,
          controller.selectedCalendar,
          (value) => controller.onCalendarSelected(value),
          theme,
        ),

        SizedBox(height: 16.h),
        Obx(
          () => controller.isAppointmentIdLoading.value
              ? Container(
                  decoration: BoxDecoration(
                    color: theme.disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.sp,
                        height: 12.sp,
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 20.sp,
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: theme.disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20.sp,
                        color: Colors.green,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          controller.appointmentIdController.text.isNotEmpty
                              ? 'Appointment ID: ${controller.appointmentIdController.text}'
                              : 'Appointment ID',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                controller
                                    .appointmentIdController
                                    .text
                                    .isNotEmpty
                                ? theme.textTheme.bodyMedium?.color
                                : theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        SizedBox(height: 16.h),
        _buildServiceTypeDropdown(theme),
        SizedBox(height: 16.h),
        _buildAppointmentTimeDropdown(theme),
        SizedBox(height: 16.h),
        Obx(
          () => _buildReadOnlyField(
            'Time Required',
            controller.timeRequired.value.isNotEmpty
                ? controller.timeRequired.value
                : 'Select service type',
            theme,
          ),
        ),
        SizedBox(height: 16.h),
        _buildResourceDropdown(theme),
      ],
    );
  }

  Widget _buildStatusForm(ThemeData theme) {
    return Column(
      children: [
        _buildStatusDropdown(theme),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildAppointmentTimeDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Time',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 4.h),
        Obx(
          () => controller.isLoadingTimeSlots.value
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading time slots...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : controller.timeSlotModels.isEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'No time slots available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedTimeSlot.value?.startTime,
                      isExpanded: true,
                      hint: Text('Select time slot (optional)'),
                      items: controller.timeSlotModels.toSet().toList().map((
                        TimeSlotModel slot,
                      ) {
                        return DropdownMenuItem<String>(
                          value: slot.startTime,
                          child: Text(slot.startTime),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        final selectedSlot = controller.timeSlotModels
                            .firstWhereOrNull(
                              (slot) => slot.startTime == value,
                            );
                        controller.selectedTimeSlot.value = selectedSlot;
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoForm(ThemeData theme) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;

      if (customer == null) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Customer Selected',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please select a customer to view their information',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final customerAddress = [
        customer.address1,
        customer.address2,
      ].where((part) => part != null && part.isNotEmpty).join(', ');

      final locationInfo = [
        customer.city,
        customer.state,
        customer.zipCode,
      ].where((part) => part != null && part.isNotEmpty).join(', ');

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Name Header
            if (customer.businessName != null &&
                customer.businessName!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 20.sp,
                        color: theme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          customer.businessName!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: Colors.grey.shade200),
                  SizedBox(height: 16.h),
                ],
              ),

            // Contact Person Name
            _buildInfoRow(
              'Contact Person',
              '${customer.title ?? ''} ${customer.firstName ?? ''} ${customer.lastName ?? ''}'
                  .trim(),
              Icons.person,
              theme,
            ),
            SizedBox(height: 8.h),

            // Job Title
            if (customer.jobTitle != null && customer.jobTitle!.isNotEmpty)
              _buildInfoRow('Job Title', customer.jobTitle!, Icons.work, theme),

            if (customer.jobTitle != null && customer.jobTitle!.isNotEmpty)
              SizedBox(height: 8.h),
            if (customer.jobTitle != null && customer.jobTitle!.isNotEmpty)
              Divider(color: Colors.grey.shade200),
            if (customer.jobTitle != null && customer.jobTitle!.isNotEmpty)
              SizedBox(height: 8.h),

            // Address
            if (customerAddress.isNotEmpty)
              _buildInfoRow(
                'Address',
                customerAddress,
                Icons.location_on,
                theme,
              ),

            if (customerAddress.isNotEmpty) SizedBox(height: 8.h),

            // Location (City, State, Zip)
            if (locationInfo.isNotEmpty)
              _buildInfoRow('Location', locationInfo, Icons.place, theme),

            if (locationInfo.isNotEmpty) SizedBox(height: 8.h),
            if (locationInfo.isNotEmpty) Divider(color: Colors.grey.shade200),
            if (locationInfo.isNotEmpty) SizedBox(height: 8.h),

            // Phone Numbers
            if (customer.phone != null && customer.phone!.isNotEmpty)
              _buildInfoRow('Phone', customer.phone!, Icons.phone, theme),

            if (customer.phone != null && customer.phone!.isNotEmpty)
              SizedBox(height: 8.h),

            if (customer.mobile != null && customer.mobile!.isNotEmpty)
              _buildInfoRow(
                'Mobile',
                customer.mobile!,
                Icons.smartphone,
                theme,
              ),

            if (customer.mobile != null && customer.mobile!.isNotEmpty)
              SizedBox(height: 8.h),
            if (customer.mobile != null && customer.mobile!.isNotEmpty)
              Divider(color: Colors.grey.shade200),
            if (customer.mobile != null && customer.mobile!.isNotEmpty)
              SizedBox(height: 8.h),

            // Email
            if (customer.email != null && customer.email!.isNotEmpty)
              _buildInfoRow('Email', customer.email!, Icons.email, theme),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade600),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSitesForm(ThemeData theme) {
    return _buildSiteDropdown(theme);
  }

  Widget _buildReadOnlyField(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableDateField(
    String label,
    String value,
    ThemeData theme, {
    required bool isStartDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () => controller.selectDateTime(
            context: Get.context!,
            isStartDate: isStartDate,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: theme.primaryColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value.contains('Select')
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    List<T> items,
    Rx<dynamic> selectedValue,
    Function(T?) onChanged,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(
              () => DropdownButton<T>(
                value: selectedValue.value == null || selectedValue.value == ''
                    ? null
                    : selectedValue.value as T?,
                isExpanded: true,
                hint: Text('Select'),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Obx(
          () => controller.isLoadingServiceTypes.value
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading service types...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedServiceType.value,
                      isExpanded: true,
                      hint: Text('Select'),
                      items: controller.serviceTypeModels.map((type) {
                        return DropdownMenuItem<int>(
                          value: type.serviceTypeId,
                          child: Text(type.serviceName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.onServiceTypeSelected(value);
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildResourceDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Resource',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Obx(
          () => controller.isLoadingResources.value
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading resources...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedResource.value,
                      isExpanded: true,
                      hint: Text('Select'),
                      items: controller.resourceModels.isEmpty
                          ? []
                          : controller.resourceModels.map((resource) {
                              return DropdownMenuItem<int>(
                                value: resource.id,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      resource.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (resource.description.isNotEmpty)
                                      Text(
                                        resource.description,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                              fontSize: 11.sp,
                                            ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                      onChanged: (value) {
                        controller.selectedResource.value = value;
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.selectedStatus.value,
                isExpanded: true,
                hint: Text('Select'),
                items: controller.statuses.map((status) {
                  return DropdownMenuItem<int>(
                    value: status['id'] as int,
                    child: Text(status['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedStatus.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sites & Locations',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => _showSiteDialog(theme),
              child: Icon(
                Icons.add_circle,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Obx(
          () => controller.isLoadingSites.value
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading sites...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : controller.sites.isEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'No sites available. Add a site first.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedSite.value,
                      isExpanded: true,
                      hint: Text('SELECT'),
                      items: controller.sites.map((site) {
                        return DropdownMenuItem<int>(
                          value: site['id'] as int?,
                          child: Text(site['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedSite.value = value;
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showSiteDialog(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: Text('Add'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Person Information Section
              Text(
                'Contact Person Information',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'First Name',
                controller.siteFirstNameController,
                theme,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Last Name',
                controller.siteLastNameController,
                theme,
              ),
              SizedBox(height: 12.h),
              _buildSiteCountryDropdown(theme),
              SizedBox(height: 12.h),
              _buildSiteProvinceDropdown(theme),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Zip/Postal Code',
                controller.siteZipCodeController,
                theme,
              ),

              SizedBox(height: 20.h),

              // Site Information Section
              Text(
                'Site Information',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Site Name',
                controller.siteNameController,
                theme,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Address',
                controller.siteAddressController,
                theme,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField('City', controller.siteCityController, theme),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Site Contact',
                controller.siteContactController,
                theme,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Email',
                controller.siteEmailController,
                theme,
                isEmail: true,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Phone Number',
                controller.sitePhoneNumberController,
                theme,
                isPhone: true,
              ),
              SizedBox(height: 12.h),
              _buildSiteTextField(
                'Note',
                controller.siteNoteController,
                theme,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSiteForm();
              Navigator.of(Get.overlayContext!).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.saveCustomerSite,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteTextField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    bool isEmail = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSiteCountryDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: ValueListenableBuilder(
              valueListenable: controller.siteCountryController,
              builder: (context, value, child) {
                return DropdownButton<String>(
                  value: value.text.isEmpty ? null : value.text,
                  isExpanded: true,
                  hint: Text('Select Country'),
                  items: ['CANADA', 'USA'].map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.siteCountryController.text = val;
                      // Clear province when country changes
                      controller.siteStateController.clear();
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteProvinceDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Province/State',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: ValueListenableBuilder(
              valueListenable: controller.siteCountryController,
              builder: (context, countryValue, child) {
                return ValueListenableBuilder(
                  valueListenable: controller.siteStateController,
                  builder: (context, provinceValue, child) {
                    // Determine which list to show based on selected country
                    final List<String> options = countryValue.text == 'CANADA'
                        ? controller.canadianProvinces
                        : countryValue.text == 'USA'
                        ? controller.usStates
                        : [];

                    return DropdownButton<String>(
                      value: provinceValue.text.isEmpty
                          ? null
                          : provinceValue.text,
                      isExpanded: true,
                      hint: Text(
                        countryValue.text.isEmpty
                            ? 'Select Country First'
                            : 'Select Province/State',
                      ),
                      items: options.isEmpty
                          ? []
                          : options.map((province) {
                              return DropdownMenuItem<String>(
                                value: province,
                                child: Text(province),
                              );
                            }).toList(),
                      onChanged: options.isEmpty
                          ? null
                          : (value) {
                              if (value != null) {
                                controller.siteStateController.text = value;
                              }
                            },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
