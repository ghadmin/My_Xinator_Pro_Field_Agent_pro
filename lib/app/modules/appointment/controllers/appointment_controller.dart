import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/custom_fields_controller.dart';
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
import '../../../service/helper/dialog_helper.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../forms/controllers/form_controller.dart';
import '../../invoice/controllers/invoice_controller.dart';
import '../../item/models/item_list_model.dart';
import '../../settings/controllers/settings_controller.dart';
import '../models/appointment_model.dart';
import '../models/equipment_model.dart';
import '../models/equipment_type_model.dart';
import '../models/file_model.dart';
import '../models/image_list_model.dart';
import '../models/note_model.dart';
import '../models/site_model.dart';
import '../models/tag_model.dart';
import '../views/appointment_details_view.dart';

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
  final formC = Get.put(FormController());
  final invoiceController = Get.put(InvoiceController());
  final customerController = Get.put(CustomerController());
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
  List<ResourceItem> resources = [
    ResourceItem(title: "Fill Gas"),
    ResourceItem(title: "Wash Indoor"),
    ResourceItem(title: "Wash Outdoor"),
    ResourceItem(title: "Check Circuit"),
  ];

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

  RxInt selectedStatusValue = 0.obs; //khel
  RxInt selectedTicketStatusValue = 0.obs; //khel
  RxString selectedTabOption = "Appointment".obs;
  final noteList = RxList<NoteModel>([]);
  final equipmentList = RxList<EquipmentModel>([]);
  final equipmentTypeList = RxList<EquipmentTypeModel>([]);
  final selectedEquipmentTypeList = RxList<EquipmentTypeModel>([]);

  /// API ///
  final appointments = RxList<Appointments>();
  final extendedAppointments = RxList<Appointments>();
  final sortedAppointments = RxList<Appointments>();
  final selectedDateString = RxString('');
  final isBasicExpanded = RxBool(false);
  final isEquipmentExpanded = RxBool(false);

  final selectedAppointment = Rx<Appointments?>(null);
  final isTyping = RxBool(false);
  final selectedEstimateOrInvoiceIndex = RxInt(0);

  Future<void> getAllNotes({bool showLoader = true}) async {
    try {
      if (showLoader) showLoading();

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
      if (showLoader) showLoading();

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

        log("getCustomerSite response: $response");

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

      await getCustomerSite(showLoader: false);
      contactName =
          "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}";
      address =
          "${appointment.customer?.address1}, "
          "${appointment.customer?.city}, "
          "${appointment.customer?.state}, ";
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
                isTaxable: item.isTaxable == "TAX" ? true : false,
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
    var companyID = MySharedPref.getCompanyID();
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
        .catchError(handleError);

    if (response == null) return;
    log(
      "url ${ApiUrl.sendCustomerSMS} params ${{"companyId": companyID, "customerId": customerID, "SMSBody": smsController.text, "mobile": mobileNumber.isNotEmpty
          ? mobileNumber
          : phoneNumber.isNotEmpty
          ? phoneNumber
          : ""}}  message send $response",
    );
    hideLoading(debugInfo: "sendSMS - Success");
    smsController.clear();
    MySnackBar.showToast(message: response["Response"]);
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
      return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
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

  Future<void> uploadImages({
    required String tagName,
    // List of image file paths
    required String description,
  }) async {
    showLoading();
    await Future.delayed(Duration.zero); // <- give UI a chance to render

    // Convert image files to Base64
    // final List<Map<String, dynamic>> imageList = [];
    // for (final path in mediaList.first.images) {
    //   final file = File(path);
    //   if (!file.existsSync()) continue;

    //   final bytes = await file.readAsBytes();
    //   final base64Image = base64Encode(bytes);

    //   imageList.add({
    //     "ImageName": file.uri.pathSegments.last,
    //     "ImageBase64": base64Image,
    //     "Description": description,
    //     "CreatedAt": DateFormat("yyyy/MM/dd").format(DateTime.now()),
    //   });
    // }

    // var userID = await MySharedPref.getUserName();
    // final requestBody = {
    //   "requestPeram": {
    //     "CustomerId": customerID,
    //     "AppointmentId": appointmentID,
    //     "CSLId": 0,
    //     "UploadedBy": userID,
    //     "CompanyId": companyId,
    //     "TagName": tagName,
    //     "ImageList": imageList,
    //   },
    // };

    // ============================================
    // NEW REQUEST BODY STRUCTURE (Kept for reference)
    // ============================================
    final List<Map<String, dynamic>> pictures = [];
    var userID = await MySharedPref.getUserName();
    final sharedPrefCompanyId = await MySharedPref.getCompanyID();
    for (final path in mediaList.first.images) {
      // Use helper method to convert image to base64
      final base64Image = await _convertImageToBase64(path);
      if (base64Image == null) continue; // Skip if conversion failed

      final file = File(path);

      pictures.add({
        "Id": mediaList.first.images.indexOf(
          path,
        ), // Will be generated by server
        "CompanyID": sharedPrefCompanyId,
        "CustomerID": customerID,
        "SiteId": selectedSite.value?.id ?? 0, // Add siteId if available
        "FileName": file.uri.pathSegments.last,
        "FileContent": base64Image, "UploadDate": mediaList.first.time,
        "UploadedBy": userID,
        "AppointmentId": int.tryParse(appointmentID) ?? 0,
        "Reference": description, // Using tagName as reference
      });
    }

    // Prepare request body with new structure
    final requestBody = {"pictures": pictures};
    // ============================================

    log("uploadImages body: ${jsonEncode(requestBody)}");

    // Send request
    final response = await DioClient()
        .post(url: ApiUrl.saveImageUrl, body: requestBody)
        .catchError(handleError);

    log("uploadImages response: $response");
    hideLoading();

    if (response == null) {
      MySnackBar.showErrorToast(message: "Upload failed: No response");
    } else {
      MySnackBar.showToast(message: "Images uploaded successfully!");
      mediaList.clear();
    }
    getImageList(false);
  }

  // Helper method to convert image file to base64 using isolate
  Future<String?> _convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Use isolate for heavy base64 encoding
      final base64Image = await compute(_encodeBytesToBase64, bytes);

      return base64Image;
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  // ============================================
  // OLD IMAGE LIST DECLARATION (Kept for reference)
  // ============================================
  // final imageList = RxList<ImageListModel>([]);
  // ============================================

  // Image list now stores ImageList objects directly from API array response
  final imageList = RxList<ImageList>([]);

  // Group images by upload date
  Map<String, List<ImageList>> get imagesGroupedByDate {
    final Map<String, List<ImageList>> grouped = {};
    for (var image in imageList) {
      final date = image.uploadDate ?? 'Unknown Date';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(image);
    }
    return grouped;
  }

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
        final List<ImageList> fetchedImages = (response as List)
            .map((e) => ImageList.fromJson(e))
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

  // Group files by upload date
  Map<String, List<FileModel>> get filesGroupedByDate {
    final Map<String, List<FileModel>> grouped = {};
    for (var file in fileList) {
      final date = file.uploadDate ?? 'Unknown Date';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(file);
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

  /// Upload files to the server
  Future<void> uploadFiles({
    required String tagName,
    // List of image file paths
    required String description,
  }) async {
    // Show upload progress dialog
    DialogHelper.showUploadProgressDialog();

    var userID = await MySharedPref.getUserName();
    final sharedPrefCompanyId = await MySharedPref.getCompanyID();

    // Count total files first for progress tracking
    int totalFiles = 0;
    for (final uploadItem in fileUploadList) {
      totalFiles += uploadItem.files.length;
    }

    if (totalFiles == 0) {
      DialogHelper.hideLoading();
      MySnackBar.showErrorToast(message: "No files to upload");
      return;
    }

    int uploadedCount = 0;
    int failedCount = 0;

    // Process files one at a time - convert AND upload immediately
    for (final uploadItem in fileUploadList) {
      for (final file in uploadItem.files) {
        uploadedCount++;

        final fileName = file.uri.pathSegments.last;

        // Update progress - preparing
        DialogHelper.updateUploadProgress(
          "Preparing ($uploadedCount/$totalFiles):\n$fileName",
        );

        // Convert to base64 (with isolate for heavy lifting)
        final base64File = await _convertFileToBase64(file);
        if (base64File == null) {
          failedCount++;
          continue;
        }

        // Prepare upload data
        final uploadData = {
          "CompanyID": sharedPrefCompanyId,
          "CustomerID": customerID,
          "FileType": lookupMimeType(file.path) ?? 'application/octet-stream',
          "SiteId":
              selectedSite.value?.id ?? selectedAppointment.value?.siteID ?? 0,
          "FileName": fileName,
          "FileSize": await file.length(),
          "FileContent": base64File,
          "UploadedBy": userID,
          "AppointmentId": int.tryParse(appointmentID) ?? 0,
          "Reference": "desc",
        };
        kLog("Prepared upload data for $fileName: ${jsonEncode(uploadData)}");
        // Update progress - uploading
        DialogHelper.updateUploadProgress(
          "Uploading ($uploadedCount/$totalFiles):\n$fileName",
        );

        // Upload immediately after conversion
        final response = await DioClient()
            .post(url: ApiUrl.saveFilesUrl, body: {"file": uploadData})
            .catchError(handleError);

        log("uploadFiles response: $response");

        if (response == null) {
          failedCount++;
        }

        // Clear base64 from memory to free up space
        uploadData["FileContent"] = null;
      }
    }

    // Update dialog with final status
    if (failedCount == 0) {
      DialogHelper.updateUploadProgress("All files uploaded successfully!");
      fileUploadList.clear();
    } else if (failedCount < totalFiles) {
      DialogHelper.updateUploadProgress(
        "Uploaded ${totalFiles - failedCount}/$totalFiles files",
      );
    } else {
      DialogHelper.updateUploadProgress("All files failed to upload");
    }

    // Wait a moment to show the final message
    await Future.delayed(const Duration(seconds: 1));

    // Hide dialog
    DialogHelper.hideLoading();

    getFileList(showLoader: false);
  }

  // Helper method to convert file to base64 using isolate
  Future<String?> _convertFileToBase64(File file) async {
    try {
      if (!file.existsSync()) {
        debugPrint('File does not exist: ${file.path}');
        return null;
      }

      // Read file bytes first (can't pass File to isolate)
      final bytes = await file.readAsBytes();

      // Use isolate for heavy base64 encoding
      final base64File = await compute(_encodeBytesToBase64, bytes);

      return base64File;
    } catch (e) {
      debugPrint('Error converting file to base64: $e');
      return null;
    }
  }

  // Static function for isolate - must be top-level or static
  static String _encodeBytesToBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  /// Add files to the upload list
  void addFilesToUploadList(List<File> files) {
    final now = DateTime.now();
    final timeString = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    final uploadItem = FileUploadItem(time: timeString, files: files);

    fileUploadList.add(uploadItem);
  }

  /// Remove a file upload item from the list
  void removeFileUploadItem(int index) {
    if (index >= 0 && index < fileUploadList.length) {
      fileUploadList.removeAt(index);
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
        (response as List).map((e) => Appointments.fromJson(e)).toList(),
      );

      sortedAppointments.assignAll(
        (response).map((e) => Appointments.fromJson(e)).toList()..sort((a, b) {
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
        sortAppointmentsText(); // re-apply filter after refresh
      }
      formC.getAttachedForms(isFromPeriodic: showLoader);

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
        (response as List).map((e) => Appointments.fromJson(e)).toList(),
      );

      hideLoading();
    }
  }

  void clearSort() {
    selectedDate(null);
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
        return formattedDate == formattedSelectedDate;
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

  /// Save Equipment to server
  Future<void> saveEquipment() async {
    showLoading();

    var companyID = await MySharedPref.getCompanyID();
    final site = selectedSite.value;

    var response = await DioClient()
        .post(
          url: ApiUrl.saveEquipmentUrl,
          body: {
            "equipments": selectedEquipmentTypeList
                .map(
                  (e) => {
                    "Id": 0,
                    "CompanyID": companyID,
                    "CustomerID": int.parse(customerID),
                    "CustomerGuid": "",
                    "SiteId": site?.id ?? 0,
                    "Model": "",
                    "Make": "",
                    "SerialNumber": "",
                    "Barcode": "",
                    "EquipmentTypeID": e.equipmentTypeId,
                    "Notes": "",
                    "WarrantyStart": "",
                    "WarrantyEnd": "",
                    "LaborWarrantyStart": "",
                    "LaborWarrantyEnd": "",
                    "InstallDate": "",
                    "CreatedDateTime": DateFormat(
                      'MM/dd/yyyy HH:mm:ss',
                    ).format(DateTime.now()),
                  },
                )
                .toList(),
          },
        )
        .catchError(handleError);

    if (response == null) {
      hideLoading();
      return;
    }

    // Fetch equipment list after successful save
    await getEquipment(showLoader: false);

    hideLoading();

    selectedEquipmentTypeList.clear();
    MySnackBar.showToast(message: 'Equipment saved successfully');
  }

  /// Update Equipment to server
  Future<void> updateEquipment(EquipmentModel equipment) async {
    showLoading();

    var companyID = await MySharedPref.getCompanyID();

    var response = await DioClient()
        .post(
          url: ApiUrl.updateEquipmentUrl,
          body: {
            "equipments": [
              {
                "Id": int.parse(equipment.id ?? "0"), // Include ID for update
                "CompanyID": companyID,
                "CustomerID": customerID,
                "CustomerGuid": selectedSite.value != null
                    ? selectedSite.value!.customerGuid
                    : "",
                "SiteId": selectedSite.value != null
                    ? selectedSite.value!.id
                    : 0,
                "Model": equipment.model ?? "",
                "Make": equipment.make ?? "",
                "SerialNumber": equipment.serialNumber,
                "Barcode": equipment.sku ?? "",
                "EquipmentType": equipment.type,
                "Notes": equipment.notes ?? "",
                "WarrantyStart": formatDate(equipment.warrantyStart),
                "WarrantyEnd": formatDate(equipment.warrantyEnd),
                "LaborWarrantyStart": formatDate(equipment.laborWarrantyStart),
                "LaborWarrantyEnd": formatDate(equipment.laborWarrantyEnd),
                "InstallDate": formatDate(equipment.installDate),
                "CreatedDateTime": equipment.createdAt != null
                    ? DateFormat(
                        'MM/dd/yyyy HH:mm:ss',
                      ).format(DateTime.parse(equipment.createdAt!))
                    : DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
              },
            ],
          },
        )
        .catchError(handleError);

    if (response == null) {
      hideLoading();
      Get.back();
      return;
    }

    // Fetch equipment list after successful update
    await getEquipment(showLoader: false);

    hideLoading();
    MySnackBar.showToast(message: 'Equipment updated successfully');
    Get.back();
  }

  /// Get equipment list from server
  Future<void> getEquipment({bool showLoader = true}) async {
    try {
      if (showLoader) showLoading();

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();
        final site = selectedSite.value;

        var response = await DioClient()
            .get(
              url: ApiUrl.getEquipmentUrl,
              params: {
                "companyId": companyID,
                "siteId": site?.id ?? 0,
                "customerId": customerID,
              },
            )
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) hideLoading();
          return;
        }

        log("getEquipment response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          final equipments = response
              .map((e) => EquipmentModel.fromJsonServer(e))
              .toList();

          // Map equipmentTypeId to type description
          for (var equipment in equipments) {
            if (equipment.equipmentTypeId != null) {
              final type = equipmentTypeList.firstWhereOrNull(
                (t) => t.equipmentTypeId == equipment.equipmentTypeId,
              );
              if (type != null) {
                // Update the equipment with the type description
                final index = equipments.indexWhere(
                  (e) => e.id == equipment.id,
                );
                if (index != -1) {
                  equipments[index] = equipment.copyWith(
                    type: type.equipmentTypeDesc,
                  );
                }
              }
            }
          }

          equipmentList.assignAll(equipments);
        } else {
          equipmentList.clear();
        }

        if (showLoader) hideLoading();
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) hideLoading();
    }
  }

  void showEmptyWidget() {
    isAppointmentEmpty.value = true;
  }

  /// Get equipment type list from server
  Future<void> getEquipmentTypes({bool showLoader = true}) async {
    try {
      if (showLoader) showLoading();

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        var response = await DioClient()
            .get(
              url: ApiUrl.getEquipmentTypeUrl,
              params: {"companyId": companyID},
            )
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) hideLoading();
          return;
        }

        log("getEquipmentType response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          equipmentTypeList.assignAll(
            response.map((e) => EquipmentTypeModel.fromJson(e)).toList(),
          );
        } else {
          equipmentTypeList.clear();
        }

        if (showLoader) hideLoading();
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) hideLoading();
    }
  }

  @override
  void onReady() async {
    showLoading();
    await getAppointments();
    await settingController.getAppointmentStatus();
    await settingController.getTicketStatus();
    await invoiceController.getTax();

    hideLoading();
    super.onReady();
  }
}
