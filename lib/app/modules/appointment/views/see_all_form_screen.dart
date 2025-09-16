import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart'
    show TextWidget;
import 'package:xinator_fsm_pro/app/modules/appointment/controllers/appointment_controller.dart'
    show AppointmentController;
import 'package:xinator_fsm_pro/app/modules/appointment/views/appointment_details_view.dart';
import 'package:xinator_fsm_pro/app/modules/forms/controllers/form_controller.dart';

import '../../../components/global-widgets/empty_widget.dart';
import '../../forms/models/form_model.dart';

class SeeAllFormsScreen extends StatefulWidget {
  int initialTabIndex;
  SeeAllFormsScreen({super.key, required this.initialTabIndex});

  @override
  State<SeeAllFormsScreen> createState() => _SeeAllFormsScreenState();
}

class _SeeAllFormsScreenState extends State<SeeAllFormsScreen> {
  AppointmentController controller = Get.find<AppointmentController>();
  FormController formC = Get.find<FormController>();

  @override
  Widget build(BuildContext context) {
    // Return a default widget if neither condition is met

    if (widget.initialTabIndex == 0) {
      return Scaffold(
          appBar: Get.size.width <= 440
              ? AppBar(
                  title: Text("Attached Forms"),
                  centerTitle: true,
                )
              : PreferredSize(
                  preferredSize: Size.fromHeight(40.sp),
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.sp),
                    child: AppBar(
                      title: Text("Attached Forms"),
                      centerTitle: true,
                    ),
                  ),
                ),
          body: _buildFilteredTemplatesView());
    } else {
      return Scaffold(
          appBar: Get.size.width <= 440
              ? AppBar(
                  title: Text("Add Forms"),
                  centerTitle: true,
                )
              : PreferredSize(
                  preferredSize: Size.fromHeight(40.sp),
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.sp),
                    child: AppBar(
                      title: Text("Add Forms"),
                      centerTitle: true,
                    ),
                  ),
                ),
          floatingActionButton: formC.selectedFormsIdList.isNotEmpty
              ? FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    await formC.assignFormsToAppointment(
                        controller
                            .selectedAppointment.value!.customer!.customerID!,
                        controller.selectedAppointment.value!.apptID
                            .toString());
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : SizedBox.shrink(),
          body: _buildAllFormsView());
    }
  }

  Widget _buildFilteredTemplatesView() {
    final filteredTemplates = formC.formModels
        .where((template) => formC.selectedFormsIdList.contains(template.id))
        .toList();

    if (filteredTemplates.isEmpty) {
      return EmptyWidget(
        onPressed: () {
          formC.getAttachedForms(isRefreshed: true);
        },
        isRefreshShown: true,
        title: "No forms attached yet",
      );
    }

    return Column(
      children: [
        SizedBox(height: 5.h),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTemplates.length,
            itemBuilder: (context, index) {
              final template = filteredTemplates[index];
              return GestureDetector(
                  onTap: () {
                    showDetailsForms(
                        context: context, formC: formC, data: template);
                  },
                  child: _buildFormCard(template, false));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllFormsView() {
    return Obx(() {
      final filteredTemplates = formC.searchQuery.value.isEmpty
          ? formC.formModels
          : formC.formModels
              .where((template) =>
                  template.templateName
                      ?.toLowerCase()
                      .contains(formC.searchQuery.value.toLowerCase()) ??
                  false)
              .toList();

      return Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: "Search templates...",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12.w, right: 8.w),
                    child: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
                onChanged: (value) {
                  formC.updateSearchQuery(value);
                },
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: filteredTemplates.isEmpty
                ? EmptyWidget(
                    onPressed: () {
                      formC.getAttachedForms(isRefreshed: true);
                    },
                    isRefreshShown: true,
                    title: "No forms found",
                  )
                : ListView.builder(
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      return GestureDetector(
                        onTap: () {
                          showDetailsForms(
                              context: context, formC: formC, data: template);
                        },
                        child: _buildFormCard(template, true),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildFormCard(dynamic template, bool showCheckbox) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox for selection (only shown in All Forms view)
                if (showCheckbox)
                  Obx(
                    () => Checkbox(
                      activeColor: Colors.blue,
                      value: formC.selectedFormsIdList.contains(template.id),
                      onChanged: (value) {
                        formC.updateSelectedForms(template.id!);
                      },
                    ),
                  ),
                Expanded(
                  child: TextWidget(
                    text: template.templateName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: template.isActive! ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    template.isActive! ? "Active" : "Inactive",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            TextWidget(
              text: template.description ?? "",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Category: ${template.category}",
                    style: TextStyle(fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text("Signature: ", style: TextStyle(fontSize: 13.sp)),
                    Icon(
                      template.requireSignature!
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: template.requireSignature!
                          ? Colors.green
                          : Colors.red,
                      size: 18.sp,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "Auto-Assign: ${template.isAutoAssignEnabled! ? "Yes" : "No"}",
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for showDetailsForms method
  void showDetailsForms({
    required BuildContext context,
    required FormModel data,
    required FormController formC,
  }) {
    ;
    final descriptionC = TextEditingController(text: data.description);
    final categoryC = TextEditingController(text: data.category);
    final titleC = TextEditingController(text: data.templateName);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 0.9.sh,
                maxWidth: 0.9.sw,
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Form Details",
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      // Template Name
                      TextField(
                        controller: titleC,
                        enabled: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Template Name *",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Category
                      TextFormField(
                        enabled: false,
                        readOnly: true, // Makes it non-interactive
                        controller: categoryC, // Display the API value
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          // Optional: Add a suffix icon to make it look more like a dropdown
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                        ),
                        // Optional: Style the text inside
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 12.h),
                      // Description
                      TextField(
                        enabled: false, readOnly: true,
                        maxLines: 3, // Makes it non-interactive
                        controller: descriptionC,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Checkboxes
                      Wrap(
                        runSpacing: 8.h,
                        spacing: 12.w,
                        children: [
                          CheckboxListTile(
                            value: data.requireSignature,
                            onChanged: (v) {},
                            title: Text("Require Signature",
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.requireTip,
                            onChanged: (v) {},
                            title: Text("Enable Tip Capture",
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.isAutoAssignEnabled,
                            onChanged: (v) {},
                            title: Text("Auto-assign to appointment types",
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          ),
                          CheckboxListTile(
                            value: data.isActive,
                            onChanged: (v) {},
                            title: Text("Active",
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Buttons
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12.w,
                        children: [
                          // TextButton(
                          //   onPressed: () => Navigator.pop(context),
                          //   child: Text("Cancel",
                          //       style: TextStyle(fontSize: 14.sp)),
                          // ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text("Close",
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
