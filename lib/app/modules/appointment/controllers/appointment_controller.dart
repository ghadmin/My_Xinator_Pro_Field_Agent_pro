import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/create_appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/custom_fields_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/image/models/picture_model.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../invoice/controllers/invoice_controller.dart';
import '../../item/models/item_list_model.dart';
import '../../settings/controllers/settings_controller.dart';
import '../models/appointment_model.dart';
import '../models/file_model.dart';
import '../models/note_model.dart';
import '../models/site_model.dart';
import '../models/tag_model.dart';

class MediaModel {
  String time;
  List<String> images;
  TextEditingController descriptionController = TextEditingController();

  MediaModel({required this.time, required this.images});
}

/// Class to represent a file upload item with description
class FileUploadItem {
  final String time;
  final List<File> files;
  final TextEditingController descriptionController = TextEditingController();

  FileUploadItem({required this.time, required this.files});
}

class AppointmentController extends GetxController
    with ExceptionHandler, WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(seconds: 3), () {
      // startPeriodic();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // startPeriodic();
    } else if (state == AppLifecycleState.paused) {
      stop();
    }
  }

  final selectedCustomer = Rx<Customer?>(null);
  final noteText = RxString("");
  final settingController = Get.put(SettingsController());
  final customFieldsController = Get.put(CustomFieldsController());
  final invoiceController = Get.put(InvoiceController());
  final customerController = Get.put(CustomerController());
  final createAppointmentController = Get.put(CreateAppointmentController());
  final TextEditingController sortTextController = TextEditingController();
  final noteController = TextEditingController();
  final note1Controller = TextEditingController();
  final isExpanded = RxBool(false);
  final mediaList = RxList<MediaModel>([]);
  final customFieldChecklistValues = RxList<String>([]);
  final customFieldDropdownValue = RxString('');
  final appointmentDetailsNoteFocusnode = Rx<FocusNode>(FocusNode());
  final appointmentDetailsMessageFocusnode = Rx<FocusNode>(FocusNode());
  final TextEditingController smsController = TextEditingController();
  final customFieldTextController = Rx<TextEditingController>(
    TextEditingController(),
  );

  String appointmentID = "";
  String companyId = "";
  String appointmentUID = "";
  String customerID = "";
  String contactName = "";
  String address = "";
  String mobileNumber = "";
  String phoneNumber = "";
  String email = "";
  String requestDate = "";
  String startDate = "";
  String endDate = "";
  String timeSlot = "";
  int timeSlotID = 0;
  String serviceType = "";
  String serviceTypeID = "";
  String promoCode = "";
  String resource = "";
  int resourceID = 0;
  String createdBy = "";
  String customerTitle = "";
  final selectedDate = Rx<DateTime?>(null);
  RxInt selectedAptIndex = 0.obs;
  final selectedSite = Rx<SiteModel?>(null);
  RxBool isAppointmentEmpty = false.obs;
  final selectedDateRange = Rx<DateTimeRange?>(null);

  RxInt selectedStatusValue = 0.obs; //khel
  RxInt selectedTicketStatusValue = 0.obs; //khel
  RxString selectedTabOption = "Appointment".obs;
  final noteList = RxList<NoteModel>([]);

  /// API ///
  final appointments = RxList<Appointments>();
  final extendedAppointments = RxList<Appointments>();
  final sortedAppointments = RxList<Appointments>();
  final selectedDateString = RxString('');
  final isEquipmentExpanded = RxBool(false);

  final selectedAppointment = Rx<Appointments?>(null);
  final isTyping = RxBool(false);
  final selectedEstimateOrInvoiceIndex = RxInt(0);

  Future<void> getAllNotes({bool showLoader = true}) async {
    try {
      kLog('getAllNotes showLoader: $showLoader');
      if (showLoader) {
        kLog('getAllNotes calling showLoading');
        showLoading();
      }

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        var response = await DioClient()
            .get(
              url: ApiUrl.getAllNotesUrl,
              params: {
                "companyId": companyID,
                "cslId": 0,
                "customerId": 0,
                "appointmentId": 0,
                "siteId": 0,
              },
            )
            .catchError(!showLoader ? handleError : () {});

        if (response == null) {
          hideLoading();
          showEmptyWidget();
          return;
        }
        log("result  ${jsonEncode(response)}");
        if (response.isEmpty) {
          noteList.clear();
          if (showLoader) hideLoading();
          showEmptyWidget();
          return;
        }

        noteList.assignAll(
          (response as List).map((e) => NoteModel.fromJson(e)).toList(),
        );

        hideLoading();

        if (noteList.isEmpty) {
          showEmptyWidget();
        }
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
    }
  }

  /// Get customer site details using siteId from selected appointment
  Future<void> getCustomerSite({bool showLoader = true}) async {
    try {
      kLog('getCustomerSite showLoader: $showLoader');
      if (showLoader) {
        kLog('getCustomerSite calling showLoading');
        showLoading();
      }

      if (await NetworkConnectivity.isNetworkAvailable()) {
        final appointment = selectedAppointment.value;
        if (appointment == null) {
          if (showLoader) hideLoading();
          return;
        }

        final siteId = appointment.siteID;
        final customerId = appointment.customerID;

        if (siteId == null || siteId.isEmpty) {
          if (showLoader) hideLoading();
          return;
        }

        var companyID = await MySharedPref.getCompanyID();

        final response = await DioClient()
            .get(
              url: ApiUrl.getCustomerSitesUrl,
              params: {
                "siteId": siteId,
                "customerId": customerId ?? 0,
                "companyId": companyID,
              },
            )
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) hideLoading();
          return;
        }

        kLog("getCustomerSite response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          selectedSite.value = SiteModel.fromJson(response[0]);
        }

        if (showLoader) hideLoading();
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) hideLoading();
    }
  }

  RxBool statusChange = RxBool(false);

  final TextEditingController noteTextController = TextEditingController();
  RxBool ticketStatusChange = RxBool(false);
  Future<void> selectSingleAppointments(
    Appointments? appointment,
    int index,
  ) async {
    try {
      if (appointment == null) return;
      selectedAppointment(appointment);

      // settingController.selectedAppointmentsStatus(AppointmentStatusSetting(
      //     companyId: appointment.status?.companyId,
      //     statusId: appointment.status?.statusId,
      //     statusName: appointment.status?.statusName));

      // settingController.selectedTicket(TicketStatusSettings(
      //     companyId: appointment.ticketStatus?.companyId,
      //     statusId: appointment.ticketStatus?.statusId,
      //     statusName: appointment.ticketStatus?.statusName));

      var createdDateTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.createdDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a",
      );

      var startTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.startDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a",
      );

      var endTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.endDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a",
      );

      // ✅ Added missing assignments
      createdBy = appointment.createdBy ?? "";
      appointmentID = "${appointment.apptID ?? ""}";
      appointmentUID = appointment.appoinmentUId ?? "";
      customerID = "${appointment.customerID ?? ""}";
      promoCode = appointment.promoCode ?? "";
      serviceTypeID = appointment.serviceTypeId ?? "";

      resourceID = appointment.resourceID!;
      timeSlotID = appointment.timeSlotId!;
      await customFieldsController.getAttachedCustomFields(
        appointmentId: appointment.apptID!,
      );
      noteController.text = appointment.note ?? "";
      await getCustomerSite(showLoader: true);
      contactName =
          "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}";

      // Build address from site or customer data
      // if (selectedSite.value != null) {
      //   final site = selectedSite.value!;
      //   address = _buildAddressString(
      //     address: c.address,
      //     city: "",
      //     state: site.state ?? "",
      //     zipCode: site.zip ?? "",
      //     country: site.country ?? "",
      //   );
      // } else {
      address = _buildAddressString(
        address: appointment.customer?.address1 ?? "",
        city: appointment.customer?.city ?? "",
        state: appointment.customer?.state ?? "",
        zipCode: appointment.customer?.zipCode ?? "",
        country: "",
      );
      mobileNumber = appointment.customer?.mobile ?? "";
      phoneNumber = appointment.customer?.phone ?? "";
      customerTitle =
          "${appointment.customer?.title ?? ""} ${appointment.customer?.title2 ?? ""}";

      // ✅ Added missing assignment
      email = appointment.customer?.email ?? "";

      invoiceController.toTextController.text =
          appointment.customer?.email ?? "";
      invoiceController.customerFirstName.value =
          appointment.customer?.firstName ?? "";

      requestDate = createdDateTime;
      startDate = startTime;
      endDate = endTime;

      timeSlot = appointment.timeSlot ?? "";
      serviceType = appointment.serviceType?.serviceName ?? "";

      if (!statusChange.value) {
        selectedStatusValue.value = appointment.status?.statusId ?? 0;
      }
      if (!ticketStatusChange.value) {
        selectedTicketStatusValue.value =
            appointment.ticketStatus?.statusId ?? 0;
      }

      settingController.selectedAppointmentsStatus(
        settingController.appointmentsStatus.firstWhere(
          (status) => status.statusId == (appointment.status?.statusId ?? 0),
        ),
      );
      settingController.selectedTicket(
        settingController.tickets.firstWhere(
          (status) =>
              status.statusId == (appointment.ticketStatus?.statusId ?? 0),
        ),
      );
      resource = appointment.resource?.name ?? "";
      if (!isTyping.value) {
        noteText(appointment.note ?? "");
        noteTextController.text = noteText.value;
      }

      if (selectedAppointment.value!.invoices != null &&
          selectedAppointment.value!.invoices!.isNotEmpty) {
        for (var item
            in selectedAppointment
                .value!
                .invoices![selectedEstimateOrInvoiceIndex.value]
                .items!) {
          if (invoiceController.selectedItemList
                  .where((e) => e.id == item.itemId)
                  .isEmpty &&
              !invoiceController.removedList.contains(item.itemId)) {
            invoiceController.selectedItemList.add(
              ItemListModel(
                id: item.itemId,
                name: item.name,
                description: item.description,
                price: double.tryParse(item.unitPrice ?? "0.00"),
                isTaxable: item.isTaxable == "TAX" ? true : false,po: item.po,
                // itemTypeId: int.parse(item.itemTyId!),
              ),
            );

            invoiceController.editAmountControllers.add(
              TextEditingController(text: item.unitPrice ?? "0.00"),
            );

            invoiceController.editDescriptionControllers.add(
              TextEditingController(text: item.description ?? ""),
            );

            invoiceController.editQuantityControllers.add(
              TextEditingController(text: item.quantity ?? "1"),
            );
          }
        }
        invoiceController.createTotalForEdit();
      }
    } catch (e) {
      log(" message : $e");
    }
  }

  Future<void> sendSMS() async {
    showLoading(debugInfo: "sendSMS - Start");
    try {
      var companyID = await MySharedPref.getCompanyID();
      var response = await DioClient()
          .get(
            url: ApiUrl.sendCustomerSMS,
            params: {
              "companyId": companyID,
              "customerId": customerID,
              "SMSBody": smsController.text,
              "mobile": mobileNumber.isNotEmpty
                  ? mobileNumber
                  : phoneNumber.isNotEmpty
                  ? phoneNumber
                  : "",
            },
          )
          .catchError((error) {
            // Handle error but don't hide loading here - let the catch block do it
            handleError(error);
            throw error; // Re-throw to ensure we don't continue
          });

      if (response == null) {
        hideLoading(debugInfo: "sendSMS - No response");
        return;
      }

      kLog(
        "url ${ApiUrl.sendCustomerSMS} params ${{"companyId": companyID, "customerId": customerID, "SMSBody": smsController.text, "mobile": mobileNumber.isNotEmpty
            ? mobileNumber
            : phoneNumber.isNotEmpty
            ? phoneNumber
            : ""}}  message send $response",
      );

      smsController.clear();
      MySnackBar.showToast(message: response["Response"]);
    } catch (e) {
      // Error already handled by handleError above
      log("Error in sendSMS: $e");
    } finally {
      hideLoading(debugInfo: "sendSMS - Complete");
    }
  }

  Future<void> pickDate() async {
    selectedDateString('');
    final context = Get.context!;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(text: 'Choose Date Selection'),
        content: TextWidget(
          text: 'Do you want to pick a single date or a date range?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('single'),
            child: TextWidget(text: 'Single Date'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('range'),
            child: TextWidget(text: 'Date Range'),
          ),
        ],
      ),
    );

    if (choice == 'single') {
      final DateTime? picked = await showDatePicker(
        context: Get.context!,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        selectedDate.value = picked;
        selectedDateString(DateFormat("MM/dd/yyyy").format(picked));
        sortAppointmentsDate();
      }
    } else if (choice == 'range') {
      final DateTimeRange? range = await showDateRangePicker(
        context: Get.context!,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: DateTimeRange(
          start: DateTime.now().subtract(Duration(days: 1)),
          end: DateTime.now().add(Duration(days: 1)),
        ),
      );

      if (range != null) {
        selectedDate.value = null;
        selectedDateRange.value = range;
        selectedDateString(
          '${DateFormat("MM/dd/yyyy").format(range.start)} - ${DateFormat("MM/dd/yyyy").format(range.end)}',
        );
        sortAppointmentsInRange(range);
      }
    }
  }

  void sortAppointmentsInRange(DateTimeRange range) {
    sortTextController.clear();

    final list = appointments.where((p0) {
      final date = DateFormat("yyyy/MM/dd hh:mm a").parse(p0.startDateTime!);
      // Filter out Pending and Scheduled status appointments
      final validStatus =
          p0.status?.statusName != "Pending" &&
          p0.status?.statusName != "Scheduled";
      return validStatus &&
          date.isAfter(range.start.subtract(const Duration(days: 1))) &&
          date.isBefore(range.end.add(const Duration(days: 1)));
    }).toList();

    sortedAppointments
      ..clear()
      ..addAll(list.isEmpty ? [] : list);
  }

  final isTaglistLoading = RxBool(false);
  final selectedTagController = Rx<TextEditingController>(
    TextEditingController(),
  );
  final selectedTagId = RxInt(-1);

  final userId = Rx<dynamic>(null);
  Future<void> getCurrentUserId() async {
    var userID = await MySharedPref.getUserName();
    userId(userID);
  }

  // Future<void> getTagList() async {
  //   isTaglistLoading(true);
  //   isAppointmentEmpty.value = false;

  //   if (await NetworkConnectivity.isNetworkAvailable()) {
  //     var companyID = await MySharedPref.getCompanyID();

  //     var response = await DioClient()
  //         .get(url: ApiUrl.getAllTagUrl, params: {"CompanyId": companyID})
  //         .catchError(handleError);

  //     // log("refreshing appointments ${jsonEncode(response)}");

  //     if (response == null || response.isEmpty) {
  //       isTaglistLoading(false);
  //       return;
  //     }
  //     if (response.isEmpty) {
  //       allTagList.clear(); // clear old data
  //       isTaglistLoading(false);
  //       return;
  //     }

  //     // ✅ Parse JSON response into TagModel list
  //     final List<TagModel> parsedList = (response as List)
  //         .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
  //         .toList();

  //     // ✅ Bind to RxList
  //     allTagList.assignAll(parsedList);
  //     filterTags("");

  //     isTaglistLoading(false);
  //   } else {
  //     isTaglistLoading(false);
  //   }
  // }

  final addNewTagLoading = RxBool(false);
  // final allTagList = <TagModel>[].obs;
  final filteredTags = <TagModel>[].obs;

  // void filterTags(String query) {
  //   if (query.isEmpty) {
  //     filteredTags.assignAll(allTagList);
  //   } else {
  //     filteredTags.assignAll(
  //       allTagList.where(
  //         (tag) => tag.name.toLowerCase().contains(query.toLowerCase()),
  //       ),
  //     );
  //   }
  //   selectedTabOption(filteredTags.first.name);
  // }

  // Future<bool> addNewTag(String tagName) async {
  //   try {
  //     addNewTagLoading(true);
  //     final companyId = await MySharedPref.getCompanyID();
  //     final params = {
  //       "tag": {
  //         "id": 0,
  //         "Name": tagName,
  //         "CompanyId": companyId,
  //         "Description": "",
  //         "CreatedAt": DateFormat("yyyy/MM/dd").format(DateTime.now()),
  //       },
  //     };

  //     final response = await DioClient().post(
  //       url: ApiUrl.saveTagUrl,
  //       body: params,
  //     );

  //     if (response != null && response['success'] == true) {
  //       MySnackBar.showToast(
  //         message: "Tag $tagName added successfully",
  //         duration: const Duration(seconds: 2),
  //       ); // refresh UI immediately
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     log("Error adding tag: $e");
  //     return false;
  //   } finally {
  //     getTagList();
  //     addNewTagLoading(false);
  //   }
  // }

  // Image list now stores ImageList objects directly from API array response
  final imageList = RxList<Picture>([]);

  // Group images by upload date

  Future<void> getImageList(bool isFromTab) async {
    showLoading();
    await Future.delayed(Duration.zero);
    // <- give UI a chance to render
    try {
      var companyID = await MySharedPref.getCompanyID();
      // ============================================
      // OLD QUERY PARAMETERS (Kept for reference)
      // ============================================
      // final queryParams = {
      //   "CustomerId": customerID,
      //   "AppointmentId": appointmentID,
      //   "cSLId": 0,
      //   "CompanyId": companyId,
      // };
      // ============================================

      // Prepare request params with new structure
      final queryParams = {
        "id": 0,
        "appointmentID": 0,
        "siteId": selectedSite.value?.id ?? 0,
        "companyId": companyID,
        "customerId": customerID,
      };

      log("queryParams: ${jsonEncode(queryParams)}");

      // Send request
      final response = isFromTab
          ? await DioClient().get(
              url: ApiUrl.getImageListUrl,
              params: queryParams,
            )
          : await DioClient()
                .get(url: ApiUrl.getImageListUrl, params: queryParams)
                .catchError(handleError);
      if (response == null) {
        MySnackBar.showErrorToast(message: "Failed to load images");
      } else {
        final List<Picture> fetchedImages = (response as List)
            .map((e) => Picture.fromJson(e))
            .toList();
        imageList.clear();
        imageList.addAll(fetchedImages);
      }
    } catch (e, st) {
      log("Error fetching images: $e", stackTrace: st);
      // MySnackBar.showErrorToast(message: "Something went wrong!");
    } finally {
      hideLoading(); // ✅ always runs
    }
  }

  // ============================================
  // FILES SECTION
  // ============================================

  // File list stores FileModel objects directly from API array response
  final fileList = RxList<FileModel>([]);

  // For managing files being uploaded (similar to mediaList for images)
  final fileUploadList = RxList<FileUploadItem>([]);

  // For managing file selection with checkboxes
  final selectedFilesIdList = RxList<int>([]);

  /// Toggle file selection by ID
  void updateSelectedFiles(int fileId) {
    if (selectedFilesIdList.contains(fileId)) {
      selectedFilesIdList.remove(fileId);
    } else {
      selectedFilesIdList.add(fileId);
    }
    // Trigger reactive update (GetX equivalent of setState)
    update();
  }

  /// Remove file upload item at index
  void removeFileUploadItem(int index) {
    if (index >= 0 && index < fileUploadList.length) {
      fileUploadList.removeAt(index);
    }
  }

  // Group files by upload date
  Map<String, List<FileModel>> get filesGroupedByDate {
    final Map<String, List<FileModel>> grouped = {};
    for (var file in fileList) {
      final dateStr = file.uploadDate ?? 'Unknown Date';
      try {
        final dateTime = DateTime.parse(dateStr);
        final formattedDate = DateFormat(
          'MMMM dd, yyyy HH:mm:ss',
        ).format(dateTime);

        if (!grouped.containsKey(formattedDate)) {
          grouped[formattedDate] = [];
        }
        grouped[formattedDate]!.add(file);
      } catch (e) {
        // If parsing fails, use original date
        if (!grouped.containsKey(dateStr)) {
          grouped[dateStr] = [];
        }
        grouped[dateStr]!.add(file);
      }
    }
    return grouped;
  }

  /// Get list of files for the current appointment
  Future<void> getFileList({bool showLoader = true}) async {
    if (showLoader) showLoading();
    await Future.delayed(Duration.zero);
    try {
      var companyID = await MySharedPref.getCompanyID();

      // Prepare request params
      final queryParams = {
        "appointmentID": 0,
        // "appointmentID": int.parse(appointmentID),
        "siteId": selectedSite.value?.id ?? 0,
        "companyId": companyID,
        "customerId": int.parse(customerID),
        "reference": "",
      };

      log("getFileList queryParams: ${jsonEncode(queryParams)}");

      final response = await DioClient()
          .get(url: ApiUrl.getFilesUrl, params: queryParams)
          .catchError(handleError);

      log("file res : ${jsonEncode(response)}");

      if (response == null) {
        if (showLoader) {
          MySnackBar.showErrorToast(message: "Failed to load files");
        }
      } else {
        final List<FileModel> fetchedFiles = (response as List)
            .map((e) => FileModel.fromJson(e))
            .toList();
        fileList.clear();
        fileList.addAll(fetchedFiles);
        log("Loaded ${fetchedFiles.length} files");
      }
    } catch (e, st) {
      log("Error fetching files: $e", stackTrace: st);
      if (showLoader) {
        MySnackBar.showErrorToast(message: "Failed to load files");
      }
    } finally {
      if (showLoader) hideLoading();
    }
  }

  Timer? _pollingTimer;
  final isSelectSingleNeedToCall = RxBool(false);
  Future<void> startPeriodic() async {
    var companyID = await MySharedPref.getCompanyID();
    _pollingTimer = Timer.periodic(const Duration(seconds: 120), (timer) async {
      if (companyID != null && companyID != "") {
        await getAppointments(showLoader: false);
        await getInvoiceList(showLoader: false);

        if (selectedAppointment.value != null &&
            !isSelectSingleNeedToCall.value) {
          selectSingleAppointments(
            sortedAppointments[selectedAptIndex.value],
            selectedAptIndex.value,
            // true,
          );
        }
      }
    });
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> getAppointments({bool showLoader = true}) async {
    try {
      if (showLoader) showLoading();

      // showLoading();
      if (showLoader) isAppointmentEmpty.value = false;
      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();
        var userID = await MySharedPref.getUserName();
        var currentDateTime = DateTime.now();

        var response = await DioClient()
            .get(
              url: ApiUrl.getAppointment,
              params: {
                "appointmentTypeStatus": 2,
                "appointmentDate": dateTimeConverter(
                  inputTime: currentDateTime.toString(),
                  outputFormat: "yyyy/MM/dd",
                ),
                "CompanyId": companyID,
                "userId": userID,
              },
            )
            .catchError(!showLoader ? handleError : () {});
        log("refreshing appointments ${jsonEncode(response)}");
        if (response == null) {
          hideLoading();
          showEmptyWidget();
          return;
        }

        if (response.isEmpty) {
          appointments.clear();
          if (showLoader) hideLoading();
          showEmptyWidget();
          return;
        }

        appointments.assignAll(
          (response as List)
              .map((e) => Appointments.fromJson(e))
              .where(
                (apt) =>
                    apt.status?.statusName != "Pending" &&
                    apt.status?.statusName != "Scheduled",
              )
              .toList(),
        );

        sortedAppointments.assignAll(
          response
              .map((e) => Appointments.fromJson(e))
              .where(
                (apt) =>
                    apt.status?.statusName != "Pending" &&
                    apt.status?.statusName != "Scheduled",
              )
              .toList()
            ..sort((a, b) {
              final aDate = DateFormat(
                "yyyy/MM/dd hh:mm a",
              ).parse(a.startDateTime!);
              final bDate = DateFormat(
                "yyyy/MM/dd hh:mm a",
              ).parse(b.startDateTime!);
              return aDate.compareTo(bDate);
            }),
        );
        if (sortTextController.text.isNotEmpty) {
          sortAppointmentsText(); // re-apply text filter after refresh
        } else if (selectedDateRange.value != null) {
          sortAppointmentsInRange(
            selectedDateRange.value!,
          ); // re-apply date range filter after refresh
        } else if (selectedDate.value != null) {
          sortAppointmentsDate(); // re-apply single date filter after refresh
        }

        await MyHive.saveAllAppointments(appointments);
        hideLoading();

        if (appointments.isEmpty) {
          showEmptyWidget();
        }
      } else {
        var savedAppointments = MyHive.getAllAppointments();

        if (savedAppointments.isNotEmpty) {
          appointments.assignAll(savedAppointments);
          savedAppointments.assignAll(savedAppointments);
          //hideLoading();
          MySnackBar.showErrorToast(message: "No network!");
          NetworkConnectivity.connectionChangeCount = 1;
        } else {
          appointments.clear();
          savedAppointments.clear();
          isError.value = true;
          NetworkConnectivity.connectionChangeCount = 1;
          // hideLoading();
          showEmptyWidget();
        }
      }
    } catch (e, s) {
      hideLoading();
      kLog(e);
      kLog(s);
      MySnackBar.showErrorToast(message: "$e");
    }
  }

  Future<void> getInvoiceList({bool showLoader = true}) async {
    extendedAppointments.clear();
    if (showLoader) showLoading();

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();
      var userID = await MySharedPref.getUserName();
      var currentDateTime = DateTime.now();

      var response = await DioClient()
          .get(
            url: ApiUrl.getInvoiceList,
            params: {
              "appointmentTypeStatus": 2,
              "appointmentDate": dateTimeConverter(
                inputTime: currentDateTime.toString(),
                outputFormat: "yyyy/MM/dd",
              ),
              "CompanyId": companyID,
              "userId": userID,
            },
          )
          .catchError(!showLoader ? handleError : () {});
      kLog("refreshing invoice list ${jsonEncode(response)}");
      if (response == null) {
        hideLoading();
        showEmptyWidget();
        return;
      }

      extendedAppointments.assignAll(
        ((response as List).map((e) => Appointments.fromJson(e)).toList()
              ..where(
                (apt) =>
                    apt.status?.statusName != "Pending" &&
                    apt.status?.statusName != "Scheduled",
              ))
            .where(
              (apt) =>
                  apt.status?.statusName != "Pending" &&
                  apt.status?.statusName != "Scheduled",
            )
            .toList(),
      );

      hideLoading();
    }
  }

  void clearSort() {
    selectedDate(null);
    selectedDateRange(null);
    selectedDateString('');
    sortedAppointments.clear();
    sortedAppointments.addAll(appointments);
  }

  void sortAppointmentsText() {
    if (appointments.isEmpty) return;

    selectedDateString('');
    if (sortTextController.text.isEmpty) {
      selectedDate(null);
      sortedAppointments.clear();
      sortedAppointments.addAll(appointments);
    } else {
      final list = appointments.where((p0) {
        final fName =
            '${p0.customer!.firstName ?? ''} ${p0.customer!.lastName ?? ''}';
        return fName.toLowerCase().contains(
          sortTextController.text.toLowerCase(),
        );
      }).toList();
      sortedAppointments.clear();
      sortedAppointments.addAll(list);
    }
  }

  Future<Position?> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return null;
    }

    // Check current permission status
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied || status.isRestricted) {
      // Request permission directly
      status = await Permission.location.request();
      if (!status.isGranted) {
        debugPrint("Location permission denied.");
        return null;
      }
    }

    if (status.isPermanentlyDenied) {
      // On iOS/Android, can't request again, user must enable manually
      debugPrint("Location permission permanently denied.");
      return null;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  final RxBool isLoading = true.obs;
  WebViewController? webController;
  bool isWebControllerInitialized = false;
  Future<void> initializeWebController() async {
    double? currentLat;
    double? currentLng;
    Position? position = await getCurrentLocation();
    if (position != null) {
      currentLat = position.latitude;
      currentLng = position.longitude;
    }

    final url = currentLng == null
        ? "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}&travelmode=driving"
        : "https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLng&destination=${Uri.encodeComponent('daffodil international university, dhaka ')}&travelmode=driving";

    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
          },
          onPageFinished: (url) {
            isLoading.value = false;
            webController?.runJavaScript("""
    // Inject viewport settings
    var meta = document.createElement('meta');
    meta.name = 'viewport';
    meta.content = 'width=device-width, initial-scale=.8, maximum-scale=1.0 user-scalable=no';
    document.getElementsByTagName('head')[0].appendChild(meta);
    document.body.style.zoom = "1";

    // Hide sidebar panel
    var sidePanel = document.querySelector('div[role="region"]');
    if (sidePanel) {
      sidePanel.style.display = 'none';
    }

    // Make map full width
    var map = document.querySelector('#scene');
    if (map) {
      map.style.width = "100%";
    }
  """);
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    isWebControllerInitialized = true;
  }

  void sortAppointmentsDate() {
    if (selectedDate.value != null) {
      sortTextController.clear();
      final list = appointments.where((p0) {
        final date = DateFormat("yyyy/MM/dd hh:mm a").parse(p0.startDateTime!);
        final formattedDate = DateFormat("yyyy/MM/dd").format(date);
        final formattedSelectedDate = DateFormat(
          "yyyy/MM/dd",
        ).format(selectedDate.value!);
        // Filter out Pending and Scheduled status appointments
        final validStatus =
            p0.status?.statusName != "Pending" &&
            p0.status?.statusName != "Scheduled";
        return validStatus && formattedDate == formattedSelectedDate;
      }).toList();
      sortedAppointments.clear();
      if (list.isEmpty) {
        sortedAppointments.clear();
      } else {
        sortedAppointments.addAll(list);
        log("date sorted list length 5: ${sortedAppointments.length}");
      }
    }
  }
  // update appointment

  Future<void> updateAppointment() async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
    kLog(
      "body ${{
        "appointment": {"CompanyID": companyID, "ApptID": appointmentID, "AppoinmentUId": appointmentUID, "CustomerID": customerID, "ServiceType": serviceType, "ServiceTypeId": serviceTypeID, "ResourceID": resourceID, "TimeSlotId": timeSlotID, "ApptDateTime": dateTimeConverter(inputTime: requestDate, outputFormat: "yyyy/MM/dd hh:mm a", inputFormat: "MM/dd/yyyy hh:mm a"), "StartDateTime": dateTimeConverter(inputTime: startDate, outputFormat: "yyyy/MM/dd hh:mm a", inputFormat: "MM/dd/yyyy hh:mm a"), "EndDateTime": dateTimeConverter(inputTime: endDate, outputFormat: "yyyy/MM/dd hh:mm a", inputFormat: "MM/dd/yyyy hh:mm a"), "CreatedDateTime": dateTimeConverter(inputTime: requestDate, outputFormat: "yyyy/MM/dd hh:mm a", inputFormat: "MM/dd/yyyy hh:mm a"), "TimeSlot": timeSlot, "Note": noteText.value, "PromoCode": promoCode, "StatusId": selectedStatusValue.value, "TicketStatusId": selectedTicketStatusValue.value, "UserID": userID, "CreatedBy": createdBy},
      }}",
    );
    var response = await DioClient()
        .post(
          url: ApiUrl.updateAppointment,
          body: {
            "appointment": {
              "CompanyID": companyID,
              "ApptID": appointmentID,
              "AppoinmentUId": appointmentUID,
              "CustomerID": customerID,
              "ServiceType": serviceType,
              "ServiceTypeId": serviceTypeID,
              "ResourceID": resourceID,
              "TimeSlotId": timeSlotID,
              "ApptDateTime": dateTimeConverter(
                inputTime: requestDate,
                outputFormat: "yyyy/MM/dd hh:mm a",
                inputFormat: "MM/dd/yyyy hh:mm a",
              ),
              "StartDateTime": dateTimeConverter(
                inputTime: startDate,
                outputFormat: "yyyy/MM/dd hh:mm a",
                inputFormat: "MM/dd/yyyy hh:mm a",
              ),
              "EndDateTime": dateTimeConverter(
                inputTime: endDate,
                outputFormat: "yyyy/MM/dd hh:mm a",
                inputFormat: "MM/dd/yyyy hh:mm a",
              ),
              "CreatedDateTime": dateTimeConverter(
                inputTime: requestDate,
                outputFormat: "yyyy/MM/dd hh:mm a",
                inputFormat: "MM/dd/yyyy hh:mm a",
              ),
              "TimeSlot": timeSlot,
              "Note": noteText.value,
              "PromoCode": promoCode,
              "StatusId": selectedStatusValue.value,
              "TicketStatusId": selectedTicketStatusValue.value,
              "UserID": userID,
              "CreatedBy": createdBy,
            },
          },
        )
        .catchError(handleError);

    if (response == null) return;

    await getAppointments();
    await getInvoiceList();

    hideLoading();
    Get.back();
    MySnackBar.showToast(message: response);
  }

  final noteId = RxInt(-1);
  Future<void> saveNote(bool isForUpdate) async {
    showLoading();

    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
    final appointment = selectedAppointment.value;
    final site = selectedSite.value;

    var response = await DioClient()
        .post(
          url: isForUpdate ? ApiUrl.updateNoteUrl : ApiUrl.saveNoteUrl,
          body: {
            "note": {
              "Id": noteId.value == -1 ? 0 : noteId.value,
              "Description": noteText.value,
              "CreatedAt": DateFormat(
                "yyyy-MM-ddTHH:mm:ss",
              ).format(DateTime.now()),
              "CSLId": 0,
              "CustomerId": appointment?.customerID ?? 0,
              "AppointmentId": appointment?.apptID ?? 0,
              "SiteID": site?.id ?? 0,
              "CompanyId": companyID,
              "UserId": userID,
              "TagId": 0,
              "UserName": userID,
            },
          },
        )
        .catchError(handleError);

    if (response == null) return;

    // await getAppointments(); // optional, if you want to refresh after saving

    hideLoading();
    Get.back();
    getAllNotes(showLoader: false);
    MySnackBar.showToast(message: 'Notes saved successfully');
  }

  // Format dates as MM/dd/yyyy (input is ISO string)
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  void showEmptyWidget() {
    isAppointmentEmpty.value = true;
  }

  @override
  void onReady() async {
    kLog('onReady called - showing loader');
    showLoading();
    await getAppointments();
    await settingController.getAppointmentStatus();
    await settingController.getTicketStatus();
    await invoiceController.getTax();

    hideLoading();
    super.onReady();
  }

  String _buildAddressString({
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String country,
  }) {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (zipCode.isNotEmpty) parts.add(zipCode);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
