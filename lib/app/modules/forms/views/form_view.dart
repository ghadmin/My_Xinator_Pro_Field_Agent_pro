import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/drawer/custom_drawer.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/empty_widget.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';
import 'package:xinator_fsm_pro/app/modules/forms/controllers/form_controller.dart';
import 'package:xinator_fsm_pro/app/modules/forms/models/create_new_form_template_model.dart'
    show CreateNewFormModel;
import 'package:xinator_fsm_pro/app/routes/app_pages.dart';
import 'package:xinator_fsm_pro/config/theme/light_theme_colors.dart';

import '../models/form_model.dart';

class FormView extends GetView<FormController> {
  const FormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomDrawer(indexClicked: 1),
        backgroundColor:
            LightThemeColors.scaffoldBackgroundColor, // light background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight:
              Platform.isAndroid ? kToolbarHeight : kToolbarHeight + 50,
          centerTitle: true,
          title: const Text(
            "Templates",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Obx(() {
          final filteredTemplates = controller.searchQuery.value.isEmpty
              ? controller.formModels
              : controller.formModels
                  .where((template) =>
                      template.templateName?.toLowerCase().contains(
                          controller.searchQuery.value.toLowerCase()) ??
                      false)
                  .toList();
          return Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  // Top image
                  controller.formModels.isEmpty
                      ? Column(
                          children: [
                            EmptyWidget(
                              onPressed: () {},
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(height: 20),

                            // Button
                            SizedBox(
                              width: 250.w,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  controller
                                      .createNewFormData(CreateNewFormModel());
                                  showCreateNewTemplateDialog(context: context);
                                },
                                child: const Text(
                                  "+ Create New Template",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(14),
                                ),
                                onPressed: () {
                                  showCreateNewTemplateDialog(context: context);
                                },
                                child: const Text(
                                  "+ New Template",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Explicit white background
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Search templates...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14.sp,
                                    ),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(
                                          left: 12.w, right: 8.w),
                                      child: Icon(
                                        Icons.search,
                                        size: 20.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    border: InputBorder
                                        .none, // ← Critical: Removes default border & padding
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    fillColor: Colors.white,
                                    filled:
                                        true, // ← Still needed, but now controlled by container
                                  ),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                  ),
                                  onChanged: (value) {
                                    controller.updateSearchQuery(value);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: filteredTemplates.length,
                                  itemBuilder: (context, index) {
                                    final template = filteredTemplates[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: TextWidget(
                                                    text:
                                                        template.templateName!,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 25.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 4.h),
                                                  decoration: BoxDecoration(
                                                    color: template.isActive!
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                  ),
                                                  child: Text(
                                                    template.isActive!
                                                        ? "Active"
                                                        : "Inactive",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.sp),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            TextWidget(
                                              text: template.description ?? "",
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey),
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            "Category: ${template.category}",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    13.sp)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Text("Signature: ",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    13.sp)),
                                                        Icon(
                                                          template.requireSignature!
                                                              ? Icons
                                                                  .check_circle
                                                              : Icons.cancel,
                                                          color: template
                                                                  .requireSignature!
                                                              ? Colors.green
                                                              : Colors.red,
                                                          size: 18.sp,
                                                        ),
                                                        SizedBox(width: 4.w),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                        "Auto-Assign: ${template.isAutoAssignEnabled! ? "Yes" : "No"}",
                                                        style: TextStyle(
                                                            fontSize: 13.sp)),
                                                    SizedBox(height: 8.h),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        showCreateNewTemplateDialog(
                                                            context: context,
                                                            template: template);
                                                      },
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.blue),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Get.toNamed(Routes
                                                            .FORMS_CREATE_DRAGG_DROP);
                                                      },
                                                      icon: Icon(Icons.settings,
                                                          color: Colors.cyan),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.copy,
                                                          color: Colors.grey),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        controller
                                                            .isActiveUpdate(
                                                                template);
                                                      },
                                                      icon: Icon(
                                                          template.isAutoAssignEnabled!
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Colors.amber),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ));
        }));
  }

  void showCreateNewTemplateDialog({
    required BuildContext context,
    FormModel? template,
  }) {
    TextEditingController templateNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    if (template != null) {
      templateNameController.text = template.templateName ?? "";
      descriptionController.text = template.description ?? "";
      controller.createNewFormData(CreateNewFormModel(
        id: template.id ?? 0,
        templateName: template.templateName,
        category: template.category,
        description: template.description,
        signature: template.requireSignature ?? false,
        tpCapture: template.requireTip ?? false,
        autoAssignAppointment: template.isAutoAssignEnabled ?? false,
        isActive: template.isActive ?? false,
      ));
    }
    log("template id ${controller.createNewFormData.value?.id}");
    showDialog(
        context: context,
        barrierDismissible: true, // true = tap outside to dismiss
        builder: (BuildContext context) {
          return Dialog(
            insetPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: Obx(() {
              final data = controller.createNewFormData.value ??
                  CreateNewFormModel(); // initialize if null

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template != null
                            ? "Edit Form Template"
                            : "New Form Template",
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),

                      // Template Name
                      TextField(
                        controller: templateNameController,
                        onChanged: (value) {
                          controller.createNewFormData(
                            CreateNewFormModel(
                              id: data.id,
                              templateName: value,
                              category: data.category,
                              description: data.description,
                              signature: data.signature,
                              tpCapture: data.tpCapture,
                              autoAssignAppointment: data.autoAssignAppointment,
                              isActive: data.isActive,
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: "Template Name *",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Category
                      DropdownButtonFormField<String>(
                        value: data.category,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: [
                          "Maintenance",
                          "Installation",
                          "Repair",
                          "Inspection",
                          "Other"
                        ]
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (val) {
                          controller.createNewFormData(
                            CreateNewFormModel(
                              templateName: data.templateName,
                              category: val,
                              id: data.id,
                              description: data.description,
                              signature: data.signature,
                              tpCapture: data.tpCapture,
                              autoAssignAppointment: data.autoAssignAppointment,
                              isActive: data.isActive,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        onChanged: (value) {
                          controller.createNewFormData(
                            CreateNewFormModel(
                              templateName: data.templateName,
                              category: data.category,
                              description: value,
                              id: data.id,
                              signature: data.signature,
                              tpCapture: data.tpCapture,
                              autoAssignAppointment: data.autoAssignAppointment,
                              isActive: data.isActive,
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Checkboxes
                      Wrap(
                        runSpacing: 8.h,
                        spacing: 12.w,
                        children: [
                          CheckboxListTile(
                            value: data.signature,
                            onChanged: (v) {
                              controller.createNewFormData(
                                CreateNewFormModel(
                                  templateName: data.templateName,
                                  category: data.category,
                                  description: data.description,
                                  signature: v ?? false,
                                  id: data.id,
                                  tpCapture: data.tpCapture,
                                  autoAssignAppointment:
                                      data.autoAssignAppointment,
                                  isActive: data.isActive,
                                ),
                              );
                            },
                            title: Text("Require Signature",
                                style: TextStyle(fontSize: 14.sp)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors
                                .blue, // Background color of checkbox when selected
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.tpCapture,
                            onChanged: (v) {
                              controller.createNewFormData(
                                CreateNewFormModel(
                                  templateName: data.templateName,
                                  category: data.category,
                                  id: data.id,
                                  description: data.description,
                                  signature: data.signature,
                                  tpCapture: v ?? false,
                                  autoAssignAppointment:
                                      data.autoAssignAppointment,
                                  isActive: data.isActive,
                                ),
                              );
                            },
                            title: Text("Enable Tip Capture",
                                style: TextStyle(fontSize: 14.sp)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors
                                .blue, // Background color of checkbox when selected
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.autoAssignAppointment,
                            onChanged: (v) {
                              controller.createNewFormData(
                                CreateNewFormModel(
                                  id: data.id,
                                  templateName: data.templateName,
                                  category: data.category,
                                  description: data.description,
                                  signature: data.signature,
                                  tpCapture: data.tpCapture,
                                  autoAssignAppointment: v ?? false,
                                  isActive: data.isActive,
                                ),
                              );
                            },
                            title: Text("Auto-assign to appointment types",
                                style: TextStyle(fontSize: 14.sp)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors
                                .blue, // Background color of checkbox when selected
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.isActive,
                            onChanged: (v) {
                              controller.createNewFormData(
                                CreateNewFormModel(
                                  templateName: data.templateName,
                                  category: data.category,
                                  description: data.description,
                                  id: data.id,
                                  signature: data.signature,
                                  tpCapture: data.tpCapture,
                                  autoAssignAppointment:
                                      data.autoAssignAppointment,
                                  isActive: v ?? false,
                                ),
                              );
                            },
                            title: Text("Active",
                                style: TextStyle(fontSize: 14.sp)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors
                                .blue, // Background color of checkbox when selected
                            checkColor: Colors.white,
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton(
                            onPressed: data.templateName != null &&
                                    data.templateName != "" &&
                                    data.category != null &&
                                    data.description != null &&
                                    data.description != ""
                                ? () async {
                                    template != null
                                        ? await controller.updateFormTemplate()
                                        : await controller.saveFormTemplate();
                                    Get.back();
                                  }
                                : () {
                                    print("calling 1 ");
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: data.templateName != null &&
                                      data.templateName != "" &&
                                      data.category != null &&
                                      data.description != null &&
                                      data.description != ""
                                  ? Colors.blue
                                  : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text("Save Template",
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
