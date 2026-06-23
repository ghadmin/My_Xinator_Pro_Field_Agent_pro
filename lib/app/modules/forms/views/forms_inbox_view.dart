import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/klog.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/form_widget/pdf_dynamic_form.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../models/forms/forms_models.dart';
import '../controllers/forms_controller.dart';
import '../binding/form_bindings.dart';

class FormsInboxView extends GetView<FormsController> {
  const FormsInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load forms from Hive when the view is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resourceId = MySharedPref.getResourceID();
      if (resourceId != null) {
        await controller.loadPendingFormsFromHive(resourceId.toString());
      }
    });

    var theme = Theme.of(context);
    return Scaffold(
      appBar: Get.size.width <= 440
          ? AppBar(
              title: const Text("Forms Inbox"),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 18.sp),
                  child: SizedBox(
                    width: 35.sp,
                    height: 35.sp,
                    child: CircleAvatar(
                      child: ClipOval(
                        child: AssetImageBox(
                          height: 35.sp,
                          width: 35.sp,
                          assetImage: AppImages.kDemoUser,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(40.sp),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: AppBar(
                  title: Padding(
                    padding: EdgeInsets.only(top: 8.sp),
                    child: Text(
                      "Forms Inbox",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 18.sp, top: 8.sp),
                      child: SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircleAvatar(
                          child: ClipOval(
                            child: AssetImageBox(
                              height: 20.sp,
                              width: 20.sp,
                              assetImage: AppImages.kDemoUser,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      drawer: CustomDrawer(indexClicked: 1),
      body: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pending Forms",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Forms assigned to you",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: LightThemeColors.hintTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: RefreshIndicator(
                  color: theme.primaryColor,
                  onRefresh: () async {
                    final resourceId = MySharedPref.getResourceID();
                    if (resourceId != null) {
                      await controller.pollPendingForms(resourceId);
                    }
                  },
                  child: controller.isPolling.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.pendingForms.isEmpty
                      ? EmptyWidget(
                          title: "No Forms Found",
                          onPressed: () async {
                            final resourceId = MySharedPref.getResourceID();
                            if (resourceId != null) {
                              await controller.pollPendingForms(resourceId);
                            }
                          },
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: controller.pendingForms.length,
                          itemBuilder: (context, index) {
                            final form = controller.pendingForms[index];
                            return _buildFormCard(context, form, theme);
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 15.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    FormQueueItem form,
    ThemeData theme,
  ) {
    final statusColor = _getStatusColor(controller.getFormStatus(form));
    final statusText = controller.getFormStatus(form);

    return SplashContainer(
      radius: 8,
      color: Colors.white,
      onPressed: () async {
        controller.selectForm(form);

        // Acknowledge the form when opened
        // await controller.acknowledgeForm(form.queueId);

        // Navigate to dynamic form filling view
        _navigateToDynamicForm(form);
      },
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.template.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (form.template.description.isNotEmpty) ...[
                      SizedBox(height: 2.sp),
                      Text(
                        form.template.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: LightThemeColors.hintTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 4.sp),
                    Text(
                      "Appointment: #${form.appointmentId}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LightThemeColors.hintTextColor,
                      ),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      "Created: ${dateTimeConverter(inputFormat: "yyyy-MM-ddTHH:mm:ss", inputTime: form.createdDateTime.toIso8601String(), outputFormat: "MM/dd/yyyy hh:mm a")}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LightThemeColors.hintTextColor,
                      ),
                    ),
                    if (form.sendToCustomerOnSubmit) ...[
                      SizedBox(height: 4.sp),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14.sp,
                            color: theme.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Will email customer",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 100.sp,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.sp,
                        vertical: 5.sp,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: statusColor,
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    Text(
                      "Tap to open",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
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

  Future<void> _navigateToDynamicForm(FormQueueItem form) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Parse template structure
      final templateStructure = jsonDecode(form.template.structure);
      final fields = templateStructure['fields'] as List? ?? [];

      // Get PDF bytes
      Uint8List? pdfBytes;
      try {
        pdfBytes = await controller.getFormPdfBytes(form.template.id);
      } catch (e) {
        debugPrint('Could not load PDF: $e');
      }

      // Parse smart field data
      final smartFieldValues = controller.parseSmartFieldData(form);

      // Check if form is submitted and fetch response data
      List? responses;
      bool isReadOnly = false;

      if (form.instanceStatus == 'Submitted' ||
          controller.getFormStatus(form) == 'Submitted') {
        isReadOnly = true;

        // Try to fetch the submitted form response
        try {
          final responseData = await controller.getFormResponseByNaturalKey(
            templateId: form.templateId,
            appointmentId: form.appointmentId,
            customerId: form.customerId,
          );

          if (responseData != null && responseData.success == true) {
            responses = responseData.responses;
            kLog('Loaded form response with ${responses?.length ?? 0} field values');
          }
        } catch (e) {
          debugPrint('Could not load form response: $e');
          // Continue without response data - form will be empty
        }
      }

      Get.back();

      if (pdfBytes != null) {
        // Convert PDF bytes to base64
        final pdfBase64 = base64Encode(pdfBytes);

        // Navigate to PDF Dynamic Form (Web-based viewer)
        await Get.to(
          () => PdfDynamicForm(
            mode: PdfFormMode.viewer,
            config: {
              'pdfBase64': pdfBase64,
              'form': {
                'fields': fields,
              },
              'smartFieldValues': smartFieldValues,
              'formInstanceId': form.formInstanceId,
              'templateId': form.templateId,
              'appointmentId': form.appointmentId,
              'customerId': form.customerId,
              'queueId': form.queueId,
              'formName': form.template.name,
              // Add response data for pre-populating fields
              if (responses != null) 'responses': responses,
              'isReadOnly': isReadOnly,
            },
          ),
          binding: FormBindings(),
        );
      } else {
        Get.snackbar(
          'Error',
          'PDF not available for this form',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to load form: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':
        return const Color(0xff4CAF50);
      case 'In Progress':
        return const Color(0xffFF9800);
      default:
        return const Color(0xff9E9E9E);
    }
  }
}
