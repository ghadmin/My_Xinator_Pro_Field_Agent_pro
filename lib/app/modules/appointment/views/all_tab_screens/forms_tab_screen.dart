
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/general_text_field.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_buttons.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/forms/forms_models.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/custom_fields_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/all_tab_screens/form_selection_screen.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/controllers/forms_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/service/helper/network_connectivity.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:remixicon/remixicon.dart';

class FormsTabScreen extends StatefulWidget {
  const FormsTabScreen({super.key});

  @override
  State<FormsTabScreen> createState() => _FormsTabScreenState();
}

class _FormsTabScreenState extends State<FormsTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  final CustomFieldsController customFieldsController =
      Get.find<CustomFieldsController>();
  final FormsController formsController = Get.find<FormsController>();

  @override
  void initState() {
    super.initState();

    final appointmentId =
        controller.selectedAppointment.value?.apptID?.toString() ?? '';
    if (appointmentId.isNotEmpty) {
      final resourceId = controller.selectedAppointment.value?.resourceID ?? 0;
      if (resourceId > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          formsController.pollPendingForms(resourceId);
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
        title: Text('Forms', style: WarmOrganicBlueTheme.headingMedium),
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
              Align(
                alignment: Alignment.centerRight,
                child: OrganicPrimaryButton(
                  text: 'Add New',
                  icon: Icons.add_rounded,
                  height: 40.h,
                  width: 140.w,
                  onPressed: () => Get.to(() => const FormSelectionScreen()),
                ),
              ),
              SizedBox(height: 10.h),

              formsController.pendingForms.isEmpty
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
                      itemCount: formsController.pendingForms
                          .where(
                            (f) =>
                                f.appointmentId ==
                                appointmentController
                                    .selectedAppointment
                                    .value!
                                    .apptID
                                    .toString(),
                          )
                          .length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildFormCard(
                            context,
                            formsController.pendingForms
                                .where(
                                  (f) =>
                                      f.appointmentId ==
                                      appointmentController
                                          .selectedAppointment
                                          .value!
                                          .apptID
                                          .toString(),
                                )
                                .toList()[index],
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

              IconButton(
                icon: Icon(
                  Remix.telegram_2_fill,
                  color: WarmOrganicBlueTheme.primaryBlue,
                ),
                iconSize: 20,
                onPressed: () async {
                  // Pre-fill customer email
                  final customerEmail =
                      controller.selectedAppointment.value?.customer?.email ??
                      '';
                  formsController.toTextController.text = customerEmail;
                  formsController.selectedFormForEmail.value = form;

                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    useSafeArea: true,
                    enableDrag: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            formsController.emailToFocusnode.value.unfocus();
                            formsController.emailSubjectFocusnode.value
                                .unfocus();
                            formsController.emailBodyFocusnode.value.unfocus();
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20.sp,
                              right: 20.sp,
                              bottom: 20.sp,
                              top: 5.sp,
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Send Form Email",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  SizedBox(height: 15.sp),
                                  GeneralTextField(
                                    hint: "To",
                                    theme: Theme.of(context),
                                    focusNode:
                                        formsController.emailToFocusnode.value,
                                    textInputType: TextInputType.emailAddress,
                                    textEditingController:
                                        formsController.toTextController,
                                  ),
                                  // SizedBox(height: 10.sp),
                                  // GeneralTextField(
                                  //   hint: "Cc",
                                  //   theme: Theme.of(context),
                                  //   focusNode:
                                  //       formsController.emailCcFocusnode.value,
                                  //   textInputType: TextInputType.emailAddress,
                                  //   textEditingController:
                                  //       formsController.ccTextController ??
                                  //       TextEditingController(),
                                  // ),
                                  SizedBox(height: 10.sp),
                                  GeneralTextField(
                                    hint: "Subject",
                                    maxLine: 3,
                                    theme: Theme.of(context),
                                    focusNode: formsController
                                        .emailSubjectFocusnode
                                        .value,
                                    textEditingController:
                                        formsController
                                            .subjectTextController ,
                                  ),
                                  SizedBox(height: 10.sp),
                                  GeneralTextField(
                                    hint: "Email body",
                                    theme: Theme.of(context),
                                    maxLine: 8,
                                    minLine: 6,
                                    focusNode: formsController
                                        .emailBodyFocusnode
                                        .value,
                                    textInputType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    textEditingController:
                                        formsController
                                            .emailBodyTextController ,
                                  ),
                                  SizedBox(height: 20.sp),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 52.h,
                                          child: SecondaryButton(
                                            title: "Cancel",
                                            onPressed: () {
                                              formsController.toTextController
                                                  .clear();
                                              formsController.ccTextController
                                                  .clear();
                                              formsController
                                                  .subjectTextController
                                                  .clear();
                                              formsController
                                                  .emailBodyTextController
                                                  .clear();
                                              Get.back();
                                            },
                                            inactive: false,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.sp),
                                      Expanded(
                                        child: SizedBox(
                                          height: 52.h,
                                          child: PrimaryButton(
                                            title: "Send",
                                            onPressed: () async {
                                              final success =
                                                  await formsController
                                                      .sendFormEmail(
                                                        form: form,
                                                      );
                                              // Only close and clear data if email sent successfully
                                              if (success == true) {
                                                formsController
                                                    .toTextController
                                                    .clear();
                                                formsController
                                                    .ccTextController
                                                    .clear();
                                                formsController
                                                    .subjectTextController
                                                    .clear();
                                                formsController
                                                    .emailBodyTextController
                                                    .clear();
                                                Get.back();
                                              }
                                              // If error, keep data in form and don't close
                                            },
                                            inactive: false,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 50.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                tooltip: 'Send Forms to Customer',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
            onPressed: () => formsController.viewForm(form),

            // onPressed: () async {
            //   kLog('selected form name ${form.template.name}');
            //   final jsonData = form.template.structure != '';
            //   if (!jsonData) {
            //     return MySnackBar.showErrorToast(
            //       message: "Form template structure is empty or invalid.",
            //     );
            //   }
            //   final config = {
            //     'form': jsonDecode(form.template.structure),
            //     'formInstanceId': form.formInstanceId,
            //     'templateId': form.templateId,
            //     'appointmentId': form.appointmentId,
            //     'customerId': form.customerId,
            //     'queueId': form.queueId,
            //     'formName': form.template.name,
            //   };

            //   if (form.smartFieldData.isNotEmpty) {
            //     try {
            //       final smartFieldValues =
            //           jsonDecode(form.smartFieldData) as Map<String, dynamic>;
            //       config['smartFieldValues'] = smartFieldValues;
            //       kLog(
            //         'SmartField values loaded: ${smartFieldValues.length} fields',
            //       );
            //     } catch (e) {
            //       kLog('Error parsing smartFieldData: $e');
            //     }
            //   }

            //   controller.showLoading();

            //   try {
            //     // Check if form has been submitted and has a formResponseId
            //     if (form.formResponseId != null && form.formResponseId! > 0) {
            //       kLog(
            //         'Fetching submitted form response: formResponseId=${form.formResponseId}',
            //       );
            //       final responseData = await formsController.getFormResponse(
            //         form.formResponseId!,
            //       );

            //       if (responseData != null) {
            //         config['formResponse'] = responseData;
            //         config['isReadOnly'] =
            //             true; // View-only mode for submitted forms
            //         kLog('✅ Form response data loaded');
            //       }
            //     } else if (form.instanceStatus == 'Submitted') {
            //       // For submitted forms from poll, use natural key (templateId + appointmentId + customerId)
            //       kLog(
            //         'Fetching submitted form by natural key: templateId=${form.templateId}, appointmentId=${form.appointmentId}, customerId=${form.customerId}',
            //       );
            //       final responseData = await formsController
            //           .getFormResponseByNaturalKey(
            //             templateId: form.templateId,
            //             appointmentId: form.appointmentId,
            //             customerId: form.customerId,
            //           );

            //       if (responseData != null) {
            //         config['formResponse'] = responseData;
            //         config['isReadOnly'] =
            //             true; // View-only mode for submitted forms
            //         kLog('✅ Form response data loaded by instance');
            //       }
            //     }

            //     // Construct PDF URL using pdfBaseUrl + path from template
            //     // Validate that pdfFile and path exist
            //     final pdfFile = config['form']?['pdfFile'];
            //     if (pdfFile == null || pdfFile['path'] == null) {
            //       MySnackBar.showErrorToast(
            //         message: "Form data not found - PDF file path is missing.",
            //       );
            //       kLog('⚠️ Form data invalid: pdfFile or path is null');
            //       Future.delayed(Duration.zero, () {
            //         controller.hideLoading();
            //       });
            //       return;
            //     }

            //     final pdfUrl = ApiUrl.pdfBaseUrl + pdfFile['path'];
            //     final pdfBase64 = await formsController.getFormPdfAsBase64(
            //       pdfUrl,
            //     );

            //     controller.hideLoading();

            //     if (pdfBase64 == null) {
            //       MySnackBar.showErrorToast(
            //         message: "Failed to load form PDF.",
            //       );
            //       return;
            //     }

            //     config['pdfBase64'] = pdfBase64;
            //     Get.toNamed(Routes.PDF_DYNAMIC_FORM, arguments: config);
            //   } catch (e, s) {
            //     controller.hideLoading();
            //     kLog(e);
            //     kLog(s);
            //     MySnackBar.showErrorToast(
            //       message: "Forms data not found - Error loading form: $e",
            //     );
            //   }
            // },
          ),
        ],
      ),
    );
  }
}
