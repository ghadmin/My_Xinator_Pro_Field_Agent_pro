import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/utils/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ─── Warm Organic Blue Design ───────────────────────────────────
import '../../../utils/simple_phone_formatter.dart';
import '../models/custom_field_model.dart';
import 'widgets/warm_organic_components.dart';
// ───────────────────────────────────────────────────────────────────
import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/klog.dart';
import '../../../../utils/responsive.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../../../components/signature/signature_dialog.dart';
import '../../../modules/forms/controllers/forms_controller.dart';
import '../../../routes/app_pages.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/custom_fields_controller.dart';
import '../parts/image/controllers/image_controller.dart';
import '../parts/file/controllers/file_controller.dart';
import '../parts/notes/controllers/notes_controller.dart';
import '../parts/equipment/controllers/equipment_controller.dart';

// ─── Appointment Details palette ────────────────────────────────
// One indigo accent; semantic colors are reserved for status only.
class _AppPalette {
  _AppPalette._();

  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF4F46E5);
  static const Color primarySoft = Color(0xFFEEF0FF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE8F7EE);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFE8F0FE);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3E2);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color neutral = Color(0xFF6B7280);
  static const Color neutralSoft = Color(0xFFF3F4F6);

  /// Very light shadow used on white cards.
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A111827), // textPrimary @ 4%
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

/// Foreground + soft background pair for a status pill.
class _StatusStyle {
  final Color fg;
  final Color bg;
  const _StatusStyle(this.fg, this.bg);
}

class AppointmentDetailsView extends StatefulWidget {
  const AppointmentDetailsView({super.key});

  @override
  State<AppointmentDetailsView> createState() => _AppointmentDetailsViewState();
}

class _AppointmentDetailsViewState extends State<AppointmentDetailsView>
    with TickerProviderStateMixin {
  FormsController? formsController;
  @override
  void initState() {
    super.initState();

    // Controllers are now registered via AppointmentBinding
    // Using Get.find() to get the lazy-loaded instances
    imageController = Get.find<ImageController>();
    fileController = Get.find<FileController>();
    notesController = Get.find<NotesController>();

    // Check if FormsController exists, if not create it
    if (Get.isRegistered<FormsController>()) {
      formsController = Get.find<FormsController>();
    } else {
      log("Creating new FormsController");
      formsController = Get.put(FormsController());
    }

    // _tabController = TabController(length: 7, vsync: this);
    // _tabController.addListener(() {
    //   if (_tabController.indexIsChanging) return;
    //   if (_tabController.index == _previousTabIndex) return;

    //   _previousTabIndex = _tabController.index;
    //   kLog("tabController index: ${_tabController.index}");

    //   // Navigate to dedicated pages
    //   if (_tabController.index == 0) {
    //     // CSL - Navigate to CSL view
    //     controller.getCustomerSite(showLoader: true);
    //     Future.delayed(Duration(seconds: 7));
    //     controller.isBasicExpanded(true);
    //     setState(() {});
    //   }
    //   if (_tabController.index == 1) {
    //     // Forms - Navigate to Forms page
    //     Get.toNamed(Routes.FORMS);
    //     // Reset to CSL tab after navigation
    //     Future.delayed(Duration(milliseconds: 500), () {
    //       if (_tabController.index == 1) {
    //         _tabController.animateTo(0);
    //       }
    //     });
    //   }
    //   if (_tabController.index == 2) {
    //     // Estimate - Navigate to Invoice page
    //     controller.getInvoiceList(showLoader: true);
    //     setState(() {});
    //   }
    //   if (_tabController.index == 3) {
    //     // Pictures - Navigate to pictures page (if exists)
    //     final appointment = controller.selectedAppointment.value;
    //     if (appointment != null) {
    //       imageController.fetchPictures(
    //         customerId: appointment.customerID?.toString() ?? '',
    //         siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
    //       );
    //     }
    //     setState(() {});
    //   }
    //   if (_tabController.index == 4) {
    //     // Equipment - Show equipment section
    //     controller.getCustomerSite(showLoader: true);
    //     final appointment = controller.selectedAppointment.value;
    //     if (appointment != null) {
    //       equipmentController.fetchEquipment(
    //         customerGuid: appointment.customer?.customerGuid ?? '',
    //         siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
    //         companyId: appointment.companyID,
    //       );
    //       equipmentController.fetchEquipmentTypes(
    //         companyId: appointment.companyID,
    //       );
    //     }
    //     setState(() {});
    //   }
    //   if (_tabController.index == 5) {
    //     // Files - Show files section
    //     final appointment = controller.selectedAppointment.value;
    //     if (appointment != null) {
    //       fileController.fetchFiles(
    //         customerId: appointment.customerID?.toString() ?? '',
    //         siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
    //       );
    //     }
    //     setState(() {});
    //   }
    //   if (_tabController.index == 6) {
    //     // Notes - Show notes section
    //     final appointment = controller.selectedAppointment.value;
    //     if (appointment != null) {
    //       notesController.fetchNotes(
    //         customerId: appointment.customerID?.toString() ?? '',
    //         siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
    //         companyId: appointment.companyID,
    //       );
    //     }
    //     setState(() {});
    //   }
    // });
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  final AppointmentController controller = Get.find<AppointmentController>();
  final CustomFieldsController customFieldsController =
      Get.find<CustomFieldsController>();
  late final ImageController imageController;
  late final FileController fileController;
  late final NotesController notesController;
  final EquipmentController equipmentController =
      Get.find<EquipmentController>();

  // ─────────────────────────────────────────────────────────────
  // MAIN BUILD — REDESIGNED WITH WARM ORGANIC BLUE THEME
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final baseTheme = WarmOrganicBlueTheme.themeData;
    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: _AppPalette.primary,
          secondary: _AppPalette.primary,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: Get.size.width <= 440 || context.isTabletLayout
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
                        style: baseTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

        backgroundColor: _AppPalette.background,
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
                          child: ResponsiveCenter(
                            maxWidth: 900,
                            child: Column(
                              children: [
                                // _buildGradientHeader(context),
                                _buildTimeCard(),
                                // _buildGradientHeader(context),
                                SizedBox(height: 5.h),

                                // Notes Card
                                OrganicCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Any Details',
                                        style: WarmOrganicBlueTheme.headingSmall
                                            .copyWith(
                                              color: _AppPalette.textPrimary,
                                            ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(14.r),
                                        decoration: BoxDecoration(
                                          color: _AppPalette.background,
                                          borderRadius: BorderRadius.circular(
                                            WarmOrganicBlueTheme.radiusMd,
                                          ),
                                        ),
                                        child: GeneralTextField(
                                          maxLine: 4,
                                          hint: "Add a note here..",
                                          theme: Theme.of(context),
                                          textEditingController:
                                              controller.noteController,
                                          textInputAction:
                                              TextInputAction.newline,
                                          textInputType:
                                              TextInputType.multiline,
                                          onChanged: (v) {
                                            controller.isTyping(true);
                                            controller.noteText(v);
                                          },
                                          onEditingComplete: () =>
                                              controller.isTyping(false),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      OrganicPrimaryButton(
                                        text: 'Save Notes',
                                        height: 43.h,
                                        color: _AppPalette.primary,
                                        onPressed: () async => await controller
                                            .updateAppointment(),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Custom Fields Card
                                OrganicCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Custom Fields',
                                        style:
                                            WarmOrganicBlueTheme.headingSmall,
                                      ),
                                      SizedBox(height: 12.h),
                                      DropdownButton<CustomFieldModel>(
                                        isExpanded: true,
                                        icon: Icon(
                                          Icons.add,
                                          color: _AppPalette.primary,
                                        ),
                                        value: null,
                                        items: customFieldsController
                                            .allCustomFields
                                            .map((field) {
                                              return DropdownMenuItem<
                                                CustomFieldModel
                                              >(
                                                value: field,
                                                child: Text(
                                                  field.fieldName!,
                                                  softWrap: true,
                                                ),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (value) {
                                          kLog("value: ${value?.fieldName}");
                                          if (value != null) {
                                            customFieldsController
                                                .saveCustomField(value);
                                          }
                                        },
                                      ),
                                      SizedBox(height: 12.h),
                                      Obx(
                                        () => ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: customFieldsController
                                              .selectedCustomFields
                                              .length,
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                                color: _AppPalette.border,
                                                thickness: 1,
                                                height: 24.h,
                                              ),
                                          itemBuilder: (context, index) {
                                            final field = customFieldsController
                                                .selectedCustomFields[index];
                                            return Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 30.w,
                                                  ),
                                                  child: buildCustomFieldWidget(
                                                    field,
                                                    context,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final ok =
                                                          await _confirmRemoveField(
                                                            context,
                                                          );
                                                      if (!ok) return;
                                                      await customFieldsController
                                                          .deleteAppointmentCustomField(
                                                            appointmentId:
                                                                controller
                                                                    .selectedAppointment
                                                                    .value!
                                                                    .apptID,
                                                            fieldId:
                                                                field.fieldID ??
                                                                0,
                                                          );
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        8.r,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: _AppPalette
                                                            .textSecondary,
                                                        size: 20.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Obx(
                                        () =>
                                            customFieldsController
                                                .selectedCustomFields
                                                .isNotEmpty
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  top: 12.h,
                                                ),
                                                child: OrganicPrimaryButton(
                                                  text: "Save Custom Fields",
                                                  onPressed: () async {
                                                    await customFieldsController
                                                        .saveAttachedCustomFields(
                                                          appointmentId: controller
                                                              .selectedAppointment
                                                              .value!
                                                              .apptID,
                                                        );
                                                  },
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                _buildTabsGrid(),
                                SizedBox(height: 70.h),
                              ],
                            ),
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

  // Helper function to calculate comprehensive duration between start and end dates
  String _calculateDuration() {
    try {
      if (controller.startDate.isNotEmpty && controller.endDate.isNotEmpty) {
        final startDateTime = DateFormat(
          'MM/dd/yyyy hh:mm a',
        ).parse(controller.startDate);
        final endDateTime = DateFormat(
          'MM/dd/yyyy hh:mm a',
        ).parse(controller.endDate);

        final duration = endDateTime.difference(startDateTime);
        final totalMinutes = duration.inMinutes;

        // Calculate all time units
        final years = totalMinutes ~/ (365 * 24 * 60);
        final remainingAfterYears = totalMinutes % (365 * 24 * 60);

        final months = remainingAfterYears ~/ (30 * 24 * 60);
        final remainingAfterMonths = remainingAfterYears % (30 * 24 * 60);

        final weeks = remainingAfterMonths ~/ (7 * 24 * 60);
        final remainingAfterWeeks = remainingAfterMonths % (7 * 24 * 60);

        final days = remainingAfterWeeks ~/ (24 * 60);
        final remainingAfterDays = remainingAfterWeeks % (24 * 60);

        final hours = remainingAfterDays ~/ 60;
        final minutes = remainingAfterDays % 60;

        // Build the duration string showing only non-zero units
        List<String> parts = [];

        if (years > 0) {
          parts.add('$years Year${years > 1 ? 's' : ''}');
        }
        if (months > 0) {
          parts.add('$months Month${months > 1 ? 's' : ''}');
        }
        if (weeks > 0) {
          parts.add('$weeks Week${weeks > 1 ? 's' : ''}');
        }
        if (days > 0) {
          parts.add('$days Day${days > 1 ? 's' : ''}');
        }
        if (hours > 0) {
          parts.add('$hours Hr');
        }
        if (minutes > 0 || parts.isEmpty) {
          parts.add('$minutes Min');
        }

        // Join all parts with spaces
        return parts.join(' ');
      }
    } catch (e) {
      kLog('Error calculating duration: $e');
    }
    return 'N/A';
  }

  /// Full site address (street, city, state, zip, country), falling back to
  /// the customer's address when the site has none. Empty parts are skipped.
  String _buildFullAddress() {
    final site = controller.selectedSite.value;
    final customer = controller.selectedAppointment.value?.customer;
    final parts =
        [
              site?.address ?? customer?.address1,
              site?.city ?? customer?.city,
              site?.state ?? customer?.state,
              site?.zip ?? customer?.zipCode,
              site?.country,
            ]
            .where((p) => p != null && p.trim().isNotEmpty)
            .map((p) => p!.trim())
            .toList();
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  /// Confirmation dialog for removing an attached custom field.
  Future<bool> _confirmRemoveField(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Remove field?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _AppPalette.textPrimary,
          ),
        ),
        content: Text(
          'This custom field will be removed from this appointment.',
          style: TextStyle(fontSize: 13.sp, color: _AppPalette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: _AppPalette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Remove',
              style: TextStyle(
                color: _AppPalette.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildTimeCard() {
    // Parse the start date to get time and date information
    String displayTime = 'N/A';
    String displayDate = '';

    try {
      if (controller.startDate.isNotEmpty) {
        final dateTime = DateFormat(
          'MM/dd/yyyy hh:mm a',
        ).parse(controller.startDate);
        displayTime = DateFormat('hh:mm a').format(dateTime);
        displayDate = DateFormat('MMM dd, yyyy').format(dateTime);
      }
    } catch (e) {
      kLog('Error parsing start date: $e');
    }

    final customerName =
        controller.selectedAppointment.value?.customer?.businessName ??
        controller.contactName;

    // Site details (same fields the web CSL page shows)
    final site = controller.selectedSite.value;
    final siteContact = [
      site?.firstName,
      site?.lastName,
    ].where((p) => (p ?? '').trim().isNotEmpty).map((p) => p!.trim()).join(' ');
    final siteStatus = site == null
        ? ''
        : (site.isActive == true ? 'Active' : 'Inactive');
    final siteCreatedOn =
        formatLastUpdatedDate(site?.createdDateTime)?.split(' ').first ?? '';
    final specialInstructions = site?.note ?? '';

    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: _AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppPalette.border),
        boxShadow: _AppPalette.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time section — time, then date, then Appt ID stacked in a column
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTime,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _AppPalette.textPrimary,
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _AppPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                // Appt ID below the date
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _AppPalette.primarySoft,
                    borderRadius: BorderRadius.circular(
                      WarmOrganicBlueTheme.radiusSm,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fingerprint_rounded,
                        size: 12,
                        color: _AppPalette.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Appt ID: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _AppPalette.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text:
                                    controller
                                        .selectedAppointment
                                        .value
                                        ?.appoinmentUId
                                        ?.toString() ??
                                    'N/A',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _AppPalette.primary,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status Badges Row
          Obx(() {
            final apptStatus =
                controller
                    .settingController
                    .selectedAppointmentsStatus
                    .value
                    ?.statusName ??
                "";
            final ticketStatus =
                controller.settingController.selectedTicket.value?.statusName;
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showDialogStatusChange(context, controller),
                    child: _buildCompactStatusBadge(
                      apptStatus.isNotEmpty ? apptStatus : "N/A",
                      _getStatusStyle(apptStatus),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showDialogTicketStatus(context, controller),
                    child: _buildCompactStatusBadge(
                      'Ticket: ${ticketStatus?.isNotEmpty == true ? ticketStatus : "N/A"}',
                      _getTicketStyle(ticketStatus),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: _AppPalette.border),
          const SizedBox(height: 12),

          // Customer row
          GestureDetector(
            onTap: () async {
              // controller.showLoading();
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
              // controller.hideLoading();
              Get.toNamed(Routes.CUSTOMER_DETAILS);
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName.isNotEmpty ? customerName : 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _AppPalette.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      // Site (CSL) name shown under the customer name

                      // Padding(
                      //   padding: const EdgeInsets.only(top: 3),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Icon(
                      //         Icons.location_on_outlined,
                      //         size: 13,
                      //         color: Color(0xFF8E8E93),
                      //       ),
                      //       const SizedBox(width: 3),
                      //       Flexible(
                      //         child: Text(
                      //           controller.selectedSite.value!.siteName ?? "",
                      //           style: const TextStyle(
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xFF8E8E93),
                      //           ),
                      //           maxLines: 1,
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _AppPalette.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: _AppPalette.border),
          const SizedBox(height: 12),

          // Appointment Info Tiles - 2 columns
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.play_circle_outline_rounded,
                  'Start Date',
                  controller.startDate,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.access_time_rounded,
                  'Duration',
                  _calculateDuration(),
                ),
              ),
            ],
          ),
          // SizedBox(height: 8.h),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildCompactInfoTile(
          //         Icons.calendar_today_rounded,
          //         'Request Date',
          //         controller.requestDate,
          //       ),
          //     ),
          //     SizedBox(width: 12.w),
          //     Expanded(
          //       child: _buildCompactInfoTile(
          //         Icons.play_circle_outline_rounded,
          //         'Start Date',
          //         controller.startDate,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 8.h),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildCompactInfoTile(
          //         Icons.stop_circle_outlined,
          //         'End Date',
          //         controller.endDate,
          //       ),
          //     ),
          //     SizedBox(width: 12.w),
          //     Expanded(
          //       child: _buildCompactInfoTile(
          //         Icons.access_time_rounded,
          //         'Duration',
          //         _calculateDuration(),
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.schedule_rounded,
                  'Time Slot',
                  controller.timeSlot,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.person_rounded,
                  'Resource',
                  controller.selectedAppointment.value?.resource?.name ?? "N/A",
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Divider — separator between appointment info and site section
          Container(height: 1, color: _AppPalette.border),
          const SizedBox(height: 12),

          // Site section — service type chip
          if (controller.serviceType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _AppPalette.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.miscellaneous_services_rounded,
                        size: 11,
                        color: _AppPalette.primary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          controller.serviceType,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _AppPalette.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.person_rounded,
                  'Site Contact',
                  siteContact,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCompactInfoTile(
                  siteStatus == 'Active'
                      ? Icons.check_circle_outline_rounded
                      : Icons.do_not_disturb_on_outlined,
                  'Status',
                  siteStatus,
                  iconColor: siteStatus == 'Active'
                      ? _AppPalette.success
                      : _AppPalette.neutral,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.event_rounded,
                  'Created On',
                  siteCreatedOn,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(), // Empty spacer to maintain 2-column layout
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoTile(
                  Icons.sticky_note_2_rounded,
                  'Special Instructions',
                  specialInstructions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: _AppPalette.border),
          const SizedBox(height: 12),

          // Contact Info Chips
          Row(
            children: [
              Expanded(
                child: _buildContactChip(
                  Icons.location_on_rounded,
                  _buildFullAddress(),
                  () async {
                    try {
                      await controller.initializeWebController();
                      if (context.mounted) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
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
                                                    BorderRadius.circular(
                                                      12.sp,
                                                    ),
                                                child: WebViewWidget(
                                                  controller:
                                                      controller.webController!,
                                                ),
                                              ),
                                              if (controller.isLoading.value)
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            _AppPalette.primary,
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
                      }
                    } catch (e) {
                      MySnackBar.showErrorToast(message: e.toString());
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Column(
            children: [
              _buildContactChip(
                Icons.phone_rounded,
                controller.selectedSite.value?.phoneNumber
                            .toString()
                            .isNotEmpty ??
                        false
                    ? PhoneDisplayFormatter.format(
                        controller.selectedSite.value!.phoneNumber,
                      )
                    : controller.selectedAppointment.value?.customer?.phone
                              .toString()
                              .isNotEmpty ??
                          false
                    ? PhoneDisplayFormatter.format(
                        controller.selectedAppointment.value!.customer!.phone,
                      )
                    : 'N/A',
                () async {
                  try {
                    await UrlLauncher.phoneCall(
                      controller.mobileNumber.isNotEmpty
                          ? controller.mobileNumber
                          : controller.phoneNumber,
                    );
                    if (context.mounted) {
                      // Phone call initiated successfully
                    }
                  } catch (e) {
                    if (context.mounted) {
                      MySnackBar.showErrorToast(message: e.toString());
                    }
                  }
                },
                actionLabel: 'Call',
                actionIcon: Icons.call_rounded,
              ),
              SizedBox(height: 8.h),
              _buildContactChip(
                Icons.email_rounded,
                controller.selectedSite.value?.email != null &&
                        controller.selectedSite.value!.email!
                            .toString()
                            .isNotEmpty
                    ? controller.selectedSite.value!.email!
                    : controller.selectedAppointment.value?.customer?.email !=
                              null &&
                          controller.selectedAppointment.value!.customer!.email!
                              .toString()
                              .isNotEmpty
                    ? controller.selectedAppointment.value!.customer!.email!
                    : 'N/A',
                () async {
                  final email =
                      controller.selectedSite.value?.email != null &&
                          controller.selectedSite.value!.email!
                              .toString()
                              .isNotEmpty
                      ? controller.selectedSite.value!.email!
                      : controller.selectedAppointment.value?.customer?.email !=
                                null &&
                            controller
                                .selectedAppointment
                                .value!
                                .customer!
                                .email!
                                .toString()
                                .isNotEmpty
                      ? controller.selectedAppointment.value!.customer!.email!
                      : null;

                  if (email != null && email.isNotEmpty && email != 'N/A') {
                    try {
                      await UrlLauncher.email(email);
                      if (context.mounted) {
                        // Email launched successfully
                      }
                    } catch (e) {
                      if (context.mounted) {
                        MySnackBar.showErrorToast(message: e.toString());
                      }
                    }
                  } else {
                    if (context.mounted) {
                      MySnackBar.showErrorToast(message: "No email available");
                    }
                  }
                },
                actionLabel: 'Send',
                actionIcon: Icons.mail_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabsGrid() {
    final tabs = [
      {'label': 'CSL', 'icon': Icons.business_rounded},
      {'label': 'Forms', 'icon': Icons.description_rounded},
      {'label': 'Est/Inv', 'icon': Icons.receipt_long_rounded},
      {'label': 'Pictures', 'icon': Icons.photo_library_rounded},
      {'label': 'Equipment', 'icon': Icons.handyman_rounded},
      {'label': 'Files', 'icon': Icons.folder_rounded},
      {'label': 'Notes', 'icon': Icons.note_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final tab = tabs[index];

        return GestureDetector(
          onTap: () {
            // Navigate to dedicated pages
            _redirectTab(tab['label'].toString());
          },
          child: Container(
            decoration: BoxDecoration(
              color: _AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _AppPalette.border, width: 1),
              boxShadow: _AppPalette.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tab['icon'] as IconData,
                  size: 22.sp,
                  color: _AppPalette.primary,
                ),
                SizedBox(height: 4.h),
                Text(
                  tab['label'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _AppPalette.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactChip(
    IconData icon,
    String text,
    VoidCallback? onTap, {
    String? actionLabel,
    IconData? actionIcon,
  }) {
    final bool enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _AppPalette.neutralSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Clamped so it stays compact on tablets (sp scales with width)
            Icon(
              icon,
              size: 14.sp.clamp(13.0, 15.0).toDouble(),
              color: enabled ? _AppPalette.primary : _AppPalette.textSecondary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp.clamp(12.0, 14.0).toDouble(),
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? _AppPalette.textPrimary
                      : _AppPalette.textSecondary,
                ),
              ),
            ),
            if (actionLabel != null && enabled) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _AppPalette.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        actionIcon ?? icon,
                        size: 11.sp.clamp(10.0, 12.0).toDouble(),
                        color: _AppPalette.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 10.5.sp.clamp(10.0, 12.0).toDouble(),
                          fontWeight: FontWeight.w700,
                          color: _AppPalette.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatusBadge(String label, _StatusStyle style) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: style.fg, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: style.fg,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.arrow_drop_down, color: style.fg, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildCompactInfoTile(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    final tint = iconColor ?? _AppPalette.primary;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconColor == null
                  ? _AppPalette.primarySoft
                  : tint.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14.sp, color: tint),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: _AppPalette.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _AppPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Soft-tinted pill styles (fg on soft bg) from the palette.
  _StatusStyle _getStatusStyle(String? status) {
    switch (status?.toLowerCase().trim()) {
      case "completed":
        return const _StatusStyle(_AppPalette.success, _AppPalette.successSoft);
      case "dispatched":
      case "scheduled":
      case "in-route":
      case "in route":
      case "arrived":
        return const _StatusStyle(_AppPalette.info, _AppPalette.infoSoft);
      case "installation in progress":
      case "installation progress":
      case "pending":
        return const _StatusStyle(_AppPalette.warning, _AppPalette.warningSoft);
      case "cancelled":
        return const _StatusStyle(_AppPalette.danger, _AppPalette.dangerSoft);
      default:
        return const _StatusStyle(_AppPalette.neutral, _AppPalette.neutralSoft);
    }
  }

  /// Tickets fall back to neutral (not red) so a missing ticket doesn't
  /// read as an error.
  _StatusStyle _getTicketStyle(String? status) {
    switch (status?.toLowerCase().trim()) {
      case "completed":
        return const _StatusStyle(_AppPalette.success, _AppPalette.successSoft);
      case "parts on order":
        return const _StatusStyle(_AppPalette.info, _AppPalette.infoSoft);
      case "on hold":
        return const _StatusStyle(_AppPalette.warning, _AppPalette.warningSoft);
      default:
        return const _StatusStyle(_AppPalette.neutral, _AppPalette.neutralSoft);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FAB
  // ─────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showSMSBottomSheet(context),
      backgroundColor: _AppPalette.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: Icon(Icons.send_rounded, size: 20.sp),
      label: Text(
        'Send SMS',
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _showSMSBottomSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    controller.appointmentDetailsNoteFocusnode.value.unfocus();
    controller.appointmentDetailsMessageFocusnode.value.unfocus();

    // Prefill with the customer's number; user can edit before sending
    controller.smsPhoneController.text = PhoneDisplayFormatter.format(
      controller.mobileNumber.isNotEmpty
          ? controller.mobileNumber
          : controller.phoneNumber,
    );

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
                      color: _AppPalette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "Phone",
                    style: WarmOrganicBlueTheme.bodySmall.copyWith(
                      color: _AppPalette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  TextField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneInputFormatter()],
                    controller: controller.smsPhoneController,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: _AppPalette.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Text(
                    'Message',
                    style: WarmOrganicBlueTheme.bodySmall.copyWith(
                      color: _AppPalette.textSecondary,
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
                      color: _AppPalette.textSecondary,
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
                            color: _AppPalette.primary,
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
                            color: _AppPalette.primary,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (SimplePhoneFormatter.clean(
                                    controller.smsPhoneController.text,
                                  ).length <
                                  10) {
                                MySnackBar.showErrorToast(
                                  message:
                                      "Please enter a valid 10-digit phone number.",
                                );
                                return;
                              }
                              Get.back();
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
  void _redirectTab(String tabName) {
    switch (tabName) {
      case 'CSL':
        Get.toNamed(Routes.CUSTOMER_LOCATION);
        break;
      case 'Forms':
        Get.toNamed(Routes.FORMS_TAB);
        break;
      case 'Est/Inv':
        Get.toNamed(Routes.ESTIMATE_TAB);
        break;
      case 'Pictures':
        Get.toNamed(Routes.PICTURES_TAB);
        break;
      case 'Equipment':
        Get.toNamed(Routes.EQUIPMENT_TAB);
        break;
      case 'Files':
        Get.toNamed(Routes.FILES_TAB);
        break;
      case 'Notes':
        Get.toNamed(Routes.NOTES_TAB);
        break;
    }
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
                    color: _AppPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Notes",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _AppPalette.textSecondary,
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
                          backgroundColor: _AppPalette.textSecondary,
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

void showAccNotesDialog(
  BuildContext context,
  NotesController notesController,
  AppointmentController appointmentController,
  ThemeData theme,
) {
  final TextEditingController noteController = TextEditingController();

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
                  text: "Add Note",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: _AppPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Description",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _AppPalette.textSecondary,
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
                    textEditingController: noteController,
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
                          backgroundColor: _AppPalette.textSecondary,
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
                          title: "Save",
                          onPressed: () async {
                            if (noteController.text.trim().isEmpty) {
                              MySnackBar.showErrorToast(
                                message: "Please enter a note",
                              );
                              return;
                            }

                            final appointment =
                                appointmentController.selectedAppointment.value;
                            if (appointment == null) {
                              MySnackBar.showErrorToast(
                                message: "No appointment selected",
                              );
                              return;
                            }

                            final success = await notesController.createNote(
                              customerId:
                                  appointment.customerID?.toString() ?? '',
                              siteId:
                                  int.tryParse(appointment.siteID ?? '') ?? 0,
                              description: noteController.text.trim(),
                              companyId: appointment.companyID,
                            );

                            if (success) {
                              Navigator.pop(context);
                            }
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
                    color: _AppPalette.border,
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
                        _AppPalette.primary,
                        () async {
                          Get.back(); // close the sheet, stay on details page
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
        color: isSelected ? color : _AppPalette.neutralSoft,
        borderRadius: BorderRadius.circular(WarmOrganicBlueTheme.radiusMd),
        border: Border.all(color: isSelected ? color : _AppPalette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _AppPalette.textPrimary,
            ),
          ),
          if (isSelected) ...[
            SizedBox(width: 8.w),
            Icon(Icons.check_rounded, size: 18.sp, color: Colors.white),
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
                    color: _AppPalette.border,
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
                        _AppPalette.primary,
                        () async {
                          Get.back(); // close the sheet, stay on details page
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
                              final compressedPath = await compressImage(
                                file.path,
                              );
                              newImages.add(compressedPath);
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
          Icon(icon, size: 30, color: _AppPalette.primary),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

void showSingleFilePickerBottomSheet(BuildContext context) {
  final controller = Get.find<AppointmentController>();
  final fileController = Get.find<FileController>();

  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Material(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.document_scanner),
              title: Text("Pick Document"),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [
                    'pdf',
                    'doc',
                    'docx',
                    'txt',
                    'xls',
                    'xlsx',
                  ],
                  allowMultiple: false,
                );
                if (result != null &&
                    result.files.isNotEmpty &&
                    context.mounted) {
                  final validFiles = [File(result.files.single.path!)];
                  if (validFiles.isNotEmpty) {
                    // Add files to upload list
                    controller.fileUploadList.add(
                      FileUploadItem(
                        time: DateFormat("MM/dd/yyyy").format(DateTime.now()),
                        files: validFiles,
                      ),
                    );
                    controller.update();
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("Browse Files"),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await FilePicker.pickFiles(
                  type: FileType.any,
                  allowMultiple: false,
                );
                if (result != null &&
                    result.files.isNotEmpty &&
                    context.mounted) {
                  final validFiles = [File(result.files.single.path!)];
                  if (validFiles.isNotEmpty) {
                    // Upload file directly using FileController
                    final appointment = controller.selectedAppointment.value;
                    if (appointment != null) {
                      await fileController.uploadFile(
                        customerId: appointment.customerID?.toString() ?? '',
                        siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
                        file: validFiles.first,
                        appointmentId: appointment.apptID.toString(),
                        companyId: appointment.companyID,
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showFileBottomSheet(BuildContext context, int index) {
  final controller = Get.find<AppointmentController>();

  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Material(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.document_scanner),
              title: Text("Pick Document"),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [
                    'pdf',
                    'doc',
                    'docx',
                    'txt',
                    'xls',
                    'xlsx',
                  ],
                  allowMultiple: true,
                );
                if (result != null &&
                    result.files.isNotEmpty &&
                    context.mounted) {
                  final validFiles = result.files
                      .map((e) => File(e.path!))
                      .toList();
                  if (validFiles.isNotEmpty) {
                    if (index != -1) {
                      controller.fileUploadList[index].files.addAll(validFiles);
                    } else {
                      controller.fileUploadList.add(
                        FileUploadItem(
                          time: DateFormat("MM/dd/yyyy").format(DateTime.now()),
                          files: validFiles,
                        ),
                      );
                    }
                    controller.update();
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("Browse Files"),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await FilePicker.pickFiles(
                  type: FileType.any,
                  allowMultiple: true,
                );
                if (result != null &&
                    result.files.isNotEmpty &&
                    context.mounted) {
                  final validFiles = result.files
                      .map((e) => File(e.path!))
                      .toList();
                  if (validFiles.isNotEmpty) {
                    if (index != -1) {
                      controller.fileUploadList[index].files.addAll(validFiles);
                    } else {
                      controller.fileUploadList.add(
                        FileUploadItem(
                          time: DateFormat("MM/dd/yyyy").format(DateTime.now()),
                          files: validFiles,
                        ),
                      );
                    }
                    controller.update();
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
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

/// Decoded PNG bytes for a signature value (data URI or raw base64), or null if malformed.
Uint8List? signatureBytesFromBase64(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    final payload = raw.split(',').last.replaceAll(RegExp(r'\s'), '');
    if (payload.isEmpty) return null;
    return base64Decode(payload);
  } catch (e) {
    debugPrint('Error decoding signature image: $e');
    return null;
  }
}

/// Formatted last-updated date for display, or null when unparseable.
String? formatLastUpdatedDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  DateTime? date = DateTime.tryParse(raw);
  if (date == null) {
    // Same epoch format as CreatedDateTime: /Date(1760000000000)/
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final millis = digits.isNotEmpty ? int.tryParse(digits) : null;
    if (millis != null) {
      date = digits.length <= 11
          ? DateTime.fromMillisecondsSinceEpoch(millis * 1000)
          : DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  if (date == null) return null;
  // Epoch-era timestamps (missing/zero server values) are not real dates.
  if (date.isBefore(DateTime(1980))) return null;
  return DateFormat('MM/dd/yyyy hh:mm a').format(date);
}

/// One checklist row. Must be called synchronously from the checklist's Obx
/// builder — an RxList read deferred into a child widget's build (e.g. a
/// Builder) falls outside Obx's tracking window and throws.
Widget _buildChecklistRow(
  AppointmentController apptC,
  CustomFieldModel field,
  String option,
) {
  final checked = apptC.customFieldChecklistValues.contains(option);
  void toggle(bool? isChecked) {
    if (isChecked == true) {
      apptC.customFieldChecklistValues.add(option);
      field.selectedOptions!.add(option);
    } else {
      apptC.customFieldChecklistValues.remove(option);
      field.selectedOptions!.remove(option);
    }
    apptC.update();
  }

  return InkWell(
    onTap: () => toggle(!checked),
    child: Container(
      color: checked ? _AppPalette.primarySoft : _AppPalette.surface,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 24.sp.clamp(20.0, 26.0),
            height: 24.sp.clamp(20.0, 26.0),
            child: Checkbox(
              value: checked,
              onChanged: toggle,
              activeColor: _AppPalette.primary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: const BorderSide(
                color: _AppPalette.textSecondary,
                width: 1.4,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: checked ? FontWeight.w600 : FontWeight.w500,
                color: checked ? _AppPalette.primary : _AppPalette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
            Container(
              decoration: BoxDecoration(
                color: _AppPalette.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _AppPalette.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < field.options!.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: _AppPalette.border,
                      ),
                    _buildChecklistRow(apptC, field, field.options![i]),
                  ],
                ],
              ),
            ),
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

    case 'time':
      return StatefulBuilder(
        builder: (context, setFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked == null) return;
                  field.timeValue = DateFormat(
                    'hh:mm a',
                  ).format(DateTime(2000, 1, 1, picked.hour, picked.minute));
                  setFieldState(() {});
                },
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select ${field.fieldName}",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    field.timeValue ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          );
        },
      );

    case 'date':
      return StatefulBuilder(
        builder: (context, setFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  field.dateValue = DateFormat('MM/dd/yyyy').format(picked);
                  setFieldState(() {});
                },
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select ${field.fieldName}",
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    field.dateValue ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          );
        },
      );

    case 'signature':
      return StatefulBuilder(
        builder: (context, setFieldState) {
          // Data URI or raw base64 → bytes; null when missing or malformed
          final signatureBytes = signatureBytesFromBase64(field.signatureValue);
          final lastUpdatedLabel = formatLastUpdatedDate(field.lastUpdated);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.fieldName!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () async {
                  await showSignatureDialog(
                    context: context,
                    title: field.fieldName!,
                    onSignatureSaved: (signatureBase64, fullName) {
                      field.signatureValue = signatureBase64;
                      setFieldState(() {});
                    },
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.draw_outlined),
                  ),
                  child: signatureBytes != null
                      ? Image.memory(
                          signatureBytes,
                          height: 100.h,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          errorBuilder: (_, _, _) => Text(
                            "Tap to sign",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : Text(
                          "Tap to sign",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),
              if (lastUpdatedLabel != null) ...[
                SizedBox(height: 6.h),
                Text(
                  'Last updated: $lastUpdatedLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WarmOrganicBlueTheme.coolGray,
                  ),
                ),
              ],
            ],
          );
        },
      );

    default:
      return Text("Unsupported field type: ${field.fieldType}");
  }
}
