import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
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
import '../../customer/models/customer_model.dart';
import '../../forms/controllers/form_controller.dart';
import '../../invoice/controllers/invoice_controller.dart';
import '../../item/models/item_list_model.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/models/appointment_status_setting.dart';
import '../../settings/models/ticket_status_model.dart';
import '../models/appointment_model.dart';
import '../models/image_list_model.dart';
import '../models/note_model.dart';
import '../models/tag_model.dart';
import '../views/appointment_details_view.dart';

class MediaModel {
  String time;
  List<String> images;
  TextEditingController descriptionController = TextEditingController();

  MediaModel({required this.time, required this.images});
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

  final noteText = RxString("");
  final settingController = Get.put(SettingsController());
  final formC = Get.put(FormController());
  final invoiceController = Get.put(InvoiceController());
  final customerController = Get.put(CustomerController());
  final TextEditingController sortTextController = TextEditingController();
  final noteController = TextEditingController();
  final note1Controller = TextEditingController();
  final isExpanded = RxBool(false);
  final mediaList = RxList<MediaModel>([]);
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
  RxBool isAppointmentEmpty = false.obs;

  RxInt selectedStatusValue = 0.obs;
  RxInt selectedTicketStatusValue = 0.obs;
  RxString selectedTabOption = "Appointment".obs;
  final noteList = RxList<NoteModel>([]);

  /// API ///
  final appointments = RxList<Appointments>();
  final sortedAppointments = RxList<Appointments>();
  final selectedDateString = RxString('');
  final isBasicExpanded = RxBool(false);
  final isEquipmentExpanded = RxBool(false);

  List<String> historyNotes = <String>[
    "History note one ",
    "History note two ",
    "History note three ",
    "History note four ",
  ];
  final selectedAppointment = Rx<Appointments?>(null);
  final isTyping = RxBool(false);
  final selectedEstimateOrInvoiceIndex = RxInt(0);

  Future<void> getAllNotes({bool showLoader = true}) async {
    if (showLoader) showLoading();

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(url: ApiUrl.getAllNotesUrl, params: {
        "companyId": companyID
      }).catchError(!showLoader ? handleError : () {});

      if (response == null) {
        hideLoading();
        showEmptyWidget();
        return;
      }
      log("result  $response");
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
  }

  void selectSingleAppointments(
    Appointments? appointment,
    int index,
    bool fromPeriodic,
  ) {
    if (!fromPeriodic) {
      imageList.clear();
      mediaList.clear();
      selectedTagController.value.clear();
    }
    if (appointment == null) return;
    selectedAppointment(appointment);

    // set full customer object
    customerController.selectedCustomer(
      CustomerModel.fromJson(appointment.customer!.toJson()),
    );

    companyId = appointment.companyID ?? "";

    settingController.selectedAppointmentsStatus(
      AppointmentStatusSetting(
        companyId: appointment.status?.companyId,
        statusId: appointment.status?.statusId,
        statusName: appointment.status?.statusName,
      ),
    );

    settingController.selectedTicket(
      TicketStatusSettings(
        companyId: appointment.ticketStatus?.companyId,
        statusId: appointment.ticketStatus?.statusId,
        statusName: appointment.ticketStatus?.statusName,
      ),
    );

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

    contactName =
        "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}";
    address = "${appointment.customer?.address1}, "
        "${appointment.customer?.city}, "
        "${appointment.customer?.state}, ";
    mobileNumber = appointment.customer?.mobile ?? "";
    phoneNumber = appointment.customer?.phone ?? "";
    customerTitle =
        "${appointment.customer?.title ?? ""} ${appointment.customer?.title2 ?? ""}";

    // ✅ Added missing assignment
    email = appointment.customer?.email ?? "";

    invoiceController.toTextController.text = appointment.customer?.email ?? "";
    invoiceController.customerFirstName.value =
        appointment.customer?.firstName ?? "";

    requestDate = createdDateTime;
    startDate = startTime;
    endDate = endTime;

    timeSlot = appointment.timeSlot ?? "";
    serviceType = appointment.serviceType?.serviceName ?? "";

    selectedStatusValue.value = appointment.status?.statusId ?? 0;
    selectedTicketStatusValue.value = appointment.ticketStatus?.statusId ?? 0;
    resource = appointment.resource?.name ?? "";
    if (!isTyping.value) {
      noteText(appointment.note ?? "");
      noteController.text = noteText.value;
    }
    selectedAptIndex.value = index;
    if (selectedAppointment.value!.invoices != null &&
        selectedAppointment.value!.invoices!.isNotEmpty) {
      for (var item in selectedAppointment
          .value!.invoices![selectedEstimateOrInvoiceIndex.value].items!) {
        if (invoiceController.selectedItemList
                .where((e) => e.selectedItem!.id == item.itemId)
                .isEmpty &&
            !invoiceController.removedList.contains(item.itemId)) {
          invoiceController.selectedItemList.add(
            SelectedItemListModel(
              quantity: double.parse(item.quantity ?? "1.00"),
              selectedItem: ItemListModel(
                id: item.itemId,
                name: item.name,
                description: item.description,
                price: double.tryParse(item.unitPrice ?? "0.00"),
                isTaxable: item.isTaxable == "TAX" ? true : false,
                // itemTypeId: int.parse(item.itemTyId!),
              ),
            ),
          );

          // invoiceController.editAmountControllers
          //     .add(TextEditingController(text: item.unitPrice ?? "0.00"));

          // invoiceController.editDescriptionControllers
          //     .add(TextEditingController(text: item.description ?? ""));
        }
      }
      if (!fromPeriodic) invoiceController.createTotalForEdit();
    }
    getAllNotes(showLoader: false);
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

  Future<void> getTagList() async {
    isTaglistLoading(true);
    isAppointmentEmpty.value = false;

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(
          url: ApiUrl.getAllTagUrl,
          params: {"CompanyId": companyID}).catchError(handleError);

      // log("refreshing appointments ${jsonEncode(response)}");

      if (response == null || response.isEmpty) {
        isTaglistLoading(false);
        return;
      }
      if (response.isEmpty) {
        allTagList.clear(); // clear old data
        isTaglistLoading(false);
        return;
      }

      // ✅ Parse JSON response into TagModel list
      final List<TagModel> parsedList = (response as List)
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // ✅ Bind to RxList
      allTagList.assignAll(parsedList);
      filterTags("");

      isTaglistLoading(false);
    } else {
      isTaglistLoading(false);
    }
  }

  final addNewTagLoading = RxBool(false);
  final allTagList = <TagModel>[].obs;
  final filteredTags = <TagModel>[].obs;

  void filterTags(String query) {
    if (query.isEmpty) {
      filteredTags.assignAll(allTagList);
    } else {
      filteredTags.assignAll(
        allTagList.where(
          (tag) => tag.name.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
    selectedTabOption(filteredTags.first.name);
  }

  Future<bool> addNewTag(String tagName) async {
    try {
      addNewTagLoading(true);
      final companyId = await MySharedPref.getCompanyID();
      final params = {
        "tag": {
          "id": 0,
          "Name": tagName,
          "CompanyId": companyId,
          "Description": "",
          "CreatedAt": DateFormat("yyyy/MM/dd").format(DateTime.now()),
        },
      };

      final response = await DioClient().post(
        url: ApiUrl.saveTagUrl,
        body: params,
      );

      if (response != null && response['success'] == true) {
        MySnackBar.showToast(
          message: "Tag $tagName added successfully",
          duration: const Duration(seconds: 2),
        ); // refresh UI immediately
        return true;
      }
      return false;
    } catch (e) {
      log("Error adding tag: $e");
      return false;
    } finally {
      getTagList();
      addNewTagLoading(false);
    }
  }

  Future<void> uploadImages({
    required String tagName,
    // List of image file paths
    required String description,
  }) async {
    showLoading();
    await Future.delayed(Duration.zero); // <- give UI a chance to render

    // Convert image files to Base64
    final List<Map<String, dynamic>> imageList = [];
    for (final path in mediaList.first.images) {
      final file = File(path);
      if (!file.existsSync()) continue; // Skip if file doesn't exist

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      imageList.add({
        "ImageName": file.uri.pathSegments.last,
        "ImageBase64": base64Image,
        "Description": description,
        "CreatedAt": DateFormat("yyyy/MM/dd").format(DateTime.now()),
      });
    }

    // Prepare request body
    final requestBody = {
      "requestPeram": {
        "CustomerId": customerID,
        "AppointmentId": appointmentID,
        "CSLId": 0,
        "CompanyId": companyId,
        "TagName": tagName,
        "ImageList": imageList,
      },
    };
    log(" body: $requestBody");
    // Send request
    final response = await DioClient()
        .post(url: ApiUrl.saveImageUrl, body: requestBody)
        .catchError(handleError);
    log("chill $response");
    hideLoading();

    if (response == null) {
      MySnackBar.showErrorToast(message: "Upload failed: No response");
    } else {
      MySnackBar.showToast(message: "Images uploaded successfully!");
      mediaList.clear();
    }
    getImageList(false);
  }

  final imageList = RxList<ImageListModel>([]);
  Future<void> getImageList(bool isFromTab) async {
    showLoading();
    await Future.delayed(Duration.zero); // <- give UI a chance to render
    try {
      // Prepare request params
      final queryParams = {
        "CustomerId": customerID,
        "AppointmentId": appointmentID,
        "cSLId": 0,
        "CompanyId": companyId,
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
      log("image res : ${jsonEncode(response)}");
      if (response == null) {
        MySnackBar.showErrorToast(message: "Failed to load images");
      } else {
        final List<ImageListModel> fetchedImages =
            (response as List).map((e) => ImageListModel.fromJson(e)).toList();
        imageList.clear();
        imageList.addAll(fetchedImages);
      }
    } catch (e, st) {
      // MySnackBar.showErrorToast(message: "Something went wrong!");
    } finally {
      hideLoading(); // ✅ always runs
    }
  }

  Timer? _pollingTimer;
  final isSelectSingleNeedToCall = RxBool(false);
  Future<void> startPeriodic() async {
    var companyID = await MySharedPref.getCompanyID();
    _pollingTimer = Timer.periodic(const Duration(seconds: 120), (timer) async {
      if (companyID != null && companyID != "") {
        await getAppointments(showLoader: false);

        if (selectedAppointment.value != null &&
            !isSelectSingleNeedToCall.value) {
          selectSingleAppointments(
            sortedAppointments[selectedAptIndex.value],
            selectedAptIndex.value,
            true,
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

      var response = await DioClient().get(
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
      ).catchError(!showLoader ? handleError : () {});
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
        (response).map((e) => Appointments.fromJson(e)).toList()
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
      print("Location services are disabled.");
      return null;
    }

    // Check current permission status
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied || status.isRestricted) {
      // Request permission directly
      status = await Permission.location.request();
      if (!status.isGranted) {
        print("Location permission denied.");
        return null;
      }
    }

    if (status.isPermanentlyDenied) {
      // On iOS/Android, can't request again, user must enable manually
      print("Location permission permanently denied.");
      return null;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print("Error getting location: $e");
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
    var response = await DioClient().post(
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
          "StatusId":
              settingController.selectedAppointmentsStatus.value!.statusId,
          "TicketStatusId": settingController.selectedTicket.value!.statusId,
          "UserID": userID,
          "CreatedBy": createdBy,
        },
      },
    ).catchError(handleError);

    if (response == null) return;

    await getAppointments();

    hideLoading();
    Get.back();
    MySnackBar.showToast(message: response);
  }

  final noteId = RxInt(-1);
  Future<void> saveNote(bool isForUpdate) async {
    showLoading();

    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();

    var response = await DioClient().post(
      url: isForUpdate
          ? ApiUrl.updateNoteUrl
          : ApiUrl.saveNoteUrl, // 👈 Replace with your actual endpoint
      body: {
        "note": {
          "Id": noteId.value == -1 ? 0 : noteId.value,
          "Description": noteText
              .value, // 👈 assuming you have a TextEditingController or Rx variable
          "CreatedAt": DateFormat("yyyy/MM/dd").format(DateTime.now()),
          "CSLId": 0,
          "CustomerId": customerID,
          "AppointmentId": appointmentID,
          "CompanyId": companyID,
          "UserId": userID,
          "TagId": selectedTagId.value,
        },
      },
    ).catchError(handleError);

    if (response == null) return;

    // await getAppointments(); // optional, if you want to refresh after saving

    hideLoading();
    Get.back();
    getAllNotes(showLoader: false);
    MySnackBar.showToast(message: response);
  }

  void showEmptyWidget() {
    isAppointmentEmpty.value = true;
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
