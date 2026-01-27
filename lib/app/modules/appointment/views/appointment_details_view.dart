import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/url_launcher.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/main_divider.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/helper/dialog_helper.dart';
import '../../forms/controllers/form_controller.dart';
import '../../forms/models/form_model.dart';
import '../../item/models/item_list_model.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/custom_fields_controller.dart';
import '../models/custom_field_model.dart';
import '../models/note_model.dart';

class AppointmentDetailsView extends StatefulWidget {
  const AppointmentDetailsView({super.key});

  @override
  State<AppointmentDetailsView> createState() => _AppointmentDetailsViewState();
}

class _AppointmentDetailsViewState extends State<AppointmentDetailsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tabController1;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 7, vsync: this);
    _tabController1 = TabController(length: 2, vsync: this);
    _tabController1.addListener(() {
      if (_tabController1.index == 0) {
        // forms  tab index

        formC.selectAttachedForms();
      }
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // ignore swipe animation
      // formC.selectedFormsIdList.clear();
      if (_tabController.index == 2) {
        // forms  tab index
        formC.formModels.clear();
        formC.fetchTemplates();

        formC.selectAttachedForms();
      }
      if (_tabController.index == 1) {
        Future.delayed(Duration(seconds: 7));
        controller.isBasicExpanded(true);
      }
      if (_tabController.index == 0) {
        // Info tab - Load saved custom fields
        _loadSavedCustomFields();
      }
      if (_tabController.index == 4) {
        // Pictures tab index

        controller.getImageList(true);
      }
      if (_tabController.index == 5) {
        // Pictures tab index

        controller.getAllNotes(showLoader: true);
      }
    });
  }

  /// Load saved custom fields and populate them with values
  Future<void> _loadSavedCustomFields() async {
    try {
      final appointmentId = controller.selectedAppointment.value?.apptID;
      if (appointmentId == null) return;

      log("📥 Loading saved custom fields for appointment: $appointmentId");

      // Call API to get saved custom fields
      var response = await DioClient().get(
        url: "${ApiUrl.saveCustomFieldUrl}/$appointmentId",
      );

      if (response != null && response is Map) {
        String fieldsValueJson = response["FeildsValue"] ?? "[]";
        log("📥 Saved fields JSON: $fieldsValueJson");

        // Parse as array of objects: [{"type": "...", "value1": "...", "value2": "..."}]
        List<dynamic> savedFieldsArray = jsonDecode(fieldsValueJson);

        // Clear previously selected fields
        customFieldsController.selectedCustomFields.clear();

        // Add fields from saved data
        for (var fieldData in savedFieldsArray) {
          if (fieldData is! Map) continue;

          String? fieldType = fieldData["type"];
          String? value1 = fieldData["value1"];
          String? value2 = fieldData["value2"];

          if (fieldType == null) continue;

          // Find matching field definition from allCustomFields
          var fieldDef = customFieldsController.allCustomFields
              .firstWhereOrNull((f) => f.fieldName == fieldType);

          if (fieldDef != null) {
            // Create a new instance of the field
            var newField = CustomFieldModel(
              fieldID: fieldDef.fieldID,
              fieldName: fieldDef.fieldName,
              fieldType: fieldDef.fieldType,
              fieldOptions: fieldDef.fieldOptions,
              isActive: fieldDef.isActive,
              options: fieldDef.options,
            );

            // Set the value based on field type
            switch (fieldDef.fieldType) {
              case 'text':
                newField.textValue = value1;
                break;
              case 'number':
                newField.numberValue = value1;
                break;
              case 'dropdown':
                newField.selectedValue = value1;
                break;
              case 'checklist':
                // For checklist, value1 contains selected options (comma-separated)
                // value2 might contain additional options
                List<String> options = [];
                if (value1 != null && value1.isNotEmpty) {
                  options.addAll(value1.split(','));
                }
                if (value2 != null && value2.isNotEmpty) {
                  options.addAll(value2.split(','));
                }
                newField.selectedOptions = options;
                break;
            }

            // Add to selected fields
            customFieldsController.selectedCustomFields.add(newField);
          }
        }

        log(
          "✅ Loaded ${customFieldsController.selectedCustomFields.length} saved custom fields",
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      log("❌ Error loading saved custom fields: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppointmentController controller = Get.find<AppointmentController>();
  CustomFieldsController customFieldsController =
      Get.find<CustomFieldsController>();

  FormController formC = Get.find<FormController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Obx(
      () => Scaffold(
        floatingActionButton: SizedBox(
          height: (_tabController.index == 0 &&
                      customFieldsController.selectedCustomFields.isNotEmpty) ||
                  (_tabController1.index == 1 &&
                      formC.selectedFormsIdList.isNotEmpty)
              ? 120
              : 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Info tab Custom Fields Save FAB (tab index 0)
              if (_tabController.index == 0 &&
                  customFieldsController.selectedCustomFields.isNotEmpty)
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  heroTag: "save_custom_fields_info",
                  onPressed: () async {
                    await _saveCustomFields();
                  },
                  child: Icon(Icons.save, color: Colors.white),
                ),
              // Forms tab FAB (tab index 2)
              if (_tabController1.index == 1 &&
                  formC.selectedFormsIdList.isNotEmpty)
                SizedBox(height: 10),
              if (_tabController1.index == 1 &&
                  formC.selectedFormsIdList.isNotEmpty)
                FloatingActionButton(
                  backgroundColor: Colors.blue,
                  heroTag: "assign_forms",
                  onPressed: () async {
                    await formC.assignFormsToAppointment(
                      controller
                          .selectedAppointment.value!.customer!.customerID!,
                      controller.selectedAppointment.value!.apptID.toString(),
                    );
                  },
                  child: Icon(Icons.add, color: Colors.white),
                ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        appBar: Get.size.width <= 440
            ? AppBar(
                leading: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.blue,
                    size: 15.sp,
                  ),
                ),
                automaticallyImplyLeading: false,
                title: Text("Appointment Details"),
                centerTitle: false,
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(40.sp),
                child: Padding(
                  padding: EdgeInsets.only(top: 15.sp),
                  child: AppBar(
                    leading: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.blue,
                        size: 15.sp,
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    title: Text("Appointment Details"),
                    centerTitle: false,
                  ),
                ),
              ),
        body: controller.selectedAppointment.value == null
            ? Center(
                child: EmptyWidget(
                  isRefreshShown: false,
                  title: "No appointments",
                  onPressed: () {
                    Get.back();
                  },
                ),
              )
            : Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              controller.showLoading();
                              await controller.customerController
                                  .getCustomers();
                              controller.customerController.businessName =
                                  controller.contactName;
                              controller.customerController.title =
                                  controller.customerTitle;
                              controller.customerController.address =
                                  controller.address;
                              controller.customerController.phoneNumber =
                                  controller.phoneNumber;
                              controller.customerController.mobileNumber =
                                  controller.mobileNumber;
                              controller.customerController.email =
                                  controller.email;

                              controller.hideLoading();

                              Get.toNamed(Routes.CUSTOMER_DETAILS);
                            },
                            child: TextWidget(
                              text: controller.contactName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          MainDivider(),
                          SizedBox(height: 6.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    showDialogScheduled(context, controller);
                                  },
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        SizedBox(
                                          height: 30.h,
                                          width: 30.w,
                                          child: Material(
                                            shape: const CircleBorder(),
                                            color: LightThemeColors.primaryColor
                                                .withValues(alpha: .3),
                                            elevation: 6,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                6,
                                              ), // Reduced padding
                                              child: CircleAvatar(
                                                backgroundColor: getStatusColor(
                                                  controller
                                                          .settingController
                                                          .selectedAppointmentsStatus
                                                          .value
                                                          ?.statusName ??
                                                      "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        TextWidget(
                                          text: controller
                                                  .settingController
                                                  .selectedAppointmentsStatus
                                                  .value
                                                  ?.statusName ??
                                              "",
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        InkWell(
                                          onTap: () {
                                            showDialogTicketStatus(
                                              context,
                                              controller,
                                            );
                                          },
                                          child: Obx(
                                            () => Column(
                                              children: [
                                                SizedBox(
                                                  height: 30.h,
                                                  width: 30.w,
                                                  child: Material(
                                                    shape: const CircleBorder(),
                                                    color: LightThemeColors
                                                        .primaryColor
                                                        .withValues(alpha: .5),
                                                    elevation: 6,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        6,
                                                      ), // Reduced padding
                                                      child: CircleAvatar(
                                                        backgroundColor: controller
                                                                    .settingController
                                                                    .selectedTicket
                                                                    .value
                                                                    ?.statusName!
                                                                    .toLowerCase() ==
                                                                "Installation in Progress"
                                                                    .toLowerCase()
                                                            ? Color(0xffE98862)
                                                            : controller
                                                                        .settingController
                                                                        .selectedTicket
                                                                        .value
                                                                        ?.statusName!
                                                                        .toLowerCase() ==
                                                                    "On Hold"
                                                                        .toLowerCase()
                                                                ? Color
                                                                    .fromARGB(
                                                                    255,
                                                                    243,
                                                                    18,
                                                                    18,
                                                                  )
                                                                : controller
                                                                            .settingController
                                                                            .selectedTicket
                                                                            .value
                                                                            ?.statusName!
                                                                            .toLowerCase() ==
                                                                        "Parts on Order"
                                                                            .toLowerCase()
                                                                    ? Color
                                                                        .fromARGB(
                                                                        255,
                                                                        21,
                                                                        234,
                                                                        242,
                                                                      )
                                                                    : controller.settingController.selectedTicket.value?.statusName!.toLowerCase() ==
                                                                            "Completed"
                                                                                .toLowerCase()
                                                                        ? Color
                                                                            .fromARGB(
                                                                            255,
                                                                            11,
                                                                            197,
                                                                            145,
                                                                          )
                                                                        : Colors
                                                                            .red,
                                                        foregroundColor:
                                                            LightThemeColors
                                                                .primaryColor
                                                                .withValues(
                                                          alpha: .5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                TextWidget(
                                                  text: (controller
                                                                  .settingController
                                                                  .selectedTicket
                                                                  .value
                                                                  ?.statusName !=
                                                              null &&
                                                          controller
                                                                  .settingController
                                                                  .selectedTicket
                                                                  .value
                                                                  ?.statusName !=
                                                              "")
                                                      ? controller
                                                              .settingController
                                                              .selectedTicket
                                                              .value
                                                              ?.statusName ??
                                                          "N/A"
                                                      : "N/A",
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Icon(
                                          size: 15.sp,
                                          Icons.location_on_outlined,
                                          color: LightThemeColors.primaryColor,
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              await controller
                                                  .initializeWebController();
                                              showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    // Make dialog full width
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            width: double
                                                                .infinity, // ← This makes it full width
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                              20,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                15.r,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    12.sp,
                                                              ),
                                                              child: Obx(
                                                                () => Stack(
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        12.sp,
                                                                      ),
                                                                      child:
                                                                          WebViewWidget(
                                                                        controller:
                                                                            controller.webController!,
                                                                      ),
                                                                    ),
                                                                    if (controller
                                                                        .isLoading
                                                                        .value)
                                                                      const Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              Colors.blue,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10.sp),
                                                        SizedBox(
                                                          height: 45.sp,
                                                          width: 120.sp,
                                                          child: PrimaryButton(
                                                            title: "Done",
                                                            onPressed: () =>
                                                                Get.back(),
                                                            inactive: false,
                                                          ),
                                                        ),
                                                        SizedBox(height: 25.sp),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );

                                              // await openMapWithRoute(
                                              //     "mohakhali dhaka bangladesh");
                                            },
                                            child: TextWidget(
                                              text: controller.address,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.visible,
                                              maxLines: 5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    InkWell(
                                      onTap: controller.mobileNumber == ""
                                          ? () {}
                                          : () async {
                                              await UrlLauncher.phoneCall(
                                                controller.mobileNumber,
                                              );
                                            },
                                      child: Row(
                                        children: [
                                          Icon(
                                            size: 15.sp,
                                            Icons.phone_android_rounded,
                                            color:
                                                LightThemeColors.primaryColor,
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: TextWidget(
                                              text:
                                                  controller.mobileNumber == ""
                                                      ? "N/A"
                                                      : controller.mobileNumber,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    InkWell(
                                      onTap: controller.phoneNumber == ""
                                          ? () {}
                                          : () async {
                                              await UrlLauncher.phoneCall(
                                                controller.phoneNumber,
                                              );
                                            },
                                      child: Row(
                                        children: [
                                          Icon(
                                            size: 15.sp,
                                            Icons.call,
                                            color:
                                                LightThemeColors.primaryColor,
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: TextWidget(
                                              text: controller.phoneNumber == ""
                                                  ? "N/A"
                                                  : controller.phoneNumber,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    InkWell(
                                      onTap: controller.email == ""
                                          ? () {}
                                          : () async {
                                              await UrlLauncher.email(
                                                controller.email,
                                              );
                                            },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.email,
                                            size: 15.sp,
                                            color:
                                                LightThemeColors.primaryColor,
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: TextWidget(
                                              text: controller.email == ""
                                                  ? "N/A"
                                                  : controller.email,
                                              maxLines: 2,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 12.sp,
                                                overflow: TextOverflow.visible,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          MainDivider(),
                          SizedBox(height: 10.h),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.grey),
                              Icon(Icons.arrow_forward, color: Colors.grey),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: TabBar(
                              isScrollable: true,

                              dividerColor: LightThemeColors
                                  .primaryColor, // for line under tabs
                              indicatorColor: LightThemeColors
                                  .primaryColor, // underline indicator color
                              labelColor: LightThemeColors
                                  .primaryColor, // selected tab text/icon color
                              unselectedLabelColor:
                                  Colors.grey, // unselected tab text/icon color
                              indicatorWeight: 3.0,
                              controller: _tabController,
                              tabs: [
                                // index 0
                                TextWidget(
                                  text: "Info",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                // index 1
                                TextWidget(
                                  text: "CSL",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),

                                // index 2
                                TextWidget(
                                  text: "Forms",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                //index 3
                                TextWidget(
                                  text: "Estimate/Invoice",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                //index 4
                                TextWidget(
                                  text: "Pictures",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                //index 5
                                TextWidget(
                                  text: "Files",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                //index 6
                                TextWidget(
                                  text: "Notes",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          //********************************* Tab One Info*********************************/
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.h),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "Request Date",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.requestDate,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "Start Date",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.startDate,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "End Date",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.endDate,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "Time Slot",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.timeSlot,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "Service Type",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.serviceType,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: TextWidget(
                                    text: "Resource",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: TextWidget(
                                    text: controller.resource,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                MainDivider(),
                                ListTile(
                                  title: Row(
                                    children: [
                                      TextWidget(
                                        text: "Notes: ",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 40.w),
                                      Expanded(
                                        child: TextWidget(
                                          text: controller.noteController.text
                                                  .isNotEmpty
                                              ? controller.noteController.text
                                              : "No notes added",
                                          style: theme.textTheme.bodyMedium,
                                          overflow: TextOverflow.visible,
                                          maxLines: 10,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 18.sp,
                                          color: theme.primaryColor,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(12.sp),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text: "Notes",
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        color: LightThemeColors
                                                            .hintTextColor,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    GeneralTextField(
                                                      maxLine: 4,
                                                      minLine: 1,
                                                      textInputType:
                                                          TextInputType
                                                              .multiline,
                                                      textInputAction:
                                                          TextInputAction
                                                              .newline,
                                                      isEnabled: true,
                                                      hint: "Add a note here..",
                                                      theme: theme,
                                                      textEditingController:
                                                          controller
                                                              .noteController,
                                                      onChanged: (v) {
                                                        controller.isTyping(
                                                          true,
                                                        );
                                                        controller.noteText(v);
                                                      },
                                                      onEditingComplete: () {
                                                        controller.isTyping(
                                                          false,
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(height: 20.h),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 48.sp,
                                                      child: PrimaryButton(
                                                        title: "Update",
                                                        onPressed: () async {
                                                          await controller
                                                              .updateAppointment();
                                                          // Navigator.pop(
                                                          //     ctx); // close dialog after update
                                                        },
                                                        inactive: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                MainDivider(),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: Row(
                                    children: [
                                      TextWidget(
                                        text: "Custom Fields: ",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      //     // Make dropdown take remaining space
                                      Expanded(
                                        child: DropdownButton<CustomFieldModel>(
                                          isExpanded: true,
                                          iconSize: 20.sp, // important!
                                          icon: Icon(
                                            Icons.add,
                                            color: theme.primaryColor,
                                          ),
                                          underline: SizedBox(),
                                          value: null,
                                          items: customFieldsController
                                              .allCustomFields
                                              .map((field) {
                                            return DropdownMenuItem<
                                                CustomFieldModel>(
                                              value: field,
                                              child: Text(
                                                field.fieldName!,
                                                softWrap:
                                                    true, // wrap text instead of ellipsis
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              customFieldsController
                                                  .saveCustomField(value);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MainDivider(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: customFieldsController
                                      .selectedCustomFields.length,
                                  itemBuilder: (context, index) {
                                    final field = customFieldsController
                                        .selectedCustomFields[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Stack(
                                          children: [
                                            // Custom field content
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: 30.w,
                                              ), // Space for remove button
                                              child: buildCustomFieldWidget(
                                                field,
                                                context,
                                              ),
                                            ),
                                            // Remove button
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  customFieldsController
                                                      .selectedCustomFields
                                                      .removeAt(index);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8.r),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                          //********************************* Tab Two CSL *********************************/
                          Obx(
                            () => SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10.w,
                                      right: 10.w,
                                      top: 10.h,
                                    ),
                                    child: Card(
                                      color: LightThemeColors.primaryColor
                                          .withValues(alpha: 0.8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        title: Text(
                                          "Basic Information",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        trailing: Icon(
                                          controller.isBasicExpanded.value
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          size: 18.sp,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          controller.isBasicExpanded(
                                            !controller.isBasicExpanded.value,
                                          );
                                        }, // you can navigate or expand on tap
                                      ),
                                    ),
                                  ),
                                  if (controller.isBasicExpanded.value)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 5.h,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildRow(
                                            "Customer Name",
                                            controller
                                                    .selectedAppointment
                                                    .value!
                                                    .customer!
                                                    .firstName ??
                                                "${controller.selectedAppointment.value?.customer!.lastName}",
                                          ),
                                          _buildRow(
                                            "Site Contact",
                                            "📞 Phone: ${controller.selectedAppointment.value?.customer!.phone ?? "N/A"}\n📱 Mobile: ${controller.selectedAppointment.value?.customer!.mobile ?? "N/A"}",
                                          ),
                                          _buildRow(
                                            "Email",
                                            controller.selectedAppointment.value
                                                    ?.customer!.email ??
                                                "N/A",
                                            valueColor: Colors.blue,
                                          ),
                                          _buildRow(
                                            "Address",
                                            " ${controller.selectedAppointment.value?.customer!.address1 ?? ""}  ${controller.selectedAppointment.value?.customer!.address2 ?? ""}",
                                          ),
                                          // _buildRow("Status", " ${controller.selectedAppointment.value?.customer!. ?? "N/A"}",
                                          // valueColor: Colors.red),
                                          // _buildRow("Special Instructions", " ${controller.selectedAppointment.value.ins ?? "N/A"}"),
                                          _buildRow(
                                            "Created On",
                                            " ${controller.selectedAppointment.value?.customer!.createdDateTime ?? "N/A"}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 10.h),
                                  // Padding(
                                  //   padding: EdgeInsets.only(
                                  //       left: 10.w, right: 10.w, top: 10.h),
                                  //   child: Card(
                                  //     color: LightThemeColors.primaryColor
                                  //         .withValues(alpha: 0.8),
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(12.r),
                                  //     ),
                                  //     elevation: 2,
                                  //     child: ListTile(
                                  //       contentPadding: EdgeInsets.symmetric(
                                  //           horizontal: 16.w, vertical: 8.h),
                                  //       title: Text(
                                  //         "Equipment",
                                  //         style: TextStyle(
                                  //           fontSize: 16.sp,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //       trailing: Icon(
                                  //         controller.isEquipmentExpanded.value
                                  //             ? Icons.arrow_downward
                                  //             : Icons.arrow_upward,
                                  //         size: 18.sp,
                                  //         color: Colors.white,
                                  //       ),
                                  //       onTap: () {
                                  //         controller.isEquipmentExpanded(
                                  //             !controller.isEquipmentExpanded.value);
                                  //       }, // you can navigate or expand on tap
                                  //     ),
                                  //   ),
                                  // ),
                                  // if (controller.isEquipmentExpanded.value)
                                  //   Padding(
                                  //     padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  //     child: Container(
                                  //       padding: EdgeInsets.all(8),
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.white,
                                  //       ),
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           // Search Box
                                  //           SizedBox(
                                  //             height: 15.h,
                                  //           ),
                                  //           TextField(
                                  //             decoration: InputDecoration(
                                  //               hintText: "Search equipment...",
                                  //               hintStyle: TextStyle(
                                  //                   fontSize: 14.sp,
                                  //                   color: Colors.grey),
                                  //               contentPadding: EdgeInsets.symmetric(
                                  //                   horizontal: 12.w, vertical: 12.h),
                                  //               border: OutlineInputBorder(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(8.r),
                                  //                 borderSide: BorderSide(
                                  //                     color: Colors.grey.shade300),
                                  //               ),
                                  //               focusedBorder: OutlineInputBorder(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(8.r),
                                  //                 borderSide: BorderSide(
                                  //                     color: Colors.blue, width: 1.5),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           SizedBox(height: 12.h),

                                  //           // Add Equipment Button
                                  //           SizedBox(
                                  //             width: 60.w,
                                  //             child: ElevatedButton(
                                  //               onPressed: () {},
                                  //               style: ElevatedButton.styleFrom(
                                  //                 padding: EdgeInsets.symmetric(
                                  //                     vertical: 12.h),
                                  //                 backgroundColor: Colors.blueAccent,
                                  //                 shape: RoundedRectangleBorder(
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(8.r),
                                  //                 ),
                                  //               ),
                                  //               child: Text(
                                  //                 "Add",
                                  //                 style: TextStyle(
                                  //                     fontSize: 14.sp,
                                  //                     color: Colors.white),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           SizedBox(height: 16.h),

                                  //           SizedBox(
                                  //             height: 120
                                  //                 .h, // give a fixed height instead of Expanded
                                  //             child: Container(
                                  //               width: double.infinity,
                                  //               padding: EdgeInsets.all(16.w),
                                  //               decoration: BoxDecoration(
                                  //                 border: Border.all(
                                  //                     color: Colors.grey.shade300),
                                  //                 borderRadius: BorderRadius.vertical(
                                  //                   bottom: Radius.circular(8.r),
                                  //                 ),
                                  //               ),
                                  //               child: Center(
                                  //                 child: Text(
                                  //                   "No equipment found.",
                                  //                   style: TextStyle(
                                  //                     fontSize: 14.sp,
                                  //                     color: Colors.grey[600],
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                          ),
                          //********************************* Tab Three Forms *********************************/
                          Column(
                            children: [
                              SizedBox(height: 10.h),
                              TabBar(
                                isScrollable: false,
                                dividerColor: LightThemeColors.primaryColor,
                                indicatorColor: LightThemeColors.primaryColor,
                                labelColor: LightThemeColors.primaryColor,
                                unselectedLabelColor: Colors.grey,
                                indicatorWeight: 3.0,
                                controller: _tabController1,
                                tabs: [
                                  // First tab
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.greenAccent,
                                      width: double.infinity,
                                      child: TextWidget(
                                        text: "Attached Forms",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Second tab
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.blueAccent,
                                      width: double.infinity,
                                      child: TextWidget(
                                        text: "Add Forms",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_tabController1.index == 0) {
                                    formC.seeAllForms.assignAll(
                                      formC.filteredTemplates,
                                    );
                                  } else {
                                    formC.seeAllForms.assignAll(
                                      formC.formModels,
                                    );
                                  }

                                  Get.toNamed(
                                    Routes.SEEALLFORMS,
                                    arguments: {
                                      "tabIndex": _tabController1.index,
                                    },
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextWidget(text: "See All"),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController1,
                                  children: [
                                    Obx(() {
                                      formC.filteredTemplates.value =
                                          formC.formModels
                                              .where(
                                                (template) => formC
                                                    .selectedFormsIdList
                                                    .contains(template.id),
                                              )
                                              .toList();
                                      log(
                                        "filterd ${formC.formModels.where((template) => formC.selectedFormsIdList.contains(template.id)).toList()}",
                                      );
                                      // Handle empty or null case
                                      if (formC.filteredTemplates.isEmpty) {
                                        return EmptyWidget(
                                          onPressed: () {
                                            formC.getAttachedForms(
                                              isRefreshed: true,
                                            );
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
                                              itemCount: formC
                                                  .filteredTemplates.length,
                                              itemBuilder: (context, index) {
                                                final template = formC
                                                    .filteredTemplates[index];

                                                return Card(
                                                  margin: EdgeInsets.only(
                                                    bottom: 12.h,
                                                  ),
                                                  elevation: 2,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8.r,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      12.w,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            /// ✅ Checkbox for selection
                                                            Expanded(
                                                              child: TextWidget(
                                                                text: template
                                                                        .templateName ??
                                                                    "",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 8.w,
                                                                vertical: 4.h,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: template
                                                                        .isActive!
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .orange,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  12.r,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                template.isActive!
                                                                    ? "Active"
                                                                    : "Inactive",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.sp,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        TextWidget(
                                                          text: template
                                                                  .description ??
                                                              "",
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.h),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Category: ${template.category}",
                                                              style: TextStyle(
                                                                fontSize: 13.sp,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4.h,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Signature: ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13.sp,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  template.requireSignature!
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .cancel,
                                                                  color: template
                                                                          .requireSignature!
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                  size: 18.sp,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 4.h,
                                                            ),
                                                            Text(
                                                              "Auto-Assign: ${template.isAutoAssignEnabled! ? "Yes" : "No"}",
                                                              style: TextStyle(
                                                                fontSize: 13.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    Obx(() {
                                      final filteredTemplates =
                                          formC.searchQuery.value.isEmpty
                                              ? formC.formModels
                                              : formC.formModels
                                                  .where(
                                                    (template) =>
                                                        template.templateName
                                                            ?.toLowerCase()
                                                            .contains(
                                                              formC.searchQuery
                                                                  .value
                                                                  .toLowerCase(),
                                                            ) ??
                                                        false,
                                                  )
                                                  .toList();

                                      return Column(
                                        children: [
                                          SizedBox(height: 20.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.w,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                autofocus: false,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Search templates...",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 14.sp,
                                                  ),
                                                  prefixIcon: Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12.w,
                                                      right: 8.w,
                                                    ),
                                                    child: Icon(
                                                      Icons.search,
                                                      size: 20.sp,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  border: InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 14.h,
                                                  ),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.black,
                                                ),
                                                onChanged: (value) {
                                                  formC.updateSearchQuery(
                                                    value,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20.h),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount:
                                                  filteredTemplates.length,
                                              itemBuilder: (context, index) {
                                                final template =
                                                    filteredTemplates[index];

                                                return GestureDetector(
                                                  onTap: () {
                                                    showDetailsForms(
                                                      context: context,
                                                      formC: formC,
                                                      data: template,
                                                    );
                                                  },
                                                  child: Card(
                                                    margin: EdgeInsets.only(
                                                      bottom: 12.h,
                                                    ),
                                                    elevation: 2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        12.w,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              /// ✅ Checkbox for selection
                                                              Obx(
                                                                () => Checkbox(
                                                                  activeColor:
                                                                      Colors
                                                                          .blue,
                                                                  value: formC
                                                                      .selectedFormsIdList
                                                                      .contains(
                                                                    template.id,
                                                                  ),
                                                                  onChanged:
                                                                      (value) {
                                                                    formC
                                                                        .updateSelectedForms(
                                                                      template
                                                                          .id!,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    TextWidget(
                                                                  text: template
                                                                          .templateName ??
                                                                      "",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5.w,
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      8.w,
                                                                  vertical: 4.h,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: template
                                                                          .isActive!
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .orange,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12.r,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  template.isActive!
                                                                      ? "Active"
                                                                      : "Inactive",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 4.h),
                                                          TextWidget(
                                                            text: template
                                                                    .description ??
                                                                "",
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8.h),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Category: ${template.category}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4.h,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "Signature: ",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13.sp,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    template.requireSignature!
                                                                        ? Icons
                                                                            .check_circle
                                                                        : Icons
                                                                            .cancel,
                                                                    color: template.requireSignature!
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                    size: 18.sp,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 4.h,
                                                              ),
                                                              Text(
                                                                "Auto-Assign: ${template.isAutoAssignEnabled! ? "Yes" : "No"}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //********************************* Tab Four Estimate/Invoice *********************************/
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),
                                // ElevatedButton(
                                //     onPressed: () {
                                //       showProductDialog(context);
                                //     },
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(2.0),
                                //       child: Text("Store locator "),
                                //     )),
                                SizedBox(height: 10.h),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0.sp),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: TextWidget(
                                          text: "Estimate/Invoice Details",
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.sp),
                                      Builder(
                                        builder: (context) {
                                          return SplashContainer(
                                            height: 45.sp,
                                            width: 150.sp,
                                            radius: 5,
                                            color: theme.primaryColor,
                                            onPressed: () {
                                              RenderBox renderBox =
                                                  context.findRenderObject()
                                                      as RenderBox;
                                              Offset offset =
                                                  renderBox.localToGlobal(
                                                Offset(32.sp, 40.sp),
                                              );
                                              final RenderBox overlay =
                                                  Overlay.of(context)
                                                          .context
                                                          .findRenderObject()
                                                      as RenderBox;
                                              showMenu(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.r),
                                                  ),
                                                ),
                                                context: context,
                                                position: RelativeRect.fromRect(
                                                  offset &
                                                      Size(
                                                        32.sp,
                                                        32.sp,
                                                      ), // smaller rect, the touch area
                                                  Offset.zero &
                                                      overlay
                                                          .size, // Bigger rect, the entire screen
                                                ),
                                                items: controller
                                                    .invoiceController
                                                    .createTypes
                                                    .map((e) {
                                                  return PopupMenuItem(
                                                    value: e["name"],
                                                    child: TextWidget(
                                                      text: "${e["name"]}",
                                                    ),
                                                  );
                                                }).toList(),
                                              ).then((v) async {
                                                if (v != null) {
                                                  controller.invoiceController
                                                      .clearAllItems();
                                                  controller
                                                      .invoiceController
                                                      .selectedCreateType
                                                      .value = v;

                                                  final x = MySharedPref
                                                          .getCompanyType() ??
                                                      '';
                                                  controller
                                                      .invoiceController
                                                      .isLocAndClassShow
                                                      .value = x == 'IsPcs';
                                                  if (v == "Invoice") {
                                                    controller.invoiceController
                                                            .createCustomerName =
                                                        controller.contactName;
                                                    controller.invoiceController
                                                            .createCustomerAddress =
                                                        controller.address;
                                                    controller.invoiceController
                                                            .createCustomerPhone =
                                                        controller.mobileNumber;
                                                    controller.invoiceController
                                                            .createCustomerEmail =
                                                        controller.email;
                                                    controller.invoiceController
                                                            .customerID.value =
                                                        controller.customerID;
                                                    controller.invoiceController
                                                            .appointmentID =
                                                        controller
                                                            .appointmentID;
                                                    controller
                                                        .invoiceController
                                                        .selectedTaxID
                                                        .value = "";
                                                    controller.invoiceController
                                                        .createDiscountTextController
                                                        .clear();
                                                    await controller
                                                        .invoiceController
                                                        .getInvoiceName();
                                                    Get.toNamed(
                                                      Routes.INVOICE_CREATE,
                                                    );
                                                  } else {
                                                    controller.invoiceController
                                                            .createCustomerName =
                                                        controller.contactName;
                                                    controller.invoiceController
                                                            .createCustomerAddress =
                                                        controller.address;
                                                    controller.invoiceController
                                                            .createCustomerPhone =
                                                        controller.mobileNumber;
                                                    controller.invoiceController
                                                            .createCustomerEmail =
                                                        controller.email;
                                                    controller.invoiceController
                                                            .customerID.value =
                                                        controller.customerID;

                                                    controller.invoiceController
                                                            .appointmentID =
                                                        controller
                                                            .appointmentID;
                                                    controller
                                                        .invoiceController
                                                        .selectedTaxID
                                                        .value = "";
                                                    controller.invoiceController
                                                        .createDiscountTextController
                                                        .clear();
                                                    await controller
                                                        .invoiceController
                                                        .getInvoiceName();
                                                    // controller.invoiceController
                                                    //     .isNoneSelected(false);
                                                    Get.toNamed(
                                                      Routes.INVOICE_CREATE,
                                                    );
                                                  }
                                                }
                                              });
                                            },
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.white,
                                                    size: 18.sp,
                                                  ),
                                                  SizedBox(width: 5.sp),
                                                  TextWidget(
                                                    text: "Create New",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15.sp),
                                Obx(
                                  () => ListView.separated(
                                    itemBuilder: (context, index) {
                                      final proposal = controller
                                          .sortedAppointments[
                                              controller.selectedAptIndex.value]
                                          .invoices![index];

                                      return GestureDetector(
                                        onTap: () async {
                                          controller.showLoading();

                                          // Save backup if we were in "new" mode before switching to "existing"
                                          if (controller.invoiceController
                                                  .existingItemType.value ==
                                              SelectedItemCategory.newOne) {
                                            controller.invoiceController
                                                .saveBackup("new");
                                          }

                                          controller.invoiceController
                                              .existingItemType(
                                                  SelectedItemCategory
                                                      .existingOne);

                                          // Clear previous selection if needed
                                          controller.invoiceController
                                              .selectedItemList
                                              .clear();
                                          for (var c in controller
                                              .invoiceController
                                              .editAmountControllers) {
                                            c.dispose();
                                          }
                                          for (var c in controller
                                              .invoiceController
                                              .editDescriptionControllers) {
                                            c.dispose();
                                          }
                                          for (var c in controller
                                              .invoiceController
                                              .editQuantityControllers) {
                                            c.dispose();
                                          }
                                          controller.invoiceController
                                              .editAmountControllers
                                              .clear();
                                          controller.invoiceController
                                              .editDescriptionControllers
                                              .clear();
                                          controller.invoiceController
                                              .editQuantityControllers
                                              .clear();
                                          controller.invoiceController
                                              .editNoteTextController
                                              .clear();
                                          controller.invoiceController
                                              .editDiscountTextController
                                              .clear();
                                          controller.invoiceController
                                              .initialTaxID.value = "";

                                          // Set basic info

                                          controller
                                              .invoiceController
                                              .invoiceItemList
                                              .value = proposal.items ?? [];
                                          controller.invoiceController
                                                  .depositList.value =
                                              proposal.paymentList ?? [];
                                          controller
                                                  .invoiceController
                                                  .selectedDiscountOption
                                                  .value =
                                              proposal.discountOption ?? "2";
                                          controller.invoiceController
                                                  .invoiceNumber =
                                              proposal.number ?? "";
                                          controller.invoiceController
                                                  .isConverted.value =
                                              proposal.isConverted ?? false;
                                          controller.invoiceController
                                                  .customerName =
                                              proposal.fullName ?? "";
                                          controller.invoiceController.address =
                                              "${proposal.city}, ";
                                          controller
                                              .invoiceController
                                              .depositAmount
                                              .value = proposal.depositAmount
                                                  ?.toStringAsFixed(
                                                2,
                                              ) ??
                                              "0.00";
                                          controller.invoiceController.invoiceID
                                                  .value =
                                              proposal.invoiceID.toString();
                                          controller.invoiceController.date =
                                              dateTimeConverter(
                                            inputFormat: "yyyy/MM/dd",
                                            inputTime:
                                                proposal.invoiceDate.toString(),
                                            outputFormat: "MM/dd/yyyy",
                                          );
                                          controller.invoiceController
                                              .subtotal = proposal.subtotal
                                                  ?.toStringAsFixed(2) ??
                                              "";
                                          controller.invoiceController
                                                  .customerID.value =
                                              proposal.customerId ?? "";
                                          controller.invoiceController.status =
                                              proposal.status ?? "";
                                          controller.invoiceController.type
                                              .value = proposal.type ?? "";
                                          controller.invoiceController.total
                                              .value = proposal.total
                                                  ?.toStringAsFixed(2) ??
                                              "";
                                          if (proposal.requestedAmountType ==
                                              2) {
                                            // type = fixed
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOption
                                                .value = "2";
                                            controller
                                                .invoiceController
                                                .requestedDepositAmountEditTextController
                                                .text = proposal
                                                    .requestedDepositAmount ??
                                                "0.00";
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOptionName
                                                .value = controller
                                                    .invoiceController
                                                    .depositRequestOptions[2]
                                                ["name"];
                                          }
                                          if (proposal.requestedAmountType ==
                                              1) {
                                            // type = percentage
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOption
                                                .value = "1";
                                            controller
                                                .invoiceController
                                                .requestDepositRateEditTextController
                                                .text = proposal
                                                    .requestedDepositPercentage ??
                                                "0.00";
                                            controller
                                                .invoiceController
                                                .requestedDepositAmountEditTextController
                                                .text = proposal
                                                    .requestedDepositAmount ??
                                                "0.00";
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOptionName
                                                .value = controller
                                                    .invoiceController
                                                    .depositRequestOptions[1]
                                                ["name"];
                                          }
                                          if (proposal.requestedAmountType ==
                                              0) {
                                            // type = null
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOption
                                                .value = "0";
                                            controller
                                                .invoiceController
                                                .requestDepositRateEditTextController
                                                .text = proposal
                                                    .requestedDepositPercentage ??
                                                "0.00";
                                            controller
                                                .invoiceController
                                                .requestedDepositAmountEditTextController
                                                .text = proposal
                                                    .requestedDepositAmount ??
                                                "0.00";
                                            controller
                                                .invoiceController
                                                .selectedDepositRequestOptionName
                                                .value = controller
                                                    .invoiceController
                                                    .depositRequestOptions[0]
                                                ["name"];
                                          }
                                          controller.invoiceController.notes =
                                              proposal.note ?? "";
                                          controller
                                              .invoiceController
                                              .editNoteTextController
                                              .text = proposal.note ?? "";
                                          controller.invoiceController.due =
                                              proposal.due ?? "";
                                          controller
                                              .invoiceController
                                              .showingDate
                                              .value = dateTimeConverter(
                                            inputFormat: "yyyy/MM/dd hh:mm a",
                                            inputTime:
                                                proposal.invoiceDate.toString(),
                                            outputFormat: "MM/dd/yyyy",
                                          );
                                          if (proposal.taxType != "") {
                                            controller
                                                .invoiceController
                                                .initialTaxID
                                                .value = proposal.taxType ?? "";
                                          }

                                          // Set discount values
                                          controller
                                                  .invoiceController
                                                  .invoiceDiscountDetails
                                                  .value =
                                              proposal.discount ?? 0.00;
                                          if (proposal.discountOption == "1") {
                                            controller
                                                .invoiceController
                                                .editDiscountTextController
                                                .text = (((double.parse(
                                                          proposal.discount
                                                                  ?.toString() ??
                                                              "0.00",
                                                        )) *
                                                        100) /
                                                    double.parse(
                                                      proposal.subtotal
                                                              ?.toStringAsFixed(
                                                            2,
                                                          ) ??
                                                          "0.00",
                                                    ))
                                                .toStringAsFixed(2);
                                          } else {
                                            controller
                                                .invoiceController
                                                .editDiscountTextController
                                                .text = double.parse(
                                              proposal.discount?.toString() ??
                                                  "0.00",
                                            ).toStringAsFixed(2);
                                          }

                                          // Set tax values

                                          controller
                                                  .invoiceController.tax.value =
                                              controller.invoiceController.taxes
                                                      .firstWhereOrNull(
                                                        (tax) =>
                                                            tax.id ==
                                                            int.tryParse(
                                                              controller
                                                                  .invoiceController
                                                                  .initialTaxID
                                                                  .value,
                                                            ),
                                                      )
                                                      ?.rate
                                                      ?.toStringAsFixed(2) ??
                                                  "0.00";
                                          controller.invoiceController
                                                  .selectedTaxName.value =
                                              controller.invoiceController.taxes
                                                      .firstWhereOrNull(
                                                        (tax) =>
                                                            tax.id ==
                                                            int.tryParse(
                                                              controller
                                                                  .invoiceController
                                                                  .initialTaxID
                                                                  .value,
                                                            ),
                                                      )
                                                      ?.name ??
                                                  "";

                                          // Populate selectedItemList and initialize controllers
                                          if (proposal.items != null &&
                                              proposal.items!.isNotEmpty) {
                                            for (var item in proposal.items!) {
                                              controller.invoiceController
                                                  .selectedItemList
                                                  .add(
                                                ItemListModel(
                                                  id: item.itemId,
                                                  name: item.name,
                                                  description: item.description,
                                                  price: double.tryParse(
                                                    item.unitPrice ?? "0.00",
                                                  ),
                                                  isTaxable:
                                                      item.isTaxable == "TAX"
                                                          ? true
                                                          : false,
                                                  // itemTypeId: int.parse(item.itemTyId!),
                                                ),
                                              );

                                              // Initialize controllers with existing values
                                              controller.invoiceController
                                                  .editAmountControllers
                                                  .add(
                                                TextEditingController(
                                                  text:
                                                      item.unitPrice ?? "0.00",
                                                ),
                                              );

                                              controller.invoiceController
                                                  .editDescriptionControllers
                                                  .add(
                                                TextEditingController(
                                                  text: item.description ?? "",
                                                ),
                                              );

                                              controller.invoiceController
                                                  .editQuantityControllers
                                                  .add(
                                                TextEditingController(
                                                  text: item.quantity ?? "1",
                                                ),
                                              );
                                            }
                                          }
                                          controller.invoiceController
                                              .createTotalForEdit();
                                          await 0.5.delay();
                                          controller.invoiceController
                                              .selectedQboClass(
                                            controller
                                                .invoiceController.qboClassList
                                                .where(
                                                  (e) =>
                                                      e.qboClassId.toString() ==
                                                      proposal.qboClassId,
                                                )
                                                .firstOrNull,
                                          );
                                          controller.invoiceController
                                              .selectedQboLocation(
                                            controller.invoiceController
                                                .qboLocationList
                                                .where(
                                                  (e) =>
                                                      e.qboLocationId
                                                          .toString() ==
                                                      proposal.qboLocationId,
                                                )
                                                .firstOrNull,
                                          );
                                          controller
                                              .invoiceController.removedList
                                              .clear(); // Optional small delay before navigation
                                          controller.hideLoading();
                                          final x =
                                              MySharedPref.getCompanyType() ??
                                                  '';
                                          controller
                                              .invoiceController
                                              .isLocAndClassShow
                                              .value = x == 'PCS';
                                          controller.invoiceController
                                              .selectedInvoice.value = proposal;
                                          Get.toNamed(Routes.INVOICE_DETAILS);
                                        },
                                        child: Card(
                                          elevation: 0,
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                title: TextWidget(
                                                  text:
                                                      "${proposal.type ?? ""} Number",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.sp,
                                                    vertical: 2.sp,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      5.r,
                                                    ),
                                                    color: proposal.type ==
                                                            "Invoice"
                                                        ? theme.primaryColor
                                                        : proposal.type ==
                                                                    "Estimate" &&
                                                                proposal.isConverted ==
                                                                    true
                                                            ? Colors.green
                                                            : Colors.yellow,
                                                  ),
                                                  child: TextWidget(
                                                    text: proposal.number ?? "",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: proposal.type ==
                                                                  "Estimate" &&
                                                              proposal.isConverted ==
                                                                  false
                                                          ? Colors.black
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              MainDivider(),
                                              ListTile(
                                                title: TextWidget(
                                                  text: "Date",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: proposal
                                                            .invoiceDate !=
                                                        ""
                                                    ? TextWidget(
                                                        text: dateTimeConverter(
                                                          inputFormat:
                                                              "yyyy/MM/dd hh:mm a",
                                                          inputTime: proposal
                                                              .invoiceDate
                                                              .toString(),
                                                          outputFormat:
                                                              "MM/dd/yyyy",
                                                        ),
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      )
                                                    : TextWidget(text: ""),
                                              ),
                                              MainDivider(),
                                              ListTile(
                                                title: TextWidget(
                                                  text: "Required Amount",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: TextWidget(
                                                  text:
                                                      "\$${proposal.total?.toStringAsFixed(2) ?? ""}",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              MainDivider(),
                                              ListTile(
                                                title: TextWidget(
                                                  text: "Amount Received",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: TextWidget(
                                                  text:
                                                      "\$${proposal.depositAmount?.toStringAsFixed(2) ?? ""}",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            SizedBox(height: 8.sp),
                                    itemCount: controller
                                        .sortedAppointments[
                                            controller.selectedAptIndex.value]
                                        .invoices!
                                        .length,
                                    shrinkWrap: true,
                                    reverse: true,
                                    physics: NeverScrollableScrollPhysics(),
                                  ),
                                ),
                                SizedBox(height: 15.sp),
                              ],
                            ),
                          ),

                          //********************************* Tab Five Pictures *********************************/
                          Obx(
                            () => Column(
                              children: [
                                SizedBox(height: 15.sp),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: controller.mediaList.length == 1
                                        ? () {}
                                        : () {
                                            showMediaBottomSheet(context, -1);
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: DottedBorder(
                                        options: RectDottedBorderOptions(
                                          dashPattern: [3, 2],
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 25.sp,
                                          color:
                                              controller.mediaList.length == 1
                                                  ? Colors.grey
                                                  : theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.imageList.isEmpty &&
                                                controller.mediaList.isEmpty
                                            ? Center(
                                                child: TextWidget(
                                                  text: "Add Pictures",
                                                ),
                                              )
                                            : ListView.separated(
                                                itemBuilder: (context, index) {
                                                  final item = controller
                                                      .mediaList[index];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextWidget(
                                                        text: item.time,
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      // ✅ Description TextField
                                                      TextField(
                                                        controller: item
                                                            .descriptionController, // make sure each item has a controller
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Add description...",
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              8.r,
                                                            ),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            ...item.images.map((
                                                              e,
                                                            ) {
                                                              if (_isVideo(e)) {
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      showMediaDialog(
                                                                    context,
                                                                    e,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      right:
                                                                          8.0,
                                                                    ),
                                                                    child: FutureBuilder<
                                                                        String?>(
                                                                      future:
                                                                          generateVideoThumbnail(
                                                                        e,
                                                                      ),
                                                                      builder: (
                                                                        context,
                                                                        snapshot,
                                                                      ) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState.waiting) {
                                                                          return Container(
                                                                            height:
                                                                                150,
                                                                            width:
                                                                                150,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                const CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                        if (snapshot.hasData &&
                                                                            snapshot.data !=
                                                                                null) {
                                                                          return Stack(
                                                                            children: [
                                                                              Container(
                                                                                height: 150,
                                                                                width: 150,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10.r,
                                                                                  ),
                                                                                  image: DecorationImage(
                                                                                    fit: BoxFit.fill,
                                                                                    image: FileImage(
                                                                                      File(
                                                                                        snapshot.data!,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const Positioned.fill(
                                                                                child: Center(
                                                                                  child: Icon(
                                                                                    Icons.play_circle_fill,
                                                                                    size: 40,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }
                                                                        return Container(
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              150,
                                                                          color:
                                                                              Colors.grey[300],
                                                                          child:
                                                                              const Icon(
                                                                            Icons.play_circle_fill,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      showMediaDialog(
                                                                    context,
                                                                    e,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 150,
                                                                    width: 150,
                                                                    margin:
                                                                        EdgeInsets
                                                                            .only(
                                                                      right: 20,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        10.r,
                                                                      ),
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            FileImage(
                                                                          File(
                                                                            e,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  showMediaBottomSheet(
                                                                context,
                                                                index,
                                                              ),
                                                              child: Container(
                                                                height: 150,
                                                                width: 150,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  right: 8,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    10.r,
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons.add,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            await controller
                                                                .uploadImages(
                                                              tagName: item.time
                                                                  .split(
                                                                " ",
                                                              )[0],
                                                              description: item
                                                                  .descriptionController
                                                                  .text,
                                                            ); // pass description
                                                          },
                                                          child: const Text(
                                                            "Save",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder: (
                                                  BuildContext context,
                                                  int index,
                                                ) =>
                                                    SizedBox(height: 8.sp),
                                                itemCount:
                                                    controller.mediaList.length,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                              ),

                                        SizedBox(height: 20.h),
                                        // Display images grouped by upload date
                                        Obx(() {
                                          final groupedImages =
                                              controller.imagesGroupedByDate;
                                          final sortedDates = groupedImages.keys
                                              .toList()
                                            ..sort();

                                          if (sortedDates.isEmpty) {
                                            return Center(
                                              child: TextWidget(
                                                text: "No pictures yet",
                                              ),
                                            );
                                          }

                                          return ListView.separated(
                                            itemBuilder: (context, index) {
                                              final date = sortedDates[index];
                                              final images =
                                                  groupedImages[date]!;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Date header
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 8.h,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 16.sp,
                                                        ),
                                                        SizedBox(width: 8),
                                                        TextWidget(
                                                          text: date,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16.sp,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8.sp,
                                                            vertical: 4.h,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: theme
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              12.r,
                                                            ),
                                                          ),
                                                          child: TextWidget(
                                                            text:
                                                                "${images.length} ${images.length == 1 ? 'image' : 'images'}",
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: theme
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  SizedBox(height: 10.h),

                                                  // Horizontal scrollable images
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                    ),
                                                    child: Row(
                                                      children: images
                                                          .map((item) =>
                                                              GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        Dialog(
                                                                      child: Image
                                                                          .memory(
                                                                        item.bytes!,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        gaplessPlayback:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 150,
                                                                  width: 150,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .only(
                                                                    right:
                                                                        12.sp,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      10.r,
                                                                    ),
                                                                    image:
                                                                        DecorationImage(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image:
                                                                          MemoryImage(
                                                                        item.bytes!,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ))
                                                          .toList(),
                                                    ),
                                                  ),

                                                  SizedBox(height: 10.h),
                                                  Divider(
                                                    height: 10,
                                                    thickness: 1,
                                                    color: Colors
                                                        .blueGrey.shade200,
                                                  ),
                                                ],
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 8.sp),
                                            itemCount: sortedDates.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                          );
                                        }),
                                        SizedBox(height: 15.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //********************************* Tab Six Files *********************************/
                          Obx(
                            () => Column(
                              children: [
                                SizedBox(height: 15.sp),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: controller.mediaList.length == 1
                                        ? () {}
                                        : () {
                                            showMediaBottomSheet(context, -1);
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: DottedBorder(
                                        options: RectDottedBorderOptions(
                                          dashPattern: [3, 2],
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 25.sp,
                                          color:
                                              controller.mediaList.length == 1
                                                  ? Colors.grey
                                                  : theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.imageList.isEmpty &&
                                                controller.mediaList.isEmpty
                                            ? Center(
                                                child: TextWidget(
                                                  text: "Add Files",
                                                ),
                                              )
                                            : ListView.separated(
                                                itemBuilder: (context, index) {
                                                  final item = controller
                                                      .mediaList[index];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextWidget(
                                                        text: item.time,
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      // ✅ Description TextField
                                                      TextField(
                                                        controller: item
                                                            .descriptionController, // make sure each item has a controller
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Add description...",
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              8.r,
                                                            ),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            ...item.images.map((
                                                              e,
                                                            ) {
                                                              if (_isVideo(e)) {
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      showMediaDialog(
                                                                    context,
                                                                    e,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      right:
                                                                          8.0,
                                                                    ),
                                                                    child: FutureBuilder<
                                                                        String?>(
                                                                      future:
                                                                          generateVideoThumbnail(
                                                                        e,
                                                                      ),
                                                                      builder: (
                                                                        context,
                                                                        snapshot,
                                                                      ) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState.waiting) {
                                                                          return Container(
                                                                            height:
                                                                                150,
                                                                            width:
                                                                                150,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                const CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                        if (snapshot.hasData &&
                                                                            snapshot.data !=
                                                                                null) {
                                                                          return Stack(
                                                                            children: [
                                                                              Container(
                                                                                height: 150,
                                                                                width: 150,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10.r,
                                                                                  ),
                                                                                  image: DecorationImage(
                                                                                    fit: BoxFit.fill,
                                                                                    image: FileImage(
                                                                                      File(
                                                                                        snapshot.data!,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const Positioned.fill(
                                                                                child: Center(
                                                                                  child: Icon(
                                                                                    Icons.play_circle_fill,
                                                                                    size: 40,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }
                                                                        return Container(
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              150,
                                                                          color:
                                                                              Colors.grey[300],
                                                                          child:
                                                                              const Icon(
                                                                            Icons.play_circle_fill,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      showMediaDialog(
                                                                    context,
                                                                    e,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 150,
                                                                    width: 150,
                                                                    margin:
                                                                        EdgeInsets
                                                                            .only(
                                                                      right: 20,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        10.r,
                                                                      ),
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            FileImage(
                                                                          File(
                                                                            e,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  showMediaBottomSheet(
                                                                context,
                                                                index,
                                                              ),
                                                              child: Container(
                                                                height: 150,
                                                                width: 150,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  right: 8,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    10.r,
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons.add,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),

                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            await controller
                                                                .uploadImages(
                                                              tagName: item.time
                                                                  .split(
                                                                " ",
                                                              )[0],
                                                              description: item
                                                                  .descriptionController
                                                                  .text,
                                                            ); // pass description
                                                          },
                                                          child: const Text(
                                                            "Save",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder: (
                                                  BuildContext context,
                                                  int index,
                                                ) =>
                                                    SizedBox(height: 8.sp),
                                                itemCount:
                                                    controller.mediaList.length,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                              ),

                                        SizedBox(height: 20.h),
                                        // Display images grouped by upload date
                                        Obx(() {
                                          final groupedImages =
                                              controller.imagesGroupedByDate;
                                          final sortedDates = groupedImages.keys
                                              .toList()
                                            ..sort();

                                          if (sortedDates.isEmpty) {
                                            return Center(
                                              child: TextWidget(
                                                text: "No files yet",
                                              ),
                                            );
                                          }

                                          return ListView.separated(
                                            itemBuilder: (context, index) {
                                              final date = sortedDates[index];
                                              final images =
                                                  groupedImages[date]!;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Date header
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 8.h,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 16.sp,
                                                        ),
                                                        SizedBox(width: 8),
                                                        TextWidget(
                                                          text: date,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16.sp,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8.sp,
                                                            vertical: 4.h,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: theme
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              12.r,
                                                            ),
                                                          ),
                                                          child: TextWidget(
                                                            text:
                                                                "${images.length} ${images.length == 1 ? 'image' : 'images'}",
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: theme
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  SizedBox(height: 10.h),

                                                  // Horizontal scrollable images
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                    ),
                                                    child: Row(
                                                      children: images
                                                          .map((item) =>
                                                              GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        Dialog(
                                                                      child: Image
                                                                          .memory(
                                                                        item.bytes!,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        gaplessPlayback:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 150,
                                                                  width: 150,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .only(
                                                                    right:
                                                                        12.sp,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      10.r,
                                                                    ),
                                                                    image:
                                                                        DecorationImage(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image:
                                                                          MemoryImage(
                                                                        item.bytes!,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ))
                                                          .toList(),
                                                    ),
                                                  ),

                                                  SizedBox(height: 10.h),
                                                  Divider(
                                                    height: 10,
                                                    thickness: 1,
                                                    color: Colors
                                                        .blueGrey.shade200,
                                                  ),
                                                ],
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 8.sp),
                                            itemCount: sortedDates.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                          );
                                        }),
                                        SizedBox(height: 15.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //********************************* Tab Seven Notes *********************************/
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.sp,
                              horizontal: 12.sp,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dropdown for selection
                                  InkWell(
                                    onTap: () async {
                                      DialogHelper.showLoading();

                                      await controller.getTagList();

                                      DialogHelper.hideLoading();
                                      controller.selectedTagId(-1);
                                      controller.note1Controller.clear();
                                      controller.selectedTagController.value
                                          .clear();
                                      controller.noteId(-1);
                                      showNotesDialog(
                                        context,
                                        controller,
                                        theme,
                                        false,
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: DottedBorder(
                                        options: RectDottedBorderOptions(
                                          dashPattern: [3, 2],
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 25.sp,
                                          color:
                                              controller.mediaList.length == 1
                                                  ? Colors.grey
                                                  : theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),

                                  // Notes list
                                  Obx(
                                    () => controller.noteList
                                            .where((e) {
                                              //     log("selected apptId ${controller.selectedAppointment.value!.apptID} and note appt id ${e.appointmentId}");
                                              return e.appointmentId ==
                                                  controller.selectedAppointment
                                                      .value!.apptID;
                                            })
                                            .toList()
                                            .isEmpty
                                        ? Center(
                                            child: TextWidget(
                                              text: "No Notes Found",
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: controller.noteList
                                                .where(
                                                  (e) =>
                                                      e.appointmentId ==
                                                      controller
                                                          .selectedAppointment
                                                          .value!
                                                          .apptID,
                                                )
                                                .toList()
                                                .length,
                                            itemBuilder: (context, index) {
                                              final note = controller.noteList
                                                  .where(
                                                    (e) =>
                                                        e.appointmentId ==
                                                        controller
                                                            .selectedAppointment
                                                            .value!
                                                            .apptID,
                                                  )
                                                  .toList()[index];

                                              return GestureDetector(
                                                onTap: note.userId!.trim() ==
                                                        controller.userId
                                                            .toString()
                                                            .trim()
                                                    ? () {
                                                        controller
                                                            .selectedTagId(
                                                          note.tagId,
                                                        );
                                                        controller
                                                                .note1Controller
                                                                .text =
                                                            note.description!;
                                                        controller
                                                                .selectedTagController
                                                                .value
                                                                .text =
                                                            controller
                                                                .allTagList
                                                                .where(
                                                                  (e) =>
                                                                      e.id ==
                                                                      note.tagId,
                                                                )
                                                                .first
                                                                .name;
                                                        controller.noteId(
                                                          note.id,
                                                        );
                                                        showNotesDialog(
                                                          context,
                                                          controller,
                                                          theme,
                                                          true,
                                                        );
                                                      }
                                                    : () {
                                                        showNoteDetailsDialog(
                                                          context,
                                                          note,
                                                          theme,
                                                          controller.allTagList
                                                              .where(
                                                                (e) =>
                                                                    e.id ==
                                                                    note.tagId,
                                                              )
                                                              .first
                                                              .name,
                                                        );
                                                      },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 4.h,
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                      12.sp,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: note.userId!
                                                                  .trim() ==
                                                              controller.userId
                                                                  .toString()
                                                                  .trim()
                                                          ? Colors.green[50]
                                                          : Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.sp,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Row with User Name on Left, Date-Time on Right
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.person,
                                                                  size: 14.sp,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                                SizedBox(
                                                                  width: 6.w,
                                                                ),
                                                                Text(
                                                                  note.userName ??
                                                                      "N/A",
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              DateFormat(
                                                                "dd MMM yyyy",
                                                              ).format(
                                                                DateTime.parse(
                                                                  note.createdAt!,
                                                                ),
                                                              ),
                                                              style: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8.h),

                                                        // Tag as a chip
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 4.h,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue
                                                                .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              12.sp,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            controller
                                                                    .allTagList
                                                                    .where(
                                                                      (e) =>
                                                                          e.id ==
                                                                          note.tagId,
                                                                    )
                                                                    .isNotEmpty
                                                                ? controller
                                                                    .allTagList
                                                                    .where(
                                                                      (e) =>
                                                                          e.id ==
                                                                          note.tagId,
                                                                    )
                                                                    .first
                                                                    .name
                                                                : "N/A",
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.h),

                                                        // Note Content
                                                        TextWidget(
                                                          text:
                                                              note.description! ??
                                                                  "N/A",
                                                          style: theme.textTheme
                                                              .bodyMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //       vertical: 8.sp, horizontal: 12.sp),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       //   TextWidget(text:
                          //       //   "Office Notes:",
                          //       //   style: theme.textTheme.bodyMedium?.copyWith(
                          //       //     fontWeight: FontWeight.bold,
                          //       //   ),
                          //       // ),
                          //       //   TextWidget(text: "Do not forget to bring the required tools."),
                          //       // SizedBox(height: 10.h),

                          //       // // --- 2. History Notes ---

                          //       // Column(
                          //       //   crossAxisAlignment: CrossAxisAlignment.start,
                          //       //   children: [
                          //       //       TextWidget(text:
                          //       //       "Previous Notes:",
                          //       //       style: theme.textTheme.bodyMedium?.copyWith(
                          //       //         fontWeight: FontWeight.bold,
                          //       //       ),
                          //       //     ),
                          //       //     ...controller.historyNotes.map(
                          //       //       (note) => Padding(
                          //       //         padding: EdgeInsets.symmetric(vertical: 4.h),
                          //       //         child:   TextWidget(text:
                          //       //           "${"07/09/2025"} • $note",
                          //       //           style: theme.textTheme.bodySmall,
                          //       //         ),
                          //       //       ),
                          //       //     ),
                          //       //     SizedBox(height: 10.h),
                          //       //   ],
                          //       // ),
                          //       TextWidget(
                          //         text: "Notes",
                          //         style: theme.textTheme.bodyLarge?.copyWith(
                          //           color: LightThemeColors.hintTextColor,
                          //           fontSize: 10.sp,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //         textAlign: TextAlign.start,
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: GeneralTextField(
                          //           maxLine: 4,
                          //           hint: "Add a note here..",
                          //           theme: theme,
                          //           textEditingController:
                          //               controller.noteController,
                          //           onChanged: (v) {
                          //             controller.isTyping(true);
                          //             controller.noteText(v);
                          //           },
                          //           onEditingComplete: () {
                          //             controller.isTyping(false);
                          //           },
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         height: 20.h,
                          //       ),
                          //       SizedBox(
                          //         width: double.infinity,
                          //         height: 48.sp,
                          //         child: PrimaryButton(
                          //             title: "Update",
                          //             onPressed: () async {
                          //               await controller.updateAppointment();
                          //             },
                          //             inactive: false),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Save all custom fields to the server
  Future<void> _saveCustomFields() async {
    try {
      // Get the appointment ID
      final appointmentId = controller.selectedAppointment.value?.apptID;
      if (appointmentId == null) {
        MySnackBar.showErrorToast(
          message: "Appointment ID not found",
        );
        return;
      }

      // Collect all custom field values as array of objects
      // Format: [{"type": "FieldName", "value1": "...", "value2": "..."}]
      final List<Map<String, dynamic>> fieldsArray = [];
      for (var field in customFieldsController.selectedCustomFields) {
        final value = field.getFieldValue();
        if (value != null && value.isNotEmpty) {
          fieldsArray.add({
            "type": field.fieldName,
            "value1": value,
            "value2": "", // Can be used for additional values if needed
          });
        }
      }

      // Check if there are any fields to save
      if (fieldsArray.isEmpty) {
        MySnackBar.showInfoToast(
          message: "Please fill in at least one custom field",
        );
        return;
      }

      // Convert to JSON string
      final fieldsValue = jsonEncode(fieldsArray);

      log("📤 Saving custom fields for appointment: $appointmentId");
      log("📤 Fields: $fieldsValue");

      // Call the API
      await customFieldsController.saveCustomFieldToServer(
        appointmentId: appointmentId,
        fieldsValue: fieldsValue,
      );

      // Success is handled by the controller (shows toast)
    } catch (e) {
      log("❌ Error saving custom fields: $e");
      MySnackBar.showErrorToast(
        message: "Failed to save custom fields",
      );
    }
  }
}

void showMediaDialog(BuildContext context, String path) {
  if (_isVideo(path)) {
    showDialog(
      context: context,
      builder: (_) => _VideoDialog(videoPath: path),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _VideoDialog extends StatefulWidget {
  final String videoPath;
  const _VideoDialog({required this.videoPath});

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            )
          : SizedBox(
              height: 150,
              width: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

Future<String?> generateVideoThumbnail(String videoPath) async {
  final tempDir = await getTemporaryDirectory();
  return await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: tempDir.path,
    imageFormat: ImageFormat.PNG,
    maxWidth: 150, // thumbnail width
    quality: 75,
  );
}

void showNotesDialog(
  BuildContext context,
  AppointmentController controller,
  ThemeData theme,
  bool isOld,
) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextWidget(
                    text: "Add / Update Notes",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // notes tag..
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () async {
                        controller.getTagList();
                        controller.selectedTagController.value.clear();
                        controller.selectedTagId(-1);
                        Get.toNamed(Routes.TAG_DETAILS);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: controller.selectedTagController.value,
                          decoration: InputDecoration(
                            labelText: 'Select Tag',
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Notes input
                  TextWidget(
                    text: "Notes",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: LightThemeColors.hintTextColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GeneralTextField(
                      maxLine: 4,
                      minLine: 1,
                      textInputType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      hint: "Add a note here..",
                      theme: theme,
                      isEnabled: true,
                      textEditingController: controller.note1Controller,
                      onChanged: (v) {
                        controller.isTyping(true);
                        controller.noteText(v);
                      },
                      onEditingComplete: () {
                        controller.isTyping(false);
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cancel
                      Expanded(
                        child: SizedBox(
                          height: 48.sp,
                          child: PrimaryButton(
                            backgroundColor: Colors.redAccent,
                            title: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            inactive: false,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Update
                      Expanded(
                        child: SizedBox(
                          height: 48.sp,
                          child: PrimaryButton(
                            backgroundColor:
                                controller.selectedTagId.value != -1
                                    ? LightThemeColors.primaryColor
                                    : LightThemeColors.buttonDisabledColor,
                            title: isOld ? "Update" : "Save",
                            onPressed: () async {
                              await controller.saveNote(isOld);
                              // Navigator.pop(context);
                            },
                            inactive: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> openMapWithRoute(String destinationAddress) async {
  try {
    // ✅ Get current location
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    final origin =
        '${position.latitude},${position.longitude}'; // current location coordinates
    final encodedDestination = Uri.encodeComponent(destinationAddress);
    log("message origin $origin");
    if (Platform.isIOS) {
      // Google Maps (if installed)
      final googleMapsUrl = Uri.parse(
        'comgooglemaps://?saddr=$origin&daddr=$encodedDestination&directionsmode=driving',
      );
      // Apple Maps fallback
      final appleMapsUrl = Uri.parse(
        'https://maps.apple.com/?saddr=$origin&daddr=$encodedDestination',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        throw 'Could not launch maps on iOS';
      }
    } else {
      // ✅ Android or others – open Google Maps web with current location
      final googleMapsWebUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$encodedDestination&travelmode=driving',
      );

      if (await canLaunchUrl(googleMapsWebUrl)) {
        await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps';
      }
    }
  } catch (e) {
    print('Error launching map: $e');
  }
}

bool _isVideo(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
}

void showDialogTicketStatus(
  BuildContext context,
  AppointmentController controller,
) {
  final tickets = controller.settingController.tickets;

  showDialog(
    barrierDismissible: true,
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16.w),
      backgroundColor: Colors.transparent,
      child: Material(
        borderRadius: BorderRadius.circular(12.r),

        color: Colors.white.withValues(
          alpha: 0.05,
        ), // Make sure background is NOT fully transparent
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensures touch detection
                  onTap: () {
                    Navigator.of(context).pop(); // or Get.back();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ..._buildTicketRows(tickets, controller, context),
            ],
          ),
        ),
      ),
    ),
  );
}

void showMediaBottomSheet(BuildContext context, int index) {
  final appointmentC = Get.find<AppointmentController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 100.h,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              // ============================================
              // TAG SYSTEM REMOVED (not needed right now)
              // ============================================
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: GestureDetector(
              //     onTap: () async {
              //       appointmentC.getTagList();
              //       Get.toNamed(Routes.TAG_DETAILS);
              //     },
              //     child: AbsorbPointer(
              //       child: TextFormField(
              //         controller: appointmentC.selectedTagController.value,
              //         decoration: InputDecoration(
              //           labelText: 'Select Tag',
              //           suffixIcon: const Icon(Icons.arrow_drop_down),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // ============================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MediaButton(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () async {
                      try {
                        // Tag validation removed
                        final List<XFile?> files =
                            await ImagePicker().pickMultiImage();
                        if (files.isNotEmpty) {
                          // Compress images before adding
                          final newImages = <String>[];
                          for (var file in files) {
                            if (file != null) {
                              try {
                                final compressedPath = await compressImage(
                                  file.path,
                                );
                                newImages.add(compressedPath);
                              } catch (e) {
                                // Skip image if compression fails
                              }
                            }
                          }

                          if (newImages.isNotEmpty) {
                            if (index != -1) {
                              appointmentC.mediaList[index].images.addAll(
                                newImages,
                              );
                            } else {
                              appointmentC.mediaList.add(
                                MediaModel(
                                  time: DateFormat("MM/dd/yyyy")
                                      .format(DateTime.now()),
                                  images: newImages,
                                ),
                              );
                            }
                          }
                        }

                        appointmentC.update();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error picking images: Unable to access gallery. Please check permissions.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }

                      Navigator.pop(context);
                    },
                  ),
                  _MediaButton(
                    icon: Icons.camera_alt,
                    title: 'Photo',
                    onTap: () async {
                      // Tag validation removed
                      final XFile? file = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (file != null) {
                        // Compress the image first
                        final compressedPath = await compressImage(file.path);

                        if (index != -1) {
                          appointmentC.mediaList[index].images.add(
                            compressedPath,
                          );
                          appointmentC.mediaList.refresh();
                        } else {
                          appointmentC.mediaList.add(
                            MediaModel(
                              time: DateFormat("MM/dd/yyyy")
                                  .format(DateTime.now()),
                              images: [compressedPath],
                            ),
                          );
                        }
                      }

                      appointmentC.update();

                      Navigator.pop(context);
                    },
                  ),
                  // _MediaButton(
                  //   icon: Icons.videocam,
                  //   title: 'Video',
                  //   onTap: () async {
                  //     if (tagController.text.trim().isEmpty && index == -1) {
                  //       ScaffoldMessenger.of(context).showMaterialBanner(
                  //         MaterialBanner(
                  //           content: const Text('Please add a tag first!'),
                  //           backgroundColor: Colors.red,
                  //           actions: [
                  //             TextButton(
                  //               onPressed: () {
                  //                 ScaffoldMessenger.of(context)
                  //                     .hideCurrentMaterialBanner();
                  //               },
                  //               child: const Text('OK',
                  //                   style: TextStyle(color: Colors.white)),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //       Future.delayed(const Duration(seconds: 2), () {
                  //         ScaffoldMessenger.of(context)
                  //             .hideCurrentMaterialBanner();
                  //       });
                  //       return;
                  //     }

                  //     final XFile? file = await ImagePicker()
                  //         .pickVideo(source: ImageSource.camera);
                  //     if (file != null) {
                  //       if (index != -1) {
                  //         appointmentC.mediaList[index].images.add(file.path);
                  //       } else {
                  //         appointmentC.mediaList.add(MediaModel(
                  //           time:
                  //               "${tagController.text} (${DateFormat("dd MMM yyyy").format(DateTime.now())})",
                  //           images: [file.path],
                  //         ));
                  //       }
                  //       appointmentC.update();
                  //     }
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

Color _getTicketColor(String? name) {
  final status = name?.toLowerCase() ?? "";
  if (status == "installation in progress") {
    return const Color(0xffE98862);
  } else if (status == "on hold") {
    return const Color.fromARGB(255, 243, 18, 18);
  } else if (status == "parts on order") {
    return const Color.fromARGB(255, 21, 234, 242);
  } else if (status == "completed") {
    return const Color(0xff0CBC8B);
  }
  return Colors.red;
}

List<Widget> _buildTicketRows(
  List<dynamic> tickets,
  AppointmentController controller,
  BuildContext context,
) {
  List<Widget> rows = [];

  for (int i = 0; i < tickets.length; i += 3) {
    final chunk = tickets.skip(i).take(3).toList();

    rows.add(
      Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: chunk.map((status) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () async {
                    controller.settingController.selectedTicket(status);
                    controller.selectedTicketStatusValue(status.statusId!);
                    await controller.updateAppointment();
                    Get.back();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        shape: const CircleBorder(),
                        color: LightThemeColors.yellowColor.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: _getTicketColor(status.statusName),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 80.w,
                        child: TextWidget(
                          text: status.statusName ?? "",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  return rows;
}

void showDialogScheduled(
  BuildContext context,
  AppointmentController controller,
) {
  showDialog(
    barrierDismissible: true,
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16.sp),
      backgroundColor: Colors.transparent,
      child: Material(
        // <-- Ensures proper hit detection
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white.withValues(alpha: 0.05), // Slight opacity
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // or Get.back()
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 32.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              buildStatusGrid(
                context,
                controller.settingController,
                controller,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildStatusGrid(
  BuildContext context,
  SettingsController controller,
  AppointmentController appointmentController,
) {
  final rows = <Widget>[];

  for (int i = 0; i < controller.appointmentsStatus.length; i += 3) {
    final rowItems = controller.appointmentsStatus.skip(i).take(3).toList();

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: rowItems.map((status) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.0.sp),
              child: GestureDetector(
                onTap: () async {
                  controller.selectedAppointmentsStatus(status);
                  appointmentController.selectedStatusValue(status.statusId!);
                  await appointmentController.updateAppointment();
                  Get.back();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      shape: CircleBorder(),
                      color: LightThemeColors.yellowColor.withValues(
                        alpha: 0.5,
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: EdgeInsets.all(6.sp),
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: getStatusColor(status.statusName!),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: 80.w,
                      child: TextWidget(
                        text: status.statusName ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  return Column(children: rows);
}

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
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 0.9.sh, maxWidth: 0.9.sw),
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
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
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
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
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
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
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
                    enabled: false,
                    readOnly: true,
                    maxLines: 3, // Makes it non-interactive
                    controller: descriptionC,
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
                        value: data.requireSignature,
                        onChanged: (v) {},
                        title: Text(
                          "Require Signature",
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CheckboxListTile(
                        value: data.requireTip,
                        onChanged: (v) {},
                        title: Text(
                          "Enable Tip Capture",
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CheckboxListTile(
                        value: data.isAutoAssignEnabled,
                        onChanged: (v) {},
                        title: Text(
                          "Auto-assign to appointment types",
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CheckboxListTile(
                        value: data.isActive,
                        onChanged: (v) {},
                        title: Text(
                          "Active",
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text("Close", style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildHeaderCell(String title) {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.all(8.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ),
  );
}

Widget _buildRow(
  String field,
  String value, {
  Color? valueColor,
  IconData? icon,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Section
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: Colors.blue),
          ),
          SizedBox(width: 12.w),
        ],

        // Text Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isNotEmpty ? value : "-",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Color getStatusColor(String statusName) {
  switch (statusName) {
    // 🔸 Existing ones (unchanged)
    case "Installation In Progress":
    case "Installation in Progress":
      return const Color(0xffE98862);
    case "Scheduled":
      return const Color(0xff2E888B);
    case "Cancelled":
      return Colors.red;
    case "Completed":
      return const Color(0xff0CBC8B);

    // 🔹 New ones (added)
    case "Pending":
      return const Color(0xFFFFC107); // Amber
    case "Closed":
      return const Color(0xFF607D8B); // Blue Grey
    case "Dispatched":
      return const Color(0xFF42A5F5); // Light Blue
    case "FA-ID Sent":
      return const Color(0xFF9575CD); // Purple
    case "In-Route":
      return const Color(0xFFFF9800); // Orange
    case "Arrived":
      return const Color(0xFF8BC34A); // Light Green
    case "On-Hold":
      return const Color(0xFFFF7043); // Deep Orange

    // 🔸 Default (fallback)
    default:
      return const Color(0xFF9E9E9E); // Grey
  }
}

Future<String> compressImage(String filePath) async {
  final compressedFile = await FlutterImageCompress.compressWithFile(
    filePath,
    quality: 40, // Adjust quality (0-100), lower = smaller size
    minWidth: 800, // Adjust minimum width
    minHeight: 800, // Adjust minimum height
    format: CompressFormat.jpeg, // Use JPEG to reduce size
  );

  if (compressedFile == null) return filePath;

  // Save compressed image to a temp file
  final tempDir = Directory.systemTemp;
  final tempFile = await File(
    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
  ).writeAsBytes(compressedFile);

  return tempFile.path;
}

// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:xinator_fsm_pro/app/components/global-widgets/general_text_field.dart';
// import 'package:xinator_fsm_pro/app/components/global-widgets/my_buttons.dart';

// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../../utils/date_converter.dart';
// import '../../../../utils/url_launcher.dart';
// import '../../../components/global-widgets/main_divider.dart';
// import '../../../components/global-widgets/splash_container.dart';
// import '../../../routes/app_pages.dart';
// import '../../item/models/item_list_model.dart';
// import '../controllers/appointment_controller.dart';

// class AppointmentDetailsView extends GetView<AppointmentController> {
//   const AppointmentDetailsView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title:   TextWidget(text: "Appointment Details"),
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Card(
//                       elevation: 0,
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () {
//                                       showDialog(
//                                         barrierDismissible: true,
//                                         context: context,
//                                         barrierColor:
//                                             Colors.black.withValues(alpha: 0.6),
//                                         builder: (context) => Dialog(
//                                           backgroundColor: Colors.transparent,
//                                           child: Center(
//                                             child: GridView.builder(
//                                               shrinkWrap: true,
//                                               itemCount: controller
//                                                   .settingController
//                                                   .appointmentsStatus
//                                                   .length,
//                                               gridDelegate:
//                                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                                 childAspectRatio: .8,
//                                                 crossAxisCount: 3,
//                                                 crossAxisSpacing: 8,
//                                                 mainAxisSpacing: 8,
//                                               ),
//                                               itemBuilder: (context, index) {
//                                                 final status = controller
//                                                     .settingController
//                                                     .appointmentsStatus[index];
//                                                 return GestureDetector(
//                                                   onTap: () {
//                                                     controller.settingController
//                                                         .selectedAppointmentsStatus(
//                                                             status);
//                                                     Navigator.pop(context);
//                                                   },
//                                                   child: Column(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       CircleAvatar(
//                                                         radius: 30,
//                                                         backgroundColor: Colors
//                                                             .green.shade100,
//                                                         child: Icon(
//                                                           status.statusName ==
//                                                                   "Pending"
//                                                               ? Icons
//                                                                   .pending_actions
//                                                               : status.statusName ==
//                                                                       "Scheduled"
//                                                                   ? Icons.event
//                                                                   : status.statusName ==
//                                                                           "Cancelled"
//                                                                       ? Icons
//                                                                           .cancel
//                                                                       : status.statusName ==
//                                                                               "Closed"
//                                                                           ? Icons
//                                                                               .close
//                                                                           : status.statusName == "Installation In Progress"
//                                                                               ? Icons.play_arrow
//                                                                               : Icons.check_circle,
//                                                           size: 28,
//                                                           color: Colors
//                                                               .green.shade700,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 6),
//                                                       SizedBox(
//                                                         width: 80,
//                                                         child:   TextWidget(text:
//                                                           status.statusName ??
//                                                               "",
//                                                           maxLines: 2,
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style:
//                                                               const TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 13),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Obx(
//                                       () => Column(
//                                         children: [
//                                           Material(
//                                             shape: const CircleBorder(),
//                                             color:
//                                                 LightThemeColors.primaryColor,
//                                             elevation: 10,
//                                             child: Padding(
//                                               padding: EdgeInsets.all(20),
//                                               child: Icon(
//                                                   controller
//                                                               .settingController
//                                                               .selectedAppointmentsStatus
//                                                               .value
//                                                               ?.statusName ==
//                                                           "Pending"
//                                                       ? Icons.pending_actions
//                                                       : controller
//                                                                   .settingController
//                                                                   .selectedAppointmentsStatus
//                                                                   .value
//                                                                   ?.statusName ==
//                                                               "Scheduled"
//                                                           ? Icons.event
//                                                           : controller
//                                                                       .settingController
//                                                                       .selectedAppointmentsStatus
//                                                                       .value
//                                                                       ?.statusName ==
//                                                                   "Cancelled"
//                                                               ? Icons.cancel
//                                                               : controller
//                                                                           .settingController
//                                                                           .selectedAppointmentsStatus
//                                                                           .value
//                                                                           ?.statusName ==
//                                                                       "Closed"
//                                                                   ? Icons.close
//                                                                   : controller
//                                                                               .settingController
//                                                                               .selectedAppointmentsStatus
//                                                                               .value
//                                                                               ?.statusName ==
//                                                                           "Installation In Progress"
//                                                                       ? Icons
//                                                                           .play_arrow
//                                                                       : Icons
//                                                                           .check_circle,
//                                                   color: Colors.white,
//                                                   size: 28.sp),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 10.h,
//                                           ),
//                                             TextWidget(text:
//                                             controller
//                                                     .settingController
//                                                     .selectedAppointmentsStatus
//                                                     .value
//                                                     ?.statusName ??
//                                                 "",
//                                             maxLines: 2,
//                                             textAlign: TextAlign.center,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                                 fontSize: 13),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                     child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                       TextWidget(text:
//                                       controller.contactName,
//                                       style:
//                                           theme.textTheme.bodyLarge?.copyWith(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.bold,
//                                         color: theme.primaryColor,
//                                       ),
//                                     )
//                                   ],
//                                 ))
//                               ],
//                             ),
//                             ListTile(
//                               onTap: () async {
//                                 controller.showLoading();
//                                 await controller.customerController
//                                     .getCustomers();
//                                 controller.customerController.businessName =
//                                     controller.contactName;
//                                 controller.customerController.title =
//                                     controller.customerTitle;
//                                 controller.customerController.address =
//                                     controller.address;
//                                 controller.customerController.phoneNumber =
//                                     controller.phoneNumber;
//                                 controller.customerController.mobileNumber =
//                                     controller.mobileNumber;
//                                 controller.customerController.email =
//                                     controller.email;

//                                 controller.hideLoading();

//                                 Get.toNamed(Routes.CUSTOMER_DETAILS);
//                               },
//                               title:   TextWidget(text:
//                                 "Contact Name",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.contactName,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: theme.primaryColor,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Address",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing: SizedBox(
//                                 width: 200.sp,
//                                 child:   TextWidget(text:
//                                   controller.address,
//                                   style: theme.textTheme.bodyLarge?.copyWith(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   textAlign: TextAlign.end,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Request Date",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.requestDate,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Start Date",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.startDate,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "End Date",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.endDate,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Time Slot",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.timeSlot,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Service Type",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.serviceType,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Mobile",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing: InkWell(
//                                 onTap: () async {
//                                   await UrlLauncher.phoneCall(
//                                       controller.mobileNumber);
//                                 },
//                                 child:   TextWidget(text:
//                                   controller.mobileNumber,
//                                   style: theme.textTheme.bodyLarge?.copyWith(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Phone",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing: InkWell(
//                                 onTap: () async {
//                                   await UrlLauncher.phoneCall(
//                                       controller.phoneNumber);
//                                 },
//                                 child:   TextWidget(text:
//                                   controller.phoneNumber,
//                                   style: theme.textTheme.bodyLarge?.copyWith(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Email",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing: SizedBox(
//                                 width: 200.sp,
//                                 child: InkWell(
//                                   onTap: () async {
//                                     await UrlLauncher.email(controller.email);
//                                   },
//                                   child:   TextWidget(text:
//                                     controller.email,
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: theme.primaryColor,
//                                     ),
//                                     textAlign: TextAlign.end,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             ListTile(
//                               title:   TextWidget(text:
//                                 "Resource",
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   color: LightThemeColors.hintTextColor,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               trailing:   TextWidget(text:
//                                 controller.resource,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             MainDivider(),
//                             Obx(() => Column(
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 12.sp),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                             TextWidget(text:
//                                             "Status",
//                                             style: theme.textTheme.bodyLarge
//                                                 ?.copyWith(
//                                               color: LightThemeColors
//                                                   .hintTextColor,
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           SizedBox(height: 8.sp),
//                                           Container(
//                                             height: 40.sp,
//                                             width: double.infinity,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 10.sp),
//                                             decoration: BoxDecoration(
//                                               color: LightThemeColors.fillColor,
//                                               borderRadius:
//                                                   BorderRadius.circular(10.r),
//                                               border: Border.all(
//                                                 width: 1,
//                                                 color: LightThemeColors
//                                                     .hintTextColor,
//                                               ),
//                                             ),
//                                             child: DropdownButtonHideUnderline(
//                                               child: DropdownButton2<int>(
//                                                 isExpanded: true,
//                                                 dropdownStyleData:
//                                                     DropdownStyleData(
//                                                         maxHeight: 245.sp,
//                                                         width: 220.sp,
//                                                         padding:
//                                                             EdgeInsets.zero,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       8.r),
//                                                           color:
//                                                               LightThemeColors
//                                                                   .fillColor,
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withValues(
//                                                                       alpha:
//                                                                           0.2),
//                                                               offset:
//                                                                   const Offset(
//                                                                       0, 4),
//                                                               blurRadius: 10,
//                                                               spreadRadius: 0,
//                                                             ),
//                                                           ],
//                                                         )),
//                                                 value: controller
//                                                             .selectedStatusValue
//                                                             .value ==
//                                                         0
//                                                     ? null
//                                                     : controller
//                                                         .selectedStatusValue
//                                                         .value,
//                                                 hint:   TextWidget(text:
//                                                   'Select an option',
//                                                   style: TextStyle(
//                                                     color: LightThemeColors
//                                                         .hintTextColor,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontSize: 12.sp,
//                                                   ),
//                                                 ),
//                                                 style:
//                                                     theme.textTheme.bodyMedium,
//                                                 items: controller
//                                                     .settingController
//                                                     .appointmentsStatus
//                                                     .map((e) {
//                                                   return DropdownMenuItem<int>(
//                                                     value: e.statusId,
//                                                     child:   TextWidget(text:
//                                                       e.statusName ?? "",
//                                                       style: theme
//                                                           .textTheme.bodyMedium
//                                                           ?.copyWith(
//                                                         fontSize: 14.sp,
//                                                         fontWeight:
//                                                             FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                                 onChanged: (int? newValue) {
//                                                   if (newValue == 4) {
//                                                     showAdaptiveDialog(
//                                                         context: context,
//                                                         builder: (context) {
//                                                           return AlertDialog(
//                                                             title: const   TextWidget(text:
//                                                               'Warning!',
//                                                               style: TextStyle(
//                                                                 color:
//                                                                     Colors.red,
//                                                               ),
//                                                             ),
//                                                             content: const   TextWidget(text:
//                                                                 'Choosing close will remove the appointment from the list.Are you sure you want to close?'),
//                                                             actions: [
//                                                               TextButton(
//                                                                 onPressed: () {
//                                                                   Get.back();
//                                                                 },
//                                                                 child: const   TextWidget(text:
//                                                                     'Cancel'),
//                                                               ),
//                                                               TextButton(
//                                                                 onPressed: () {
//                                                                   Get.back();
//                                                                   controller
//                                                                           .selectedStatusValue
//                                                                           .value =
//                                                                       newValue!;
//                                                                 },
//                                                                 child:   TextWidget(text:
//                                                                   'Close',
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: LightThemeColors
//                                                                         .bodyTextSecondaryColor,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           );
//                                                         });
//                                                   } else {
//                                                     controller
//                                                         .selectedStatusValue
//                                                         .value = newValue!;
//                                                   }
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(height: 10.sp),
//                                     MainDivider(),
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 12.sp),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                             TextWidget(text:
//                                             "Ticket Status",
//                                             style: theme.textTheme.bodyLarge
//                                                 ?.copyWith(
//                                               color: LightThemeColors
//                                                   .hintTextColor,
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           SizedBox(height: 8.sp),
//                                           Container(
//                                             height: 40.sp,
//                                             width: double.infinity,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 10.sp),
//                                             decoration: BoxDecoration(
//                                               color: LightThemeColors.fillColor,
//                                               borderRadius:
//                                                   BorderRadius.circular(10.r),
//                                               border: Border.all(
//                                                 width: 1,
//                                                 color: LightThemeColors
//                                                     .hintTextColor,
//                                               ),
//                                             ),
//                                             child: DropdownButtonHideUnderline(
//                                               child: DropdownButton2<int>(
//                                                 isExpanded: true,
//                                                 dropdownStyleData:
//                                                     DropdownStyleData(
//                                                         maxHeight: 200.sp,
//                                                         width: 220.sp,
//                                                         padding:
//                                                             EdgeInsets.zero,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       8.r),
//                                                           color:
//                                                               LightThemeColors
//                                                                   .fillColor,
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withValues(
//                                                                       alpha:
//                                                                           0.2),
//                                                               offset:
//                                                                   const Offset(
//                                                                       0, 4),
//                                                               blurRadius: 10,
//                                                               spreadRadius: 0,
//                                                             ),
//                                                           ],
//                                                         )),
//                                                 value: controller
//                                                             .selectedTicketStatusValue
//                                                             .value ==
//                                                         0
//                                                     ? null
//                                                     : controller
//                                                         .selectedTicketStatusValue
//                                                         .value,
//                                                 hint:   TextWidget(text:
//                                                   'Select an option',
//                                                   style: TextStyle(
//                                                     color: LightThemeColors
//                                                         .hintTextColor,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontSize: 12.sp,
//                                                   ),
//                                                 ),
//                                                 style:
//                                                     theme.textTheme.bodyMedium,
//                                                 items: controller
//                                                     .settingController.tickets
//                                                     .map((e) {
//                                                   return DropdownMenuItem<int>(
//                                                     value: e.statusId,
//                                                     child:   TextWidget(text:
//                                                       e.statusName ?? "",
//                                                       style: theme
//                                                           .textTheme.bodyMedium
//                                                           ?.copyWith(
//                                                         fontSize: 14.sp,
//                                                         fontWeight:
//                                                             FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                                 onChanged: (int? newValue) {
//                                                   controller
//                                                       .selectedTicketStatusValue
//                                                       .value = newValue!;
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 )),
//                             MainDivider(),
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 8.sp, horizontal: 12.sp),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                     TextWidget(text:
//                                     "Notes",
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: LightThemeColors.hintTextColor,
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     textAlign: TextAlign.start,
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: GeneralTextField(
//                                         maxLine: 4,
//                                         hint: "Add a note here..",
//                                         theme: theme,
//                                         textEditingController:
//                                             controller.noteTextController),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10.sp),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48.sp,
//                       child: PrimaryButton(
//                           title: "Update",
//                           onPressed: () async {
//                             await controller.updateAppointment(
//                                 controller.selectedTicketStatusValue.value
//                                     .toString(),
//                                 controller.selectedStatusValue.value
//                                     .toString());
//                           },
//                           inactive: false),
//                     ),
//                     SizedBox(height: 35.sp),
//                     Padding(
//                       padding: EdgeInsets.only(left: 10.0.sp),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Center(
//                             child:   TextWidget(text:
//                               "Estimate/Invoice Details",
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 18.sp,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 10.sp),
//                           Builder(builder: (context) {
//                             return SplashContainer(
//                               height: 45.sp,
//                               width: 150.sp,
//                               radius: 5,
//                               color: theme.primaryColor,
//                               onPressed: () {
//                                 RenderBox renderBox =
//                                     context.findRenderObject() as RenderBox;
//                                 Offset offset = renderBox
//                                     .localToGlobal(Offset(32.sp, 40.sp));
//                                 final RenderBox overlay = Overlay.of(context)
//                                     .context
//                                     .findRenderObject() as RenderBox;
//                                 showMenu(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(8.r)),
//                                   ),
//                                   context: context,
//                                   position: RelativeRect.fromRect(
//                                       offset &
//                                           Size(
//                                               32.sp,
//                                               32
//                                                   .sp), // smaller rect, the touch area
//                                       Offset.zero &
//                                           overlay
//                                               .size // Bigger rect, the entire screen
//                                       ),
//                                   items: controller
//                                       .invoiceController.createTypes
//                                       .map((e) {
//                                     return PopupMenuItem(
//                                       value: e["name"],
//                                       child:   TextWidget(text: "${e["name"]}"),
//                                     );
//                                   }).toList(),
//                                 ).then((v) async {
//                                   if (v != null) {
//                                     controller.invoiceController
//                                         .clearAllItems();
//                                     controller.invoiceController
//                                         .selectedCreateType.value = v;

//                                     if (v == "Invoice") {
//                                       controller.invoiceController
//                                               .createCustomerName =
//                                           controller.contactName;
//                                       controller.invoiceController
//                                               .createCustomerAddress =
//                                           controller.address;
//                                       controller.invoiceController
//                                               .createCustomerPhone =
//                                           controller.mobileNumber;
//                                       controller.invoiceController
//                                               .createCustomerEmail =
//                                           controller.email;
//                                       controller.invoiceController.customerID
//                                           .value = controller.customerID;
//                                       controller
//                                               .invoiceController.appointmentID =
//                                           controller.appointmentID;
//                                       controller.invoiceController.selectedTaxID
//                                           .value = "";
//                                       controller.invoiceController
//                                           .createDiscountTextController
//                                           .clear();
//                                       await controller.invoiceController
//                                           .getInvoiceName();
//                                       Get.toNamed(Routes.INVOICE_CREATE);
//                                     } else {
//                                       controller.invoiceController
//                                               .createCustomerName =
//                                           controller.contactName;
//                                       controller.invoiceController
//                                               .createCustomerAddress =
//                                           controller.address;
//                                       controller.invoiceController
//                                               .createCustomerPhone =
//                                           controller.mobileNumber;
//                                       controller.invoiceController
//                                               .createCustomerEmail =
//                                           controller.email;
//                                       controller.invoiceController.customerID
//                                           .value = controller.customerID;

//                                       controller
//                                               .invoiceController.appointmentID =
//                                           controller.appointmentID;
//                                       controller.invoiceController.selectedTaxID
//                                           .value = "";
//                                       controller.invoiceController
//                                           .createDiscountTextController
//                                           .clear();
//                                       await controller.invoiceController
//                                           .getInvoiceName();
//                                       Get.toNamed(Routes.INVOICE_CREATE);
//                                     }
//                                   }
//                                 });
//                               },
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.add_circle_outline,
//                                       color: Colors.white,
//                                       size: 18.sp,
//                                     ),
//                                     SizedBox(width: 5.sp),
//                                       TextWidget(text:
//                                       "Create New",
//                                       style:
//                                           theme.textTheme.bodyLarge?.copyWith(
//                                         color: Colors.white,
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 15.sp),
//                     Obx(() => ListView.separated(
//                           itemBuilder: (context, index) {
//                             final proposal = controller
//                                 .appointments[controller.selectedAptIndex.value]
//                                 .invoices![index];

//                             return GestureDetector(
//                               onTap: () async {
//                                 controller.showLoading();

//                                 // Clear previous selection if needed
//                                 controller.invoiceController.selectedItemList
//                                     .clear();
//                                 for (var c in controller
//                                     .invoiceController.editAmountControllers) {
//                                   c.dispose();
//                                 }
//                                 for (var c in controller.invoiceController
//                                     .editDescriptionControllers) {
//                                   c.dispose();
//                                 }
//                                 for (var c in controller.invoiceController
//                                     .editQuantityControllers) {
//                                   c.dispose();
//                                 }
//                                 controller
//                                     .invoiceController.editAmountControllers
//                                     .clear();
//                                 controller.invoiceController
//                                     .editDescriptionControllers
//                                     .clear();
//                                 controller
//                                     .invoiceController.editQuantityControllers
//                                     .clear();
//                                 controller
//                                     .invoiceController.editNoteTextController
//                                     .clear();
//                                 controller.invoiceController
//                                     .editDiscountTextController
//                                     .clear();
//                                 controller
//                                     .invoiceController.initialTaxID.value = "";

//                                 // Set basic info
//                                 controller.invoiceController.invoiceItemList
//                                     .value = proposal.items ?? [];
//                                 controller.invoiceController.depositList.value =
//                                     proposal.paymentList ?? [];
//                                 controller
//                                     .invoiceController
//                                     .selectedDiscountOption
//                                     .value = proposal.discountOption ?? "2";
//                                 controller.invoiceController.invoiceNumber =
//                                     proposal.number ?? "";
//                                 controller.invoiceController.isConverted.value =
//                                     proposal.isConverted ?? false;
//                                 controller.invoiceController.customerName =
//                                     proposal.fullName ?? "";
//                                 controller.invoiceController.address =
//                                     "${proposal.city}";
//                                 controller.invoiceController.depositAmount
//                                     .value = proposal.depositAmount.toString();
//                                 controller.invoiceController.invoiceID.value =
//                                     proposal.invoiceID.toString();
//                                 controller.invoiceController.date =
//                                     dateTimeConverter(
//                                         inputFormat: "yyyy/MM/dd",
//                                         inputTime:
//                                             proposal.invoiceDate.toString(),
//                                         outputFormat: "MM/dd/yyyy");
//                                 controller.invoiceController.subtotal =
//                                     proposal.subtotal?.toStringAsFixed(1) ?? "";
//                                 controller.invoiceController.customerID.value =
//                                     proposal.customerId ?? "";
//                                 controller.invoiceController.status =
//                                     proposal.status ?? "";
//                                 controller.invoiceController.type.value =
//                                     proposal.type ?? "";
//                                 controller.invoiceController.total.value =
//                                     proposal.total?.toStringAsFixed(1) ?? "";
//                                 controller.invoiceController.newTotal.value =
//                                     controller.invoiceController.total.value;
//                                 controller.invoiceController.notes =
//                                     proposal.note ?? "";
//                                 controller
//                                     .invoiceController
//                                     .editNoteTextController
//                                     .text = proposal.note ?? "";
//                                 controller.invoiceController.due =
//                                     proposal.due ?? "";
//                                 controller.invoiceController.showingDate.value =
//                                     dateTimeConverter(
//                                         inputFormat: "yyyy/MM/dd hh:mm a",
//                                         inputTime:
//                                             proposal.invoiceDate.toString(),
//                                         outputFormat: "MM/dd/yyyy");
//                                 if (proposal.taxType != "") {
//                                   controller.invoiceController.initialTaxID
//                                       .value = proposal.taxType ?? "";
//                                 }
//                                 // Set discount values
//                                 controller
//                                     .invoiceController
//                                     .invoiceDiscountDetails
//                                     .value = proposal.discount ?? 0.00;
//                                 if (proposal.discountOption == "1") {
//                                   controller
//                                       .invoiceController
//                                       .editDiscountTextController
//                                       .text = (((double.parse(proposal.discount
//                                                       ?.toString() ??
//                                                   "0.00")) *
//                                               100) /
//                                           double.parse(proposal.subtotal
//                                                   ?.toStringAsFixed(2) ??
//                                               "0.00"))
//                                       .toStringAsFixed(2);
//                                 } else {
//                                   controller
//                                       .invoiceController
//                                       .editDiscountTextController
//                                       .text = double.parse(
//                                           proposal.discount?.toString() ??
//                                               "0.00")
//                                       .toStringAsFixed(2);
//                                 }

//                                 // Set tax values

//                                 controller.invoiceController.tax.value =
//                                     controller.invoiceController.taxes
//                                             .firstWhereOrNull((tax) =>
//                                                 tax.id ==
//                                                 int.tryParse(controller
//                                                     .invoiceController
//                                                     .initialTaxID
//                                                     .value))
//                                             ?.rate
//                                             ?.toStringAsFixed(2) ??
//                                         "0.00";

//                                 // Populate selectedItemList and initialize controllers
//                                 if (proposal.items != null &&
//                                     proposal.items!.isNotEmpty) {
//                                   for (var item in proposal.items!) {
//                                     controller
//                                         .invoiceController.selectedItemList
//                                         .add(ItemListModel(
//                                       id: item.itemId,
//                                       name: item.name,
//                                       description: item.description,
//                                       price: double.tryParse(
//                                           item.unitPrice ?? "0.00"),
//                                       isTaxable: item.isTaxable == "TAX"
//                                           ? true
//                                           : false,
//                                       // itemTypeId: int.parse(item.itemTyId!),
//                                     ));

//                                     // Initialize controllers with existing values
//                                     controller
//                                         .invoiceController.editAmountControllers
//                                         .add(TextEditingController(
//                                             text: item.unitPrice ?? "0.00"));

//                                     controller.invoiceController
//                                         .editDescriptionControllers
//                                         .add(TextEditingController(
//                                             text: item.description ?? ""));

//                                     controller.invoiceController
//                                         .editQuantityControllers
//                                         .add(TextEditingController(
//                                             text: item.quantity ?? "1"));
//                                   }
//                                 }
//                                 controller.invoiceController
//                                     .createTotalForEdit();
//                                 await 0.5
//                                     .delay(); // Optional small delay before navigation
//                                 controller.hideLoading();
//                                 Get.toNamed(Routes.INVOICE_DETAILS);
//                               },
//                               child: Card(
//                                 elevation: 0,
//                                 color: Colors.white,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     ListTile(
//                                       title:   TextWidget(text:
//                                         "${proposal.type ?? ""} Number",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           color: LightThemeColors.hintTextColor,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       trailing: Container(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 8.sp, vertical: 2.sp),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(5.r),
//                                           color: proposal.type == "Invoice"
//                                               ? theme.primaryColor
//                                               : proposal.type == "Estimate" &&
//                                                       proposal.isConverted ==
//                                                           true
//                                                   ? Colors.green
//                                                   : Colors.yellow,
//                                         ),
//                                         child:   TextWidget(text:
//                                           proposal.number ?? "",
//                                           style: theme.textTheme.bodyLarge
//                                               ?.copyWith(
//                                             fontSize: 14.sp,
//                                             fontWeight: FontWeight.w500,
//                                             color:
//                                                 proposal.type == "Estimate" &&
//                                                         proposal.isConverted ==
//                                                             false
//                                                     ? Colors.black
//                                                     : Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     MainDivider(),
//                                     ListTile(
//                                       title:   TextWidget(text:
//                                         "Date",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           color: LightThemeColors.hintTextColor,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       trailing: proposal.invoiceDate != ""
//                                           ?   TextWidget(text:
//                                               dateTimeConverter(
//                                                   inputFormat:
//                                                       "yyyy/MM/dd hh:mm a",
//                                                   inputTime: proposal
//                                                       .invoiceDate
//                                                       .toString(),
//                                                   outputFormat: "MM/dd/yyyy"),
//                                               style: theme.textTheme.bodyLarge
//                                                   ?.copyWith(
//                                                 fontSize: 14.sp,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             )
//                                           :   TextWidget(text: ""),
//                                     ),
//                                     MainDivider(),
//                                     ListTile(
//                                       title:   TextWidget(text:
//                                         "Required Amount",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           color: LightThemeColors.hintTextColor,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       trailing:   TextWidget(text:
//                                         "\$${proposal.total?.toStringAsFixed(2) ?? ""}",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                     MainDivider(),
//                                     ListTile(
//                                       title:   TextWidget(text:
//                                         "Amount Received",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           color: LightThemeColors.hintTextColor,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       trailing:   TextWidget(text:
//                                         "\$${proposal.depositAmount?.toStringAsFixed(2) ?? ""}",
//                                         style:
//                                             theme.textTheme.bodyLarge?.copyWith(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                           separatorBuilder: (BuildContext context, int index) =>
//                               SizedBox(height: 8.sp),
//                           itemCount: controller
//                               .appointments[controller.selectedAptIndex.value]
//                               .invoices!
//                               .length,
//                           shrinkWrap: true,
//                           reverse: true,
//                           physics: NeverScrollableScrollPhysics(),
//                         )),
//                     SizedBox(height: 15.sp),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class ResourceItem {
  final String title;
  RxBool selected;

  ResourceItem({required this.title, bool selected = false})
      : selected = selected.obs;
}

final List<String> productList = ["Computer", "Plumbing", "Tailoring", "AC"];

void openGoogleMaps(String query) async {
  final encodedQuery = Uri.encodeComponent("$query shop near me");
  final url = "https://www.google.com/maps/search/?api=1&query=$encodedQuery";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print("Could not launch $url");
  }
}

void showNoteDetailsDialog(
  BuildContext context,
  NoteModel note,
  ThemeData theme,
  String tagName,
) {
  showDialog(
    context: context,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // Allow the dialog to expand up to 80% of the screen height
            maxHeight: screenHeight * 0.8,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Note Details",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // User Name & Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            note.userName ?? "N/A",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat(
                          "dd MMM yyyy",
                        ).format(DateTime.parse(note.createdAt!)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Tag chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: TextWidget(
                      text: tagName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Description
                  TextWidget(
                    textAlign: TextAlign.justify,
                    maxLines: 500,
                    overflow: TextOverflow.visible,
                    text: note.description ?? "No description available.",
                    style: theme.textTheme.bodyMedium,
                  ),

                  SizedBox(height: 20.h),

                  // Close Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buildCustomFieldWidget(CustomFieldModel field, BuildContext context) {
  switch (field.fieldType) {
    // ---------------- DROPDOWN ----------------
    case 'dropdown':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldName!, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 10.h),
          DropdownButton<String>(
            isExpanded: true,
            value: field.selectedValue,
            hint: Text("Select ${field.fieldName}"),
            items: field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) field.selectedValue = value;
            },
          ),
        ],
      );

    // ---------------- CHECKLIST ----------------
    case 'checklist':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldName!, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 10.h),
          ...field.options!.map((option) {
            return CheckboxListTile(
              checkColor: Colors.white,
              activeColor: Colors.blue,
              tileColor: field.selectedOptions!.contains(option)
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              title: Text(option),
              value: field.selectedOptions!.contains(option),
              onChanged: (isChecked) {
                if (isChecked == true) {
                  field.selectedOptions!.add(option);
                } else {
                  field.selectedOptions!.remove(option);
                }
              },
            );
          }),
        ],
      );

    // ---------------- TEXT FIELD ----------------
    case 'text':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldName!, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 10.h),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter ${field.fieldName}",
            ),
            onChanged: (value) {
              field.textValue = value;
            },
          ),
        ],
      );

    // ---------------- NUMBER FIELD ----------------
    case 'number':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldName!, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 10.h),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter ${field.fieldName}",
            ),
            onChanged: (value) {
              field.numberValue = value;
            },
          ),
        ],
      );

    // ---------------- UNSUPPORTED ----------------
    default:
      return Text("Unsupported field type: ${field.fieldType}");
  }
}

void showProductDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select a Service"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(productList[index]),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  openGoogleMaps(productList[index]);
                },
              );
            },
          ),
        ),
      );
    },
  );
}
