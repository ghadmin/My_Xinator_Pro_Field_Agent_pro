import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/empty_widget.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';
import 'package:xinator_fsm_pro/app/modules/forms/controllers/form_controller.dart';
import 'package:xinator_fsm_pro/config/theme/light_theme_colors.dart';

class FormView extends GetView<FormController> {
  const FormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  // Create new template action
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
                                  // Create new template action
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
                                                      onPressed: () {},
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.blue),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.settings,
                                                          color: Colors.cyan),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.copy,
                                                          color: Colors.grey),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {},
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
}
