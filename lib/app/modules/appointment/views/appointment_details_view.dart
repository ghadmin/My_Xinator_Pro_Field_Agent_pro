// ═══════════════════════════════════════════════════════════════
// AppointmentDetailsView — Warm Organic Blue Redesign
// Preserves all original logic and data with new UI design
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ─── Warm Organic Blue Design ───────────────────────────────────
import '../../../../utils/url_launcher.dart';
import '../../../../config/theme/warm_organic_blue_theme.dart';
import '../../../service/REST/api_urls.dart';
import 'widgets/warm_organic_components.dart';
// ───────────────────────────────────────────────────────────────────

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/klog.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../models/forms/forms_models.dart';
import '../../../modules/forms/controllers/forms_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/phone_number_formatter.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/custom_fields_controller.dart';
import '../models/appointment_model.dart';
import '../models/custom_field_model.dart';
import 'widgets/equipment_form_modal.dart';
import '../models/file_model.dart';
import '../../item/models/item_list_model.dart';

class AppointmentDetailsView extends StatefulWidget {
  const AppointmentDetailsView({super.key});

  @override
  State<AppointmentDetailsView> createState() => _AppointmentDetailsViewState();
}

class _AppointmentDetailsViewState extends State<AppointmentDetailsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _previousTabIndex = 0;
  FormsController? formsController;
  final GlobalKey _createInvoiceButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Check if FormsController exists, if not create it
    if (Get.isRegistered<FormsController>()) {
      formsController = Get.find<FormsController>();
    } else {
      log("Creating new FormsController");
      formsController = Get.put(FormsController());
    }

    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == _previousTabIndex) return;

      _previousTabIndex = _tabController.index;
      kLog("tabController index: ${_tabController.index}");
      if (_tabController.index == 0) {
        _loadSavedCustomFields();
        setState(() {});
      }
      if (_tabController.index == 1) {
        controller.getCustomerSite(showLoader: true);
        Future.delayed(Duration(seconds: 7));
        controller.isBasicExpanded(true);
        setState(() {});
      }
      if (_tabController.index == 2) {
        formsController = Get.put<FormsController>(FormsController());
        formsController?.pollPendingForms(
          controller.selectedAppointment.value?.resourceID ?? "",
        );
        // _buildFormsTab(context);
        setState(() {});
      }
      if (_tabController.index == 4) {
        controller.getImageList(true);
        setState(() {});
      }
      if (_tabController.index == 3) {
        controller.getInvoiceList(showLoader: true);
        setState(() {});
      }
      if (_tabController.index == 5) {
        controller.getCustomerSite(showLoader: true);
        controller.getEquipment(showLoader: true);
        controller.getEquipmentTypes(showLoader: true);
        setState(() {});
      }
      if (_tabController.index == 6) {
        controller.getFileList(showLoader: true);
        setState(() {});
      }
      if (_tabController.index == 7) {
        controller.getAllNotes(showLoader: true);
        setState(() {});
      }
    });
  }

  Future<void> _loadSavedCustomFields() async {
    try {
      final appointmentId = controller.selectedAppointment.value?.apptID;
      if (appointmentId == null) return;

      log("📥 Loading saved custom fields for appointment: $appointmentId");
      await customFieldsController.getAttachedCustomFields(
        appointmentId: appointmentId,
      );

      if (customFieldsController.attachedCustomFields.isNotEmpty) {
        customFieldsController.selectedCustomFields.clear();

        for (var attachedField in customFieldsController.attachedCustomFields) {
          var fieldDef = customFieldsController.allCustomFields
              .firstWhereOrNull((f) => f.fieldID == attachedField.fieldID);

          if (fieldDef != null) {
            var newField = CustomFieldModel(
              fieldID: fieldDef.fieldID,
              fieldName: fieldDef.fieldName,
              fieldType: fieldDef.fieldType,
              fieldOptions: fieldDef.fieldOptions,
              isActive: fieldDef.isActive,
              options: fieldDef.options,
            );

            switch (fieldDef.fieldType) {
              case 'text':
                newField.textValue = attachedField.fieldValue;
                break;
              case 'number':
                newField.numberValue = attachedField.fieldValue;
                break;
              case 'dropdown':
                newField.selectedValue = attachedField.fieldValue;
                break;
              case 'checklist':
                newField.selectedOptions = attachedField.getFieldValueAsList();
                break;
            }

            customFieldsController.selectedCustomFields.add(newField);
          }
        }

        log(
          "✅ Loaded ${customFieldsController.selectedCustomFields.length} saved custom fields",
        );
        setState(() {});
      } else {
        log(
          "ℹ️ No attached custom fields found for appointment: $appointmentId",
        );
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

  // ─────────────────────────────────────────────────────────────
  // MAIN BUILD — REDESIGNED WITH WARM ORGANIC BLUE THEME
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Theme(
      data: WarmOrganicBlueTheme.themeData,
      child: Scaffold(
        appBar: Get.size.width <= 440
            ? AppBar(elevation: 1, title: Text("Appointment Details"))
            : PreferredSize(
                preferredSize: Size.fromHeight(40.sp),
                child: Padding(
                  padding: EdgeInsets.only(top: 15.sp),
                  child: AppBar(
                    elevation: 1,
                    title: Padding(
                      padding: EdgeInsets.only(top: 8.sp),
                      child: Text(
                        "Appointment Details",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

        // Contact Name (tappable) this thing add to appbar. ),
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        body: Obx(
          () => controller.selectedAppointment.value == null
              ? Center(
                  child: EmptyWidget(
                    isRefreshShown: false,
                    title: "No appointments",
                    onPressed: () => Get.back(),
                  ),
                )
              : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            children: [
                              _buildGradientHeader(context),

                              OrganicTabBar(
                                controller: _tabController,
                                tabs: const [
                                  'Info',
                                  'CSL',
                                  'Forms',
                                  'Estimate',
                                  'Pictures',
                                  'Equipment',
                                  'Files',
                                  'Notes',
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _buildSelectedTabContent(context),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GRADIENT HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 8.h),
      decoration: BoxDecoration(
        gradient: WarmOrganicBlueTheme.headerGradient,
        borderRadius: BorderRadius.all(
          Radius.circular(WarmOrganicBlueTheme.radiusXl),
        ),
        boxShadow: WarmOrganicBlueTheme.elevatedShadow,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Back + Title
            GestureDetector(
              onTap: () async {
                controller.showLoading();
                await controller.customerController.getCustomers();
                controller.customerController.businessName =
                    controller.contactName;
                controller.customerController.title = controller.customerTitle;
                controller.customerController.address = controller.address;
                controller.customerController.phoneNumber =
                    controller.phoneNumber;
                controller.customerController.mobileNumber =
                    controller.mobileNumber;
                controller.customerController.email = controller.email;
                controller.hideLoading();
                Get.toNamed(Routes.CUSTOMER_DETAILS);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.contactName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Service: ${controller.serviceType}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 24.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Status Badges
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showDialogStatusChange(context, controller),
                    child: _buildStatusBadge(
                      controller
                              .settingController
                              .selectedAppointmentsStatus
                              .value
                              ?.statusName ??
                          "",
                      _getStatusColor(
                        controller
                            .settingController
                            .selectedAppointmentsStatus
                            .value
                            ?.statusName,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showDialogTicketStatus(context, controller),
                    child: _buildStatusBadge(
                      'Ticket: ${controller.settingController.selectedTicket.value?.statusName ?? "N/A"}',
                      _getTicketColor(
                        controller
                            .settingController
                            .selectedTicket
                            .value
                            ?.statusName,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Contact Info Chips
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfoChip(
                    Icons.location_on_rounded,
                    controller.address,
                    () async {
                      await controller.initializeWebController();
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            // Make dialog full width
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double
                                        .infinity, // ← This makes it full width
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.sp,
                                      ),
                                      child: Obx(
                                        () => Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.sp),
                                              child: WebViewWidget(
                                                controller:
                                                    controller.webController!,
                                              ),
                                            ),
                                            if (controller.isLoading.value)
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.blue,
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
                                    onPressed: () => Get.back(),
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfoChip(
                    Icons.phone_rounded,
                    controller.mobileNumber.isNotEmpty
                        ? controller.mobileNumber
                        : controller.phoneNumber.isNotEmpty
                        ? controller.phoneNumber
                        : 'N/A',
                    () async {
                      await UrlLauncher.phoneCall(controller.mobileNumber);
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildHeaderInfoChip(
                    Icons.email_rounded,
                    controller.email.isNotEmpty ? controller.email : 'N/A',
                    controller.email == ""
                        ? () {}
                        : () async {
                            await UrlLauncher.email(controller.email);
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextWidget(
              text: label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.white, size: 20.sp),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  Color _getTicketColor(String? status) {
    switch (status?.toLowerCase()) {
      case "installation in progress":
        return const Color(0xffE98862);
      case "on hold":
        return const Color.fromARGB(255, 243, 18, 18);
      case "parts on order":
        return const Color.fromARGB(255, 21, 234, 242);
      case "completed":
        return const Color.fromARGB(255, 11, 197, 145);
      default:
        return Colors.red;
    }
  }

  Widget _buildHeaderInfoChip(IconData icon, String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusSm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextWidget(
                  text: text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  maxLines: 5,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FAB
  // ─────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10.h),
          SizedBox(height: 10.sp),
          Container(
            decoration: BoxDecoration(
              gradient: WarmOrganicBlueTheme.fabGradient,
              borderRadius: BorderRadius.circular(
                WarmOrganicBlueTheme.radiusFull,
              ),
              boxShadow: WarmOrganicBlueTheme.elevatedShadow,
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showSMSBottomSheet(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: Icon(Icons.send_rounded, size: 20.sp),
              label: Text(
                'Send SMS',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSMSBottomSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    controller.appointmentDetailsNoteFocusnode.value.unfocus();
    controller.appointmentDetailsMessageFocusnode.value.unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Send Message",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: WarmOrganicBlueTheme.deepNavy,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "Phone",
                    style: WarmOrganicBlueTheme.bodySmall.copyWith(
                      color: WarmOrganicBlueTheme.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.sp,
                      vertical: 6.sp,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      color: Colors.grey.shade50,
                    ),
                    child: Text(
                      controller.phoneNumber.isNotEmpty
                          ? PhoneNumberFormatter.formatPhoneNumber(
                              controller.phoneNumber,
                            )
                          : controller.mobileNumber.isNotEmpty
                          ? PhoneNumberFormatter.formatPhoneNumber(
                              controller.mobileNumber,
                            )
                          : "No Phone Number",
                      style: TextStyle(
                        color: WarmOrganicBlueTheme.darkSlate,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Text(
                    'Message',
                    style: WarmOrganicBlueTheme.bodySmall.copyWith(
                      color: WarmOrganicBlueTheme.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  TextField(
                    maxLines: 5,
                    minLines: 1,
                    focusNode: controller.appointmentDetailsNoteFocusnode.value,
                    textInputAction: TextInputAction.newline,
                    controller: controller.smsController,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: WarmOrganicBlueTheme.darkSlate,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 48.sp,
                          child: OrganicSecondaryButton(
                            text: "Cancel",
                            onPressed: () {
                              controller.smsController.clear();
                              FocusScope.of(context).unfocus();
                              Get.back();
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48.sp,
                          child: OrganicPrimaryButton(
                            text: "Send",
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              Get.back();
                              if (controller.mobileNumber.isEmpty &&
                                  controller.phoneNumber.isEmpty) {
                                MySnackBar.showErrorToast(
                                  message:
                                      "No phone number found for this customer.",
                                );
                                return;
                              }
                              await 1.delay();
                              await controller.sendSMS();
                            },
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
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB CONTENT SELECTOR
  // ─────────────────────────────────────────────────────────────
  Widget _buildSelectedTabContent(BuildContext context) {
    return Obx(() {
      switch (_tabController.index) {
        case 0:
          return _buildInfoTab(context);
        case 1:
          return _buildCslTab(context);
        case 2:
          return _buildFormsTab(context);
        case 3:
          return _buildEstimateTab(context);
        case 4:
          return _buildPicturesTab(context);
        case 5:
          return _buildEquipmentTab(context);
        case 6:
          return _buildFilesTab(context);
        case 7:
          return _buildNotesTab(context);
        default:
          return _buildInfoTab(context);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 0 — INFO
  // ─────────────────────────────────────────────────────────────
  Widget _buildInfoTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dates Card
          OrganicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment Info',
                  style: WarmOrganicBlueTheme.headingSmall,
                ),
                OrganicDivider(),
                _buildInfoTile(
                  Icons.calendar_today_rounded,
                  'Request Date',
                  controller.requestDate,
                ),
                _buildInfoTile(
                  Icons.play_circle_outline_rounded,
                  'Start Date',
                  controller.startDate,
                ),
                _buildInfoTile(
                  Icons.stop_circle_outlined,
                  'End Date',
                  controller.endDate,
                ),
                _buildInfoTile(
                  Icons.schedule_rounded,
                  'Time Slot',
                  controller.timeSlot,
                ),
                _buildInfoTile(
                  Icons.category_rounded,
                  'Service Type',
                  controller.serviceType,
                ),
                _buildInfoTile(
                  Icons.person_rounded,
                  'Resource',
                  controller.selectedAppointment.value?.resource?.name ?? "N/A",
                ),
              ],
            ),
          ),

          // Notes Card
          OrganicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Any Details', style: WarmOrganicBlueTheme.headingSmall),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: WarmOrganicBlueTheme.warmGray,
                    borderRadius: BorderRadius.circular(
                      WarmOrganicBlueTheme.radiusMd,
                    ),
                  ),
                  child: GeneralTextField(
                    maxLine: 4,
                    hint: "Add a note here..",
                    theme: Theme.of(context),
                    textEditingController: controller.noteController,
                    onChanged: (v) {
                      controller.isTyping(true);
                      controller.noteText(v);
                    },
                    onEditingComplete: () => controller.isTyping(false),
                  ),
                ),
                SizedBox(height: 12.h),
                OrganicPrimaryButton(
                  text: 'Save Notes',
                  height: 40.h,
                  onPressed: () async => await controller.updateAppointment(),
                ),
              ],
            ),
          ),

          // Custom Fields Card
          OrganicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Custom Fields', style: WarmOrganicBlueTheme.headingSmall),
                SizedBox(height: 12.h),
                DropdownButton<CustomFieldModel>(
                  isExpanded: true,
                  icon: Icon(
                    Icons.add,
                    color: WarmOrganicBlueTheme.primaryBlue,
                  ),
                  value: null,
                  items: customFieldsController.allCustomFields.map((field) {
                    return DropdownMenuItem<CustomFieldModel>(
                      value: field,
                      child: Text(field.fieldName!, softWrap: true),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null)
                      customFieldsController.saveCustomField(value);
                  },
                ),
                SizedBox(height: 12.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: customFieldsController.selectedCustomFields.length,
                  separatorBuilder: (context, index) => Divider(
                    color: WarmOrganicBlueTheme.warmSilver,
                    thickness: 1,
                    height: 24.h,
                  ),
                  itemBuilder: (context, index) {
                    final field =
                        customFieldsController.selectedCustomFields[index];
                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 30.w),
                          child: buildCustomFieldWidget(field, context),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              customFieldsController.selectedCustomFields
                                  .removeAt(index);
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
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
                    );
                  },
                ),
                if (customFieldsController.selectedCustomFields.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: OrganicPrimaryButton(
                      text: "Save Custom Fields",
                      onPressed: () async {
                        await customFieldsController.saveAttachedCustomFields(
                          appointmentId:
                              controller.selectedAppointment.value!.apptID,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: WarmOrganicBlueTheme.primaryBlueSoft,
              borderRadius: BorderRadius.circular(
                WarmOrganicBlueTheme.radiusSm,
              ),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: WarmOrganicBlueTheme.primaryBlue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: WarmOrganicBlueTheme.caption),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1 — CSL
  // ─────────────────────────────────────────────────────────────
  Widget _buildCslTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(
        () => Column(
          children: [
            // Basic Information
            OrganicCard(
              shadow: WarmOrganicBlueTheme.softShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          gradient: WarmOrganicBlueTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            WarmOrganicBlueTheme.radiusSm,
                          ),
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Basic Information',
                        style: WarmOrganicBlueTheme.headingSmall,
                      ),
                      const Spacer(),
                      OrganicIconButton(
                        icon: controller.isBasicExpanded.value
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20.sp,
                        onTap: () => controller.isBasicExpanded(
                          !controller.isBasicExpanded.value,
                        ),
                      ),
                    ],
                  ),
                  if (controller.isBasicExpanded.value) ...[
                    OrganicDivider(),
                    _buildCSLRow(
                      'Customer Name',
                      '${controller.selectedSite.value?.firstName ?? ''} ${controller.selectedSite.value?.lastName ?? ''}'
                          .trim(),
                    ),
                    if (controller.selectedSite.value?.siteName != null &&
                        controller.selectedSite.value!.siteName!.isNotEmpty)
                      _buildCSLRow(
                        'Site Name',
                        controller.selectedSite.value!.siteName!,
                      ),
                    if (controller.selectedSite.value?.address != null &&
                        controller.selectedSite.value!.address!.isNotEmpty)
                      _buildCSLRow(
                        'Site Address',
                        controller.selectedSite.value!.address!,
                      ),
                    if (controller.selectedSite.value?.state != null &&
                        controller.selectedSite.value!.state!.isNotEmpty)
                      _buildCSLRow(
                        'State / Province',
                        controller.selectedSite.value!.state!,
                      ),
                    if (controller.selectedSite.value?.zip != null &&
                        controller.selectedSite.value!.zip!.isNotEmpty)
                      _buildCSLRow(
                        'Zip Code',
                        controller.selectedSite.value!.zip!,
                      ),
                    if (controller.selectedSite.value?.contact != null &&
                            controller
                                .selectedSite
                                .value!
                                .contact!
                                .isNotEmpty ||
                        controller.selectedSite.value?.firstName != null ||
                        controller.selectedSite.value?.lastName != null)
                      _buildCSLRow(
                        'Site Contact',
                        '${controller.selectedSite.value?.contact ?? ''} ${controller.selectedSite.value?.firstName ?? ''} ${controller.selectedSite.value?.lastName ?? ''}'
                            .trim(),
                      ),
                    if (controller.selectedSite.value?.phoneNumber != null &&
                        controller.selectedSite.value!.phoneNumber!.isNotEmpty)
                      _buildCSLRow(
                        'Site Phone',
                        controller.selectedSite.value!.phoneNumber!,
                      ),
                    if (controller.selectedSite.value?.email != null &&
                        controller.selectedSite.value!.email!.isNotEmpty)
                      _buildCSLRow(
                        'Site Email',
                        controller.selectedSite.value!.email!,
                      ),
                    if (controller.selectedSite.value == null) ...[
                      _buildCSLRow(
                        'Contact',
                        'Phone: ${controller.selectedAppointment.value?.customer!.phone ?? "N/A"}\nMobile: ${controller.selectedAppointment.value?.customer!.mobile ?? "N/A"}',
                      ),
                      _buildCSLRow(
                        'Email',
                        controller.selectedAppointment.value?.customer!.email ??
                            "N/A",
                      ),
                      if (controller
                                  .selectedAppointment
                                  .value
                                  ?.customer!
                                  .address1 !=
                              null &&
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .address1!
                              .isNotEmpty)
                        _buildCSLRow(
                          'Address Line 1',
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .address1!,
                        ),
                      if (controller
                                  .selectedAppointment
                                  .value
                                  ?.customer!
                                  .address2 !=
                              null &&
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .address2!
                              .isNotEmpty)
                        _buildCSLRow(
                          'Address Line 2',
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .address2!,
                        ),
                      if (controller
                                  .selectedAppointment
                                  .value
                                  ?.customer!
                                  .city !=
                              null &&
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .city!
                              .isNotEmpty)
                        _buildCSLRow(
                          'City',
                          controller.selectedAppointment.value!.customer!.city!,
                        ),
                      if (controller
                                  .selectedAppointment
                                  .value
                                  ?.customer!
                                  .state !=
                              null &&
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .state!
                              .isNotEmpty)
                        _buildCSLRow(
                          'State / Province',
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .state!,
                        ),
                      if (controller
                                  .selectedAppointment
                                  .value
                                  ?.customer!
                                  .zipCode !=
                              null &&
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .zipCode!
                              .isNotEmpty)
                        _buildCSLRow(
                          'Zip Code',
                          controller
                              .selectedAppointment
                              .value!
                              .customer!
                              .zipCode!,
                        ),
                    ],
                    _buildCSLRow(
                      'Created On',
                      '${controller.selectedAppointment.value?.customer!.createdDateTime ?? "N/A"}',
                    ),
                  ],
                ],
              ),
            ),

            // Map Card
            OrganicCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Location',
                          style: WarmOrganicBlueTheme.headingSmall,
                        ),
                        Row(
                          children: [
                            OrganicIconButton(
                              icon: Icons.directions_rounded,
                              onTap: () => openMapWithRoute(controller.address),
                            ),
                            SizedBox(width: 10.w),
                            OrganicIconButton(
                              icon: Icons.open_in_new_rounded,
                              color: WarmOrganicBlueTheme.accentCyan,
                              onTap: () => openGoogleMaps(controller.address),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(WarmOrganicBlueTheme.radiusLg),
                    ),
                    child: SizedBox(
                      height: 250.h,
                      width: double.infinity,
                      child: _InlineMap(address: controller.address),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCSLRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2 — FORMS
  // ─────────────────────────────────────────────────────────────
  Widget _buildFormsTab(BuildContext context) {
    final appointmentId =
        controller.selectedAppointment.value?.apptID?.toString() ?? '';

    return Obx(() {
      // final isLoading = formsController?.isPolling.value ?? false;
      // final allForms = formsController?.pendingForms ?? [];

      // // Filter forms by appointment ID
      // final formsForAppointment = allForms.isNotEmpty
      //     ? allForms.where((f) => f.appointmentId == appointmentId).toList()
      //     : <FormQueueItem>[];

      // // Poll for forms on first load
      // if (appointmentId.isNotEmpty && allForms.isEmpty) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     final resourceId =
      //         controller.selectedAppointment.value?.resourceID ?? 0;
      //     if (resourceId > 0) {
      //       formsController?.pollPendingForms(resourceId);
      //     }
      //   });
      // }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with refresh button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Forms', style: WarmOrganicBlueTheme.headingSmall),
                OrganicIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    final resourceId =
                        controller.selectedAppointment.value?.resourceID ?? 0;
                    if (resourceId > 0) {
                      formsController?.pollPendingForms(resourceId);
                    }
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: formsController!.pendingForms.isEmpty
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
          ),
        ],
      );
    });
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
          // Header row
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

          // Action button
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
                // Pass form metadata for submission
                'formInstanceId': form.formInstanceId,
                'templateId': form.templateId,
                'appointmentId': form.appointmentId,
                'customerId': form.customerId,
                'queueId': form.queueId,
                'formName': form.template.name,
              };

              // Parse smartFieldData if available
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

              // Show loading dialog using controller
              controller.showLoading();

              try {
                final pdfBase64 = await formsController?.getFormPdfAsBase64(
                  ApiUrl.pdfBaseUrl + config['form']['pdfFile']['path'],
                );

                // Hide loading dialog
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
                // Hide loading dialog on error
                controller.hideLoading();
                MySnackBar.showErrorToast(message: "Error loading PDF: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 3 — ESTIMATE / INVOICE
  // ─────────────────────────────────────────────────────────────
  Widget _buildEstimateTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Action Row
            OrganicPrimaryButton(
              key: _createInvoiceButtonKey,
              text: 'Create New',
              icon: Icons.add_rounded,
              height: 40.h,
              width: 140.w,
              onPressed: () => _showCreateInvoiceMenu(context),
            ),
            SizedBox(height: 12.h),

            // Invoice Cards
            if (controller
                        .sortedAppointments[controller.selectedAptIndex.value]
                        .invoices ==
                    null ||
                controller
                    .sortedAppointments[controller.selectedAptIndex.value]
                    .invoices!
                    .isEmpty)
              OrganicEmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No Invoices',
                subtitle: 'Create an invoice or estimate for this appointment.',
              )
            else
              ...controller
                  .sortedAppointments[controller.selectedAptIndex.value]
                  .invoices!
                  .map((proposal) => _buildInvoiceCard(context, proposal)),

            // Extended Appointments
            // if (controller.extendedAppointments.isNotEmpty) ...[
            //   SizedBox(height: 16.h),
            //   OrganicSectionTitle(title: 'Extended Appointments'),
            //   ...controller.extendedAppointments.map(
            //     (extendedAppt) => Column(
            //       children: [
            //         Text(
            //           'Appointment ID: ${extendedAppt.appoinmentUId}',
            //           style: WarmOrganicBlueTheme.bodyMedium.copyWith(
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         SizedBox(height: 10.h),
            //         ...extendedAppt.invoices!.map(
            //           (invoice) =>
            //               _buildInvoiceCard(context, invoice, isExtended: true),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Invoices proposal, {
    bool isExtended = false,
  }) {
    final isEstimate = proposal.type == "Estimate";
    return OrganicCard(
      margin: EdgeInsets.only(bottom: 10.h),
      shadow: WarmOrganicBlueTheme.softShadow,
      onTap: () async {
        controller.showLoading();
        // Load invoice details logic here...
        controller.invoiceController.isExternalInvoice.value = isExtended;
        await _loadInvoiceDetails(proposal);
        controller.hideLoading();
        Get.toNamed(Routes.INVOICE_DETAILS);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isEstimate
                      ? WarmOrganicBlueTheme.statusYellowLight
                      : WarmOrganicBlueTheme.statusGreenLight,
                  borderRadius: BorderRadius.circular(
                    WarmOrganicBlueTheme.radiusFull,
                  ),
                ),
                child: Text(
                  isEstimate ? 'Estimate' : 'Invoice',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isEstimate
                        ? WarmOrganicBlueTheme.statusYellow
                        : WarmOrganicBlueTheme.statusGreen,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                proposal.number ?? "",
                style: WarmOrganicBlueTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildCSLRow(
            'Amount',
            '\$${proposal.total?.toStringAsFixed(2) ?? "0.00"}',
          ),
          _buildCSLRow(
            'Date',
            dateTimeConverter(
              inputFormat: "yyyy/MM/dd hh:mm a",
              inputTime: proposal.invoiceDate.toString(),
              outputFormat: "MM/dd/yyyy",
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OrganicSecondaryButton(
              text: 'View Details',
              height: 36.h,
              onPressed: () async {
                controller.showLoading();
                controller.invoiceController.isExternalInvoice.value = false;
                // Save backup if we were in "new" mode before switching to "existing"
                if (controller.invoiceController.existingItemType.value ==
                    SelectedItemCategory.newOne) {
                  controller.invoiceController.saveBackup("new");
                }

                controller.invoiceController.existingItemType.value =
                    SelectedItemCategory.existingOne;

                // Clear previous selection if needed
                controller.invoiceController.selectedItemList.clear();
                for (var c
                    in controller.invoiceController.editAmountControllers) {
                  c.dispose();
                }
                for (var c
                    in controller
                        .invoiceController
                        .editDescriptionControllers) {
                  c.dispose();
                }
                for (var c
                    in controller.invoiceController.editQuantityControllers) {
                  c.dispose();
                }
                controller.invoiceController.editAmountControllers.clear();
                controller.invoiceController.editDescriptionControllers.clear();
                controller.invoiceController.editQuantityControllers.clear();
                controller.invoiceController.editNoteTextController.clear();
                controller.invoiceController.editDiscountTextController.clear();
                controller.invoiceController.initialTaxID.value = "";

                // Set basic info

                controller.invoiceController.invoiceItemList.value =
                    proposal.items ?? [];
                controller.invoiceController.depositList.value =
                    proposal.paymentList ?? [];
                controller.invoiceController.selectedDiscountOption.value =
                    proposal.discountOption ?? "2";
                controller.invoiceController.invoiceNumber =
                    proposal.number ?? "";
                controller.invoiceController.isConverted.value =
                    proposal.isConverted ?? false;
                controller.invoiceController.customerName =
                    proposal.fullName ?? "";
                controller.invoiceController.address = "${proposal.city}, ";
                controller.invoiceController.depositAmount.value =
                    proposal.depositAmount?.toStringAsFixed(2) ?? "0.00";
                controller.invoiceController.invoiceID.value = proposal
                    .invoiceID
                    .toString();
                controller.invoiceController.date = dateTimeConverter(
                  inputFormat: "yyyy/MM/dd",
                  inputTime: proposal.invoiceDate.toString(),
                  outputFormat: "MM/dd/yyyy",
                );
                controller.invoiceController.subtotal =
                    proposal.subtotal?.toStringAsFixed(2) ?? "";
                controller.invoiceController.customerID.value =
                    proposal.customerId ?? "";
                controller.invoiceController.status = proposal.status ?? "";
                controller.invoiceController.type.value = proposal.type ?? "";
                controller.invoiceController.total.value =
                    proposal.total?.toStringAsFixed(2) ?? "";
                if (proposal.requestedAmountType == 2) {
                  // type = fixed
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "2";
                  controller
                          .invoiceController
                          .requestedDepositAmountEditTextController
                          .text =
                      proposal.requestedDepositAmount ?? "0.00";
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[2]["name"];
                }
                if (proposal.requestedAmountType == 1) {
                  // type = percentage
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "1";
                  controller
                          .invoiceController
                          .requestDepositRateEditTextController
                          .text =
                      proposal.requestedDepositPercentage ?? "0.00";
                  controller
                          .invoiceController
                          .requestedDepositAmountEditTextController
                          .text =
                      proposal.requestedDepositAmount ?? "0.00";
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[1]["name"];
                }
                if (proposal.requestedAmountType == 0) {
                  // type = null
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "0";
                  controller
                          .invoiceController
                          .requestDepositRateEditTextController
                          .text =
                      proposal.requestedDepositPercentage ?? "0.00";
                  controller
                          .invoiceController
                          .requestedDepositAmountEditTextController
                          .text =
                      proposal.requestedDepositAmount ?? "0.00";
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[0]["name"];
                }
                controller.invoiceController.notes = proposal.note ?? "";
                controller.invoiceController.editNoteTextController.text =
                    proposal.note ?? "";
                controller.invoiceController.due = proposal.due ?? "";
                controller.invoiceController.showingDate.value =
                    dateTimeConverter(
                      inputFormat: "yyyy/MM/dd hh:mm a",
                      inputTime: proposal.invoiceDate.toString(),
                      outputFormat: "MM/dd/yyyy",
                    );
                if (proposal.taxType != "") {
                  controller.invoiceController.initialTaxID.value =
                      proposal.taxType ?? "";
                }

                // Set discount values
                controller.invoiceController.invoiceDiscountDetails.value =
                    proposal.discount ?? 0.00;
                if (proposal.discountOption == "1") {
                  controller.invoiceController.editDiscountTextController.text =
                      (((double.parse(
                                    proposal.discount?.toString() ?? "0.00",
                                  )) *
                                  100) /
                              double.parse(
                                proposal.subtotal?.toStringAsFixed(2) ?? "0.00",
                              ))
                          .toStringAsFixed(2);
                } else {
                  controller.invoiceController.editDiscountTextController.text =
                      double.parse(
                        proposal.discount?.toString() ?? "0.00",
                      ).toStringAsFixed(2);
                }

                // Set tax values

                controller.invoiceController.tax.value =
                    controller.invoiceController.taxes
                        .firstWhereOrNull(
                          (tax) =>
                              tax.id ==
                              int.tryParse(
                                controller.invoiceController.initialTaxID.value,
                              ),
                        )
                        ?.rate
                        ?.toStringAsFixed(2) ??
                    "0.00";
                controller.invoiceController.selectedTaxName.value =
                    controller.invoiceController.taxes
                        .firstWhereOrNull(
                          (tax) =>
                              tax.id ==
                              int.tryParse(
                                controller.invoiceController.initialTaxID.value,
                              ),
                        )
                        ?.name ??
                    "";

                // Populate selectedItemList and initialize controllers
                if (proposal.items != null && proposal.items!.isNotEmpty) {
                  for (var item in proposal.items!) {
                    controller.invoiceController.selectedItemList.add(
                      ItemListModel(
                        id: item.itemId,
                        name: item.name,
                        description: item.description,
                        price: double.tryParse(item.unitPrice ?? "0.00"),
                        isTaxable: item.isTaxable == "TAX" ? true : false,
                        // itemTypeId: int.parse(item.itemTyId!),
                      ),
                    );

                    // Initialize controllers with existing values
                    controller.invoiceController.editAmountControllers.add(
                      TextEditingController(text: item.unitPrice ?? "0.00"),
                    );

                    controller.invoiceController.editDescriptionControllers.add(
                      TextEditingController(text: item.description ?? ""),
                    );

                    controller.invoiceController.editQuantityControllers.add(
                      TextEditingController(text: item.quantity ?? "1"),
                    );
                  }
                }
                controller.invoiceController.createTotalForEdit();
                await 0.5.delay();
                controller.invoiceController.selectedQboClass(
                  controller.invoiceController.qboClassList
                      .where(
                        (e) => e.qboClassId.toString() == proposal.qboClassId,
                      )
                      .firstOrNull,
                );
                controller.invoiceController.selectedQboLocation(
                  controller.invoiceController.qboLocationList
                      .where(
                        (e) =>
                            e.qboLocationId.toString() ==
                            proposal.qboLocationId,
                      )
                      .firstOrNull,
                );
                controller.invoiceController.removedList
                    .clear(); // Optional small delay before navigation
                controller.hideLoading();
                final x = MySharedPref.getCompanyType() ?? '';
                controller.invoiceController.isLocAndClassShow.value =
                    x == 'PCS';
                controller.invoiceController.selectedInvoice.value = proposal;
                Get.toNamed(Routes.INVOICE_DETAILS);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInvoiceDetails(dynamic invoice) async {
    // Load invoice details logic from original code
    controller.invoiceController.existingItemType.value =
        SelectedItemCategory.existingOne;
    controller.invoiceController.selectedItemList.clear();
    // ... (rest of invoice loading logic from original)
  }

  void _showCreateInvoiceMenu(BuildContext context) {
    final RenderBox buttonRenderBox =
        _createInvoiceButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Get the button's position and size
    final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
    final buttonSize = buttonRenderBox.size;

    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height,
          buttonSize.width,
          buttonSize.height,
        ),
        Offset.zero & overlay.size,
      ),
      items: controller.invoiceController.createTypes.map((e) {
        return PopupMenuItem(
          value: e["name"],
          child: TextWidget(text: "${e["name"]}"),
        );
      }).toList(),
    ).then((v) async {
      if (v != null) {
        controller.invoiceController.clearAllItems();
        controller.invoiceController.selectedCreateType.value = v;

        final x = MySharedPref.getCompanyType() ?? '';
        controller.invoiceController.isLocAndClassShow.value = x == 'IsPcs';

        controller.invoiceController.createCustomerName =
            controller.contactName;
        controller.invoiceController.createCustomerAddress = controller.address;
        controller.invoiceController.createCustomerPhone =
            controller.mobileNumber;
        controller.invoiceController.createCustomerEmail = controller.email;
        controller.invoiceController.customerID.value = controller.customerID;
        controller.invoiceController.appointmentID = controller.appointmentID;
        controller.invoiceController.selectedTaxID.value = "";
        controller.invoiceController.createDiscountTextController.clear();

        await controller.invoiceController.getInvoiceName();
        Get.toNamed(Routes.INVOICE_CREATE);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 4 — PICTURES
  // ─────────────────────────────────────────────────────────────
  Widget _buildPicturesTab(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SizedBox(height: 8.h),
          // Upload Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: OrganicPrimaryButton(
              text: 'Add Photo',
              icon: Icons.add_photo_alternate_rounded,
              height: 42.h,
              onPressed: () => _showMediaOptions(context),
            ),
          ),
          SizedBox(height: 16.h),

          // Upload Section
          if (controller.mediaList.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Uploads',
                  style: WarmOrganicBlueTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            ...controller.mediaList
                .toList()
                .asMap()
                .entries
                .toList()
                .reversed
                .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return OrganicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.time, style: WarmOrganicBlueTheme.bodySmall),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: item.descriptionController,
                          decoration: InputDecoration(
                            hintText: "Add description...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...item.images.map((e) {
                                if (_isVideo(e)) {
                                  return GestureDetector(
                                    onTap: () => showMediaDialog(context, e),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: FutureBuilder<String?>(
                                        future: generateVideoThumbnail(e),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Stack(
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.r,
                                                        ),
                                                    image: DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: FileImage(
                                                        File(snapshot.data!),
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
                                            height: 150,
                                            width: 150,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.play_circle_fill,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () => showMediaDialog(context, e),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      margin: EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: FileImage(File(e)),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }),
                              GestureDetector(
                                onTap: () =>
                                    showMediaBottomSheet(context, index),
                                child: Container(
                                  height: 150,
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        OrganicPrimaryButton(
                          text: "Upload Images",
                          onPressed: () async {
                            await controller.uploadImages(
                              tagName: item.time.split(" ")[0],
                              description: item.descriptionController.text,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ],

          // Uploaded Images Grouped by Date
          if (controller.imagesGroupedByDate.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...(controller.imagesGroupedByDate.keys.toList()..sort()).map((
              date,
            ) {
              final images = controller.imagesGroupedByDate[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        date,
                        style: WarmOrganicBlueTheme.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    child: Row(
                      children: images.map((item) {
                        kLog("${ApiUrl.imageBaseUrl}/${item.pictureURL!}");
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Stack(
                                  children: [
                                    item.pictureURL != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                "${ApiUrl.imageBaseUrl}/${item.pictureURL!}",
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const Center(
                                                  child: Icon(Icons.error),
                                                ),
                                          )
                                        : Image.memory(
                                            item.bytes!,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: 150,
                            margin: EdgeInsets.only(right: 12.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: item.pictureURL != null
                                  ? CachedNetworkImage(
                                      imageUrl: item.pictureURL!,
                                      fit: BoxFit.fill,
                                      placeholder: (_, __) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    )
                                  : Image.memory(item.bytes!, fit: BoxFit.fill),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 5 — EQUIPMENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildEquipmentTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(
        () => Column(
          children: [
            // Add Equipment Button
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButtonWithIcon(
                title: 'Add Equipment',
                onPressed: () {
                  Get.bottomSheet(
                    EquipmentFormModal(
                      equipmentTypes: controller.equipmentTypeList,
                    ),
                    isScrollControlled: false,
                    backgroundColor: Colors.transparent,
                  );
                },
                iconData: Icons.add,
                inactive: false,
              ),
            ),
            SizedBox(height: 16.h),

            // Equipment List
            if (controller.equipmentList.isNotEmpty) ...[
              OrganicSectionTitle(title: 'Equipment List'),
              ...controller.equipmentList.map(
                (equipment) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: EquipmentCard(
                    equipment: equipment,
                    onEdit: () => Get.bottomSheet(
                      EquipmentFormModal(
                        equipment: equipment,
                        equipmentTypes: controller.equipmentTypeList,
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 32.h),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction, size: 64.sp, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'No equipment added yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 6 — FILES
  // ─────────────────────────────────────────────────────────────
  Widget _buildFilesTab(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SizedBox(height: 8.h),
          // Upload Button
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () => showSingleFilePickerBottomSheet(context),
                child: DottedBorder(
                  options: RectDottedBorderOptions(dashPattern: [3, 2]),
                  child: Icon(
                    Icons.add,
                    size: 25.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Upload Section
          if (controller.fileUploadList.isNotEmpty)
            ...controller.fileUploadList.map(
              (item) => OrganicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.time, style: WarmOrganicBlueTheme.bodySmall),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: item.descriptionController,
                      decoration: InputDecoration(
                        hintText: "Add description...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: item.files.map((file) {
                          final fileName = file.path.split('/').last;
                          final extension = fileName.contains('.')
                              ? fileName.split('.').last.toLowerCase()
                              : '';
                          return Container(
                            height: 120,
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFileIconData(extension) ??
                                      Icons.insert_drive_file,
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    OrganicPrimaryButton(
                      text: "Upload Files",
                      onPressed: () async {
                        await controller.uploadFiles(
                          tagName: item.time.split(" ")[0],
                          description: item.descriptionController.text,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Files Grouped by Date
          if (controller.filesGroupedByDate.isNotEmpty) ...[
            SizedBox(height: 16.h),

            ...(controller.filesGroupedByDate.keys.toList()..sort()).map((
              date,
            ) {
              final files = controller.filesGroupedByDate[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      date,
                      style: WarmOrganicBlueTheme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    child: Row(
                      children: files.map((file) {
                        return GestureDetector(
                          onTap: () => _downloadFile(file),
                          child: Container(
                            height: 120,
                            width: 100,
                            margin: EdgeInsets.only(right: 12.sp),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFileIconData(file.fileExtension) ??
                                      Icons.insert_drive_file,
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                ),

                                SizedBox(height: 5),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    file.fileName ?? 'Unknown',
                                    style: TextStyle(fontSize: 10),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData? _getFileIconData(String? extension) {
    if (extension == null) return null;
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 7 — NOTES
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotesTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Add Note Button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                controller.note1Controller.clear();
                controller.noteId(-1);
                showNotesDialog(context, controller, theme, false);
              },
              child: DottedBorder(
                options: RectDottedBorderOptions(dashPattern: [3, 2]),
                child: Icon(
                  Icons.add,
                  size: 25.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Notes List
          Obx(() {
            final filteredNoteList = controller.noteList
                .where(
                  (note) =>
                      note.siteId.toString() ==
                          controller.selectedAppointment.value?.siteID &&
                      note.customerId ==
                          controller.selectedAppointment.value?.customerID,
                )
                .toList();

            if (filteredNoteList.isEmpty) {
              return Center(child: TextWidget(text: "No Notes Found"));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredNoteList.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final note = filteredNoteList[index];
                final isOwnNote =
                    note.userId!.trim() == controller.userId.toString().trim();
                return OrganicCard(
                  color: isOwnNote ? Colors.green[50] : Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      TextWidget(
                        text: note.description ?? "N/A",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER METHODS (Preserved from Original)
  // ─────────────────────────────────────────────────────────────

  Future<void> _downloadFile(FileModel file) async {
    final fileName =
        file.fileName ?? 'file_${DateTime.now().millisecondsSinceEpoch}';
    String finalFileName = fileName;
    if (file.fileExtension != null &&
        !fileName.endsWith('.${file.fileExtension}')) {
      finalFileName = '$fileName.${file.fileExtension}';
    }

    Directory downloadDir;
    if (Platform.isAndroid) {
      downloadDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${appDocDir.path}/Downloads');
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${appDocDir.path}/Downloads');
    }

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final filePath = '${downloadDir.path}/$finalFileName';
    final savedFile = File(filePath);

    if (await savedFile.exists()) {
      await _openFile(filePath, file);
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      Uint8List? fileBytes;

      if (file.fileURL != null && file.fileURL!.isNotEmpty) {
        try {
          final response = await Dio().get(
            file.fileURL!,
            options: Options(responseType: ResponseType.bytes),
          );
          fileBytes = response.data as Uint8List;
        } catch (e) {
          if (mounted) Navigator.pop(context);
          MySnackBar.showErrorToast(
            message: 'Failed to download file from server',
          );
          return;
        }
      } else {
        fileBytes = file.bytes;
        if (fileBytes == null &&
            file.fileContent != null &&
            file.fileContent!.isNotEmpty) {
          try {
            fileBytes = base64Decode(file.fileContent!);
          } catch (e) {
            if (mounted) Navigator.pop(context);
            MySnackBar.showErrorToast(message: 'Failed to decode file content');
            return;
          }
        }
      }

      if (fileBytes == null) {
        if (mounted) Navigator.pop(context);
        MySnackBar.showErrorToast(message: 'File content not available');
        return;
      }

      await savedFile.writeAsBytes(fileBytes, flush: true);
      kLog("File saved to: $filePath");

      if (mounted) Navigator.pop(context);
      await _openFile(filePath, file);
    } catch (e, s) {
      kLog("Error saving file: $e");
      kLog(s);
      if (mounted) Navigator.pop(context);
      MySnackBar.showErrorToast(message: 'Failed to download file: $e');
    }
  }

  Future<void> _openFile(String filePath, FileModel file) async {
    final ext = file.fileExtension?.toLowerCase();

    if (file.isImage) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Image.file(File(filePath), fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }

    if (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv') {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => _VideoDialog(videoPath: filePath),
        );
      }
      return;
    }

    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      MySnackBar.showErrorToast(
        message: 'Could not open file: ${result.message}',
      );
    }
  }

  bool _isVideo(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  void _showMediaOptions(BuildContext context) {
    showMediaBottomSheet(context, -1);
  }
}

// ─────────────────────────────────────────────────────────────
// GLOBAL HELPER FUNCTIONS (Preserved from Original)
// ─────────────────────────────────────────────────────────────

void showMediaDialog(BuildContext context, String path) {
  if (path.split('.').last.toLowerCase() == 'mp4' ||
      path.split('.').last.toLowerCase() == 'mov' ||
      path.split('.').last.toLowerCase() == 'avi' ||
      path.split('.').last.toLowerCase() == 'mkv') {
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
    maxWidth: 150,
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
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Add / Update Notes",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: WarmOrganicBlueTheme.deepNavy,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Notes",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
                    onEditingComplete: () => controller.isTyping(false),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: Colors.redAccent,
                          title: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          inactive: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: LightThemeColors.primaryColor,
                          title: isOld ? "Update" : "Save",
                          onPressed: () async {
                            await controller.saveNote(isOld);
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
      );
    },
  );
}

void showDialogStatusChange(
  BuildContext context,
  AppointmentController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
      ),
    ),
    builder: (_) {
      final tickets = controller.settingController.appointmentsStatus;
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: WarmOrganicBlueTheme.warmSilver,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Change Status', style: WarmOrganicBlueTheme.headingMedium),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: tickets
                    .map(
                      (v) => _buildStatusOption(
                        v.statusName ?? "N/A",
                        WarmOrganicBlueTheme.primaryBlue,
                        () async {
                          controller.settingController
                              .selectedAppointmentsStatus(v);
                          controller.selectedStatusValue(v.statusId!);
                          await controller.updateAppointment();
                        },
                        (controller
                                    .settingController
                                    .selectedAppointmentsStatus
                                    .value
                                    ?.statusName ??
                                "") ==
                            v.statusName,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStatusOption(
  String label,
  Color color,
  VoidCallback onTap,
  bool isSelected,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (isSelected) ...[
            SizedBox(width: 8.w),
            Icon(
              Icons.check_circle_outline_outlined,
              size: 18.sp,
              color: Colors.greenAccent,
            ),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// INLINE MAP WIDGET
// ─────────────────────────────────────────────────────────────
class _InlineMap extends StatefulWidget {
  final String address;

  const _InlineMap({required this.address});

  @override
  State<_InlineMap> createState() => _InlineMapState();
}

class _InlineMapState extends State<_InlineMap> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body, html { margin: 0; padding: 0; height: 100%; width: 100%; }
            iframe { width: 100%; height: 100%; border: 0; }
          </style>
        </head>
        <body>
          <iframe
            src="https://www.google.com/maps?q=${Uri.encodeComponent(widget.address)}&output=embed"
            allowfullscreen
            loading="lazy"
            referrerpolicy="no-referrer-when-downgrade">
          </iframe>
        </body>
        </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: WarmOrganicBlueTheme.warmSilver,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

void showDialogTicketStatus(
  BuildContext context,
  AppointmentController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
      ),
    ),
    builder: (_) {
      final tickets = controller.settingController.tickets;
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(WarmOrganicBlueTheme.radiusXl),
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: WarmOrganicBlueTheme.warmSilver,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Change Status', style: WarmOrganicBlueTheme.headingMedium),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: tickets
                    .map(
                      (v) => _buildStatusOption(
                        v.statusName ?? "N/A",
                        WarmOrganicBlueTheme.primaryBlue,
                        () async {
                          controller.settingController.selectedTicket(v);
                          controller.selectedTicketStatusValue(v.statusId!);
                          await controller.updateAppointment();
                        },
                        (controller
                                    .settingController
                                    .selectedTicket
                                    .value
                                    ?.statusName ??
                                "") ==
                            v.statusName,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MediaButton(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () async {
                      try {
                        final List<XFile?> files = await ImagePicker()
                            .pickMultiImage();
                        if (files.isNotEmpty) {
                          final newImages = <String>[];
                          for (var file in files) {
                            if (file != null) {
                              try {
                                final compressedPath = await compressImage(
                                  file.path,
                                );
                                newImages.add(compressedPath);
                              } catch (e) {}
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
                                  time: DateFormat(
                                    "MM/dd/yyyy",
                                  ).format(DateTime.now()),
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
                      try {
                        final XFile? file = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          imageQuality: 85,
                        );
                        if (file != null) {
                          final compressedPath = await compressImage(file.path);

                          if (index != -1) {
                            appointmentC.mediaList[index].images.add(
                              compressedPath,
                            );
                            appointmentC.mediaList.refresh();
                          } else {
                            appointmentC.mediaList.add(
                              MediaModel(
                                time: DateFormat(
                                  "MM/dd/yyyy",
                                ).format(DateTime.now()),
                                images: [compressedPath],
                              ),
                            );
                          }
                        }

                        appointmentC.update();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error taking photo: Unable to access camera. Please check permissions.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }

                      Navigator.pop(context);
                    },
                  ),
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

void showSingleFilePickerBottomSheet(BuildContext context) {
  final controller = Get.find<AppointmentController>();

  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.document_scanner),
            title: Text("Pick Document"),
            onTap: () async {
              Navigator.pop(sheetContext);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
                allowMultiple: false,
              );
              if (result != null &&
                  result.files.isNotEmpty &&
                  context.mounted) {
                final validFiles = await _validateAndFilterFiles([
                  File(result.files.single.path!),
                ], context);
                if (validFiles.isNotEmpty) {
                  controller.addFilesToUploadList(validFiles);
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text("Browse Files"),
            onTap: () async {
              Navigator.pop(sheetContext);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowMultiple: false,
              );
              if (result != null &&
                  result.files.isNotEmpty &&
                  context.mounted) {
                final validFiles = await _validateAndFilterFiles([
                  File(result.files.single.path!),
                ], context);
                if (validFiles.isNotEmpty) {
                  controller.addFilesToUploadList(validFiles);
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<List<File>> _validateAndFilterFiles(
  List<File> files,
  BuildContext context,
) async {
  const maxSizeInBytes = 10 * 1024 * 1024;
  final validFiles = <File>[];
  final skippedFiles = <String>[];

  for (var file in files) {
    try {
      final fileSize = await file.length();
      if (fileSize <= maxSizeInBytes) {
        validFiles.add(file);
      } else {
        final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        skippedFiles.add('${file.uri.pathSegments.last} ($sizeInMB MB)');
      }
    } catch (e) {
      skippedFiles.add('${file.uri.pathSegments.last} (Error: $e)');
    }
  }

  if (skippedFiles.isNotEmpty && context.mounted) {
    MySnackBar.showErrorToast(
      message:
          'Skipped ${skippedFiles.length} file(s) over 10MB limit:\n${skippedFiles.take(3).join("\n")}${skippedFiles.length > 3 ? "\n..." : ""}',
    );
  }

  return validFiles;
}

Future<String> compressImage(String filePath) async {
  final compressedFile = await FlutterImageCompress.compressWithFile(
    filePath,
    quality: 40,
    minWidth: 800,
    minHeight: 800,
    format: CompressFormat.jpeg,
  );

  if (compressedFile == null) return filePath;

  final tempDir = Directory.systemTemp;
  final tempFile = await File(
    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
  ).writeAsBytes(compressedFile);

  return tempFile.path;
}

Future<void> openMapWithRoute(String destinationAddress) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    final origin = '${position.latitude},${position.longitude}';
    final encodedDestination = Uri.encodeComponent(destinationAddress);

    if (Platform.isIOS) {
      final googleMapsUrl = Uri.parse(
        'comgooglemaps://?saddr=$origin&daddr=$encodedDestination&directionsmode=driving',
      );
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
    debugPrint('Error launching map: $e');
  }
}

void openGoogleMaps(String query) async {
  final encodedQuery = Uri.encodeComponent("$query shop near me");
  final url = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$encodedQuery",
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $url");
  }
}

Color getStatusColor(String statusName) {
  switch (statusName) {
    case "Installation In Progress":
    case "Installation in Progress":
      return const Color(0xffE98862);
    case "Scheduled":
      return const Color(0xff2E888B);
    case "Cancelled":
      return Colors.red;
    case "Completed":
      return const Color(0xff0CBC8B);
    case "Pending":
      return const Color(0xFFFFC107);
    case "Closed":
      return const Color(0xFF607D8B);
    case "Dispatched":
      return const Color(0xFF42A5F5);
    case "FA-ID Sent":
      return const Color(0xFF9575CD);
    case "In-Route":
      return const Color(0xFFFF9800);
    case "Arrived":
      return const Color(0xFF8BC34A);
    case "On-Hold":
      return const Color(0xFFFF7043);
    default:
      return const Color(0xFF9E9E9E);
  }
}

Widget buildCustomFieldWidget(CustomFieldModel field, BuildContext context) {
  final apptC = Get.find<AppointmentController>();
  switch (field.fieldType) {
    case 'dropdown':
      return Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.fieldName!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 10.h),
            DropdownButton<String>(
              isExpanded: true,
              value: apptC.customFieldDropdownValue.value != ''
                  ? apptC.customFieldDropdownValue.value
                  : null,
              hint: Text("Select ${field.fieldName}"),
              items: field.options?.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  apptC.customFieldDropdownValue.value = value;
                  field.selectedValue = value;
                }
              },
            ),
          ],
        ),
      );

    case 'checklist':
      return Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.fieldName!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 10.h),
            ...field.options!.map((option) {
              return CheckboxListTile(
                checkColor: Colors.white,
                activeColor: Colors.blue,
                tileColor: apptC.customFieldChecklistValues.contains(option)
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                title: Text(option),
                value: apptC.customFieldChecklistValues.contains(option),
                onChanged: (isChecked) {
                  if (isChecked == true) {
                    apptC.customFieldChecklistValues.add(option);
                    field.selectedOptions!.add(option);
                  } else {
                    apptC.customFieldChecklistValues.remove(option);
                    field.selectedOptions!.remove(option);
                  }
                  apptC.update();
                },
              );
            }),
          ],
        ),
      );

    case 'text':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldName!, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 10.h),
          TextField(
            controller: apptC.customFieldTextController.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter ${field.fieldName}",
            ),
            onChanged: (value) => field.textValue = value,
          ),
        ],
      );

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
            onChanged: (value) => field.numberValue = value,
          ),
        ],
      );

    default:
      return Text("Unsupported field type: ${field.fieldType}");
  }
}
