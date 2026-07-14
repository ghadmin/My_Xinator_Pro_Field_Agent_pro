import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/controllers/forms_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/forms/forms_models.dart';

class FormSelectionScreen extends StatefulWidget {
  const FormSelectionScreen({super.key});

  @override
  State<FormSelectionScreen> createState() => _FormSelectionScreenState();
}

class _FormSelectionScreenState extends State<FormSelectionScreen> {
  late final FormsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FormsController>();

    // Fetch templates on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchFormTemplates();
    });
  }

  @override
  void dispose() {
    // Don't delete the controller - it's shared across screens
    // Just clear the selection when leaving
    _controller.clearTemplateSelection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text('Select Forms', style: WarmOrganicBlueTheme.headingMedium),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: WarmOrganicBlueTheme.deepNavy),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Show loading skeleton
        if (_controller.isLoadingTemplates.value) {
          return _buildLoadingSkeleton();
        }

        // Show error state
        if (_controller.templatesError.value) {
          return _buildErrorState();
        }

        // Show empty state
        if (_controller.availableFormTemplates.isEmpty) {
          return _buildEmptyState();
        }

        // Show form list
        return _buildFormList();
      }),
      floatingActionButton: Obx(() {
        if (_controller.selectedTemplatesCount > 0) {
          return FloatingActionButton.extended(
            onPressed: _handleSave,
            backgroundColor: WarmOrganicBlueTheme.primaryBlue,
            label: Text(
              'Save',
              style: WarmOrganicBlueTheme.buttonLabel.copyWith(fontSize: 15.sp),
            ),
            elevation: 4,
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        // Search bar skeleton
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                WarmOrganicBlueTheme.radiusMd,
              ),
            ),
          ),
        ),

        // Header skeleton
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonLine(width: 120.w, height: 20.h),
                    SizedBox(height: 8.h),
                    _buildSkeletonLine(width: 180.w, height: 14.h),
                  ],
                ),
              ),
              _buildSkeletonBox(width: 80.w, height: 32.h),
            ],
          ),
        ),

        // Form cards skeleton
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 4,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _buildFormCardSkeleton(),
          ),
        ),
      ],
    );
  }

  /// Build skeleton line
  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  /// Build skeleton box
  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  /// Build form card skeleton
  Widget _buildFormCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
      ),
      child: Row(
        children: [
          // Checkbox skeleton
          _buildSkeletonBox(width: 24.w, height: 24.w),
          SizedBox(width: 16.w),

          // Icon skeleton
          _buildSkeletonBox(width: 48.w, height: 48.w),
          SizedBox(width: 16.w),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonLine(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                _buildSkeletonLine(width: 200.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: WarmOrganicBlueTheme.statusRed,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: WarmOrganicBlueTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _controller.templatesErrorMessage.value.isNotEmpty
                  ? _controller.templatesErrorMessage.value
                  : 'Failed to load forms. Please check your connection and try again.',
              style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                color: WarmOrganicBlueTheme.coolGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _controller.retryFetchTemplates,
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Retry', style: WarmOrganicBlueTheme.buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: WarmOrganicBlueTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    WarmOrganicBlueTheme.radiusMd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64.sp,
              color: WarmOrganicBlueTheme.coolGray,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Forms Available',
              style: WarmOrganicBlueTheme.headingSmall,
            ),
            SizedBox(height: 8.h),
            Text(
              'There are no forms configured for your account yet.',
              style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                color: WarmOrganicBlueTheme.coolGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please contact your administrator to set up forms.',
              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                color: WarmOrganicBlueTheme.coolGray.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build form list
  Widget _buildFormList() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: TextField(
            controller: _controller.templateSearchController,
            onChanged: (value) {
              // Controller handles search via listener
            },
            decoration: InputDecoration(
              hintText: 'Search forms...',
              hintStyle: WarmOrganicBlueTheme.bodyMedium.copyWith(
                color: WarmOrganicBlueTheme.coolGray,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: WarmOrganicBlueTheme.coolGray,
                size: 20.sp,
              ),
              suffixIcon: Obx(() {
                if (_controller.templateSearchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: WarmOrganicBlueTheme.coolGray,
                      size: 20.sp,
                    ),
                    onPressed: _controller.clearTemplateSearch,
                  );
                }
                return const SizedBox.shrink();
              }),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  WarmOrganicBlueTheme.radiusMd,
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  WarmOrganicBlueTheme.radiusMd,
                ),
                borderSide: BorderSide(
                  color: WarmOrganicBlueTheme.warmSilver,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  WarmOrganicBlueTheme.radiusMd,
                ),
                borderSide: BorderSide(
                  color: WarmOrganicBlueTheme.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),

        // Form options list
        Expanded(
          child: Obx(() {
            final filteredOptions = _controller.filteredFormTemplates;

            if (filteredOptions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48.sp,
                      color: WarmOrganicBlueTheme.coolGray,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No forms found',
                      style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                        color: WarmOrganicBlueTheme.coolGray,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Try a different search term',
                      style: WarmOrganicBlueTheme.bodySmall.copyWith(
                        color: WarmOrganicBlueTheme.coolGray.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filteredOptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final option = filteredOptions[index];
                return Obx(
                  () => _buildFormOptionCard(
                    option,
                    _controller.isTemplateSelected(option.id),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );

  }

  Widget _buildFormOptionCard(FormOption option, bool isSelected) {
    return GestureDetector(
      onTap: () => _controller.toggleTemplateSelection(option),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? WarmOrganicBlueTheme.primaryBlue
                : WarmOrganicBlueTheme.warmSilver,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: WarmOrganicBlueTheme.primaryBlue.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : WarmOrganicBlueTheme.subtleShadow,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? WarmOrganicBlueTheme.primaryBlue
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? WarmOrganicBlueTheme.primaryBlue
                        : WarmOrganicBlueTheme.coolGray.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                    : null,
              ),

              SizedBox(width: 16.w),

              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: WarmOrganicBlueTheme.primaryBlueSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  option.icon,
                  color: WarmOrganicBlueTheme.primaryBlue,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: WarmOrganicBlueTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 4.h),
                    Text(
                      option.description,
                      style: WarmOrganicBlueTheme.bodySmall.copyWith(
                        color: WarmOrganicBlueTheme.coolGray,
                      ),
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

  void _handleSave() async {
    if (_controller.selectedTemplatesCount == 0) return;

    // Get selected form names
    final selectedForms = _controller.getSelectedTemplates();

    kLog('Selected forms: ${selectedForms.map((f) => f.name).toList()}');

    // Show loading
    _controller.showLoading(); final appointmentController = Get.find<AppointmentController>();
    
  final selectedAppointment =
          appointmentController.selectedAppointment.value;
    try {
      // Get appointment data from AppointmentController
     

      if (selectedAppointment == null) {
        _controller.hideLoading();
        MySnackBar.showErrorToast(message: 'No appointment selected');
        return;
      }

      // Get appointment ID and customer ID from selected appointment
      final appointmentId = selectedAppointment.apptID?.toString() ?? '';
      final customerId =
          selectedAppointment.customer!.customerID?.toString() ?? '';

      kLog('Appointment ID: $appointmentId, Customer ID: $customerId');

      if (appointmentId.isEmpty) {
        _controller.hideLoading();
        MySnackBar.showErrorToast(message: 'Appointment ID not found');
        return;
      }

      // Attach selected forms to the appointment
      final response = await _controller.attachSelectedFormsToAppointment(
        appointmentId: appointmentId,
        customerId: customerId,
      );

      _controller.hideLoading();

      if (response != null) {
        // Navigate back to show success
        Get.back(result: true);
      }
    } catch (e) {
      _controller.hideLoading();
      kLog('❌ Error in _handleSave: $e');
    } finally {
      _controller.pollPendingForms(selectedAppointment!.resourceID);
    }
  }
}
