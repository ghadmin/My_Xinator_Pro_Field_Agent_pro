import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/forms/forms_models.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/controllers/forms_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/routes/app_pages.dart';
import 'package:myxinator_pro_field_agent_pro/app/service/REST/api_urls.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/custom_fields_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';

class FormsTabScreen extends StatefulWidget {
  const FormsTabScreen({super.key});

  @override
  State<FormsTabScreen> createState() => _FormsTabScreenState();
}

class _FormsTabScreenState extends State<FormsTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  final CustomFieldsController customFieldsController =
      Get.find<CustomFieldsController>();
  FormsController? formsController;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<FormsController>()) {
      formsController = Get.find<FormsController>();
    } else {
      log("Creating new FormsController");
      formsController = Get.put(FormsController());
    }

    final appointmentId =
        controller.selectedAppointment.value?.apptID?.toString() ?? '';
    if (appointmentId.isNotEmpty) {
      final resourceId = controller.selectedAppointment.value?.resourceID ?? 0;
      if (resourceId > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          formsController?.pollPendingForms(resourceId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text(
          'Forms',
          style: WarmOrganicBlueTheme.headingMedium,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final appointmentId =
            controller.selectedAppointment.value?.apptID?.toString() ?? '';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              SizedBox(height: 8.h),

              formsController!.pendingForms.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          OrganicEmptyState(
                            icon: Icons.description_outlined,
                            title: 'No Forms',
                            subtitle: appointmentId.isNotEmpty
                                ? 'No forms attached to this appointment.'
                                : 'Select an appointment to view forms.',
                          ),
                          SizedBox(height: 50.h),
                        ],
                      ),
                    )
                  : ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: formsController!.pendingForms.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildFormCard(
                            context,
                            formsController!.pendingForms[index],
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormCard(BuildContext context, FormQueueItem form) {
    final status = formsController?.getFormStatus(form) ?? 'Pending';
    final statusColor = formsController?.getFormStatusColor(form) ?? '#9E9E9E';

    return OrganicCard(
      margin: EdgeInsets.only(bottom: 12.h),
      shadow: WarmOrganicBlueTheme.softShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  form.template.name,
                  style: WarmOrganicBlueTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(statusColor.replaceFirst('#', '0xFF')),
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Color(
                      int.parse(statusColor.replaceFirst('#', '0xFF')),
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Color(
                      int.parse(statusColor.replaceFirst('#', '0xFF')),
                    ),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (form.template.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              form.template.description,
              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                color: WarmOrganicBlueTheme.coolGray,
              ),
            ),
          ],

          SizedBox(height: 8.h),

          OrganicSecondaryButton(
            text: 'View Form',
            icon: Icons.visibility_rounded,
            height: 32.h,
            width: double.infinity,
            onPressed: () async {
              kLog('selected form name ${form.template.name}');
              final jsonData = form.template.structure != '';
              if (!jsonData) {
                return MySnackBar.showErrorToast(
                  message: "Form template structure is empty or invalid.",
                );
              }
              final config = {
                'form': jsonDecode(form.template.structure),
                'formInstanceId': form.formInstanceId,
                'templateId': form.templateId,
                'appointmentId': form.appointmentId,
                'customerId': form.customerId,
                'queueId': form.queueId,
                'formName': form.template.name,
              };

              if (form.smartFieldData.isNotEmpty) {
                try {
                  final smartFieldValues =
                      jsonDecode(form.smartFieldData) as Map<String, dynamic>;
                  config['smartFieldValues'] = smartFieldValues;
                  kLog(
                    'SmartField values loaded: ${smartFieldValues.length} fields',
                  );
                } catch (e) {
                  kLog('Error parsing smartFieldData: $e');
                }
              }

              controller.showLoading();

              try {
                final pdfBase64 = await formsController?.getFormPdfAsBase64(
                  ApiUrl.pdfBaseUrl + config['form']['pdfFile']['path'],
                );

                controller.hideLoading();

                if (pdfBase64 == null) {
                  MySnackBar.showErrorToast(
                    message: "Failed to load form PDF.",
                  );
                  return;
                }

                config['pdfBase64'] = pdfBase64;
                Get.toNamed(Routes.PDF_DYNAMIC_FORM, arguments: config);
              } catch (e) {
                controller.hideLoading();
                MySnackBar.showErrorToast(message: "Error loading PDF: $e");
              }
            },
          ),
        ],
      ),
    );
  }
}
