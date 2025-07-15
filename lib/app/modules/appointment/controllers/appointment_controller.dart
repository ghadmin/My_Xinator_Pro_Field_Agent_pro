import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xinator_fsm_pro/app/modules/appointment/views/appointment_details_view.dart'
    show ResourceItem;
import 'package:xinator_fsm_pro/app/modules/customer/controllers/customer_controller.dart';
import 'package:xinator_fsm_pro/app/modules/customer/models/customer_model.dart';
import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';
import 'package:xinator_fsm_pro/app/modules/settings/controllers/settings_controller.dart';
import 'package:xinator_fsm_pro/app/modules/settings/models/appointment_status_setting.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../settings/models/ticket_status_model.dart';
import '../models/appointment_model.dart';

class AppointmentController extends GetxController with ExceptionHandler {
  final settingController = Get.put(SettingsController());
  final invoiceController = Get.put(InvoiceController());
  final customerController = Get.put(CustomerController());
  final TextEditingController noteTextController = TextEditingController();
  final TextEditingController sortTextController = TextEditingController();
  final isExpanded = RxBool(false);
  List<ResourceItem> resources = [
    ResourceItem(title: "Fill Gas"),
    ResourceItem(title: "Wash Indoor"),
    ResourceItem(title: "Wash Outdoor"),
    ResourceItem(title: "Check Circuit"),
  ];

  String appointmentID = "";
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
  String notes = "";
  final selectedDate = Rx<DateTime?>(null);
  RxInt selectedAptIndex = 0.obs;
  RxBool isAppointmentEmpty = false.obs;

  RxInt selectedStatusValue = 0.obs;
  RxInt selectedTicketStatusValue = 0.obs;

  /// API ///
  final appointments = RxList<Appointments>();
  final sortedAppointments = RxList<Appointments>();
  final selectedDateString = RxString('');

  List<String> historyNotes = <String>[
    "History note one ",
    "History note two ",
    "History note three ",
    "History note four "
  ];

  void selectSingleAppointments(Appointments appointment, int index) {
    log("all appointment in json : ${appointment.toJson()}");
    customerController.selectedCustomer(
        CustomerModel.fromJson(appointment.customer!.toJson()));
    settingController.selectedAppointmentsStatus(AppointmentStatusSetting(
        companyId: appointment.status?.companyId,
        statusId: appointment.status?.statusId,
        statusName: appointment.status?.statusName));
    settingController.selectedTicket(TicketStatusSettings(
        companyId: appointment.ticketStatus?.companyId,
        statusId: appointment.ticketStatus?.statusId,
        statusName: appointment.ticketStatus?.statusName));
    var createdDateTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.createdDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a");
    var startTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.startDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a");
    var endTime = dateTimeConverter(
        inputFormat: "yyyy/MM/dd hh:mm a",
        inputTime: appointment.endDateTime.toString(),
        outputFormat: "MM/dd/yyyy hh:mm a");
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

    notes = appointment.note ?? "";
    noteTextController.text = appointment.note ?? "";
    selectedAptIndex.value = index;
    mobileNumber = appointment.customer?.mobile ?? "";
  }

  Future<void> pickDate() async {
    selectedDateString('');
    final context = Get.context!;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Date Selection'),
        content: Text('Do you want to pick a single date or a date range?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('single'),
            child: Text('Single Date'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('range'),
            child: Text('Date Range'),
          ),
        ],
      ),
    );

    if (choice == 'single') {
      final DateTime? picked = await showDatePicker(
        context: context,
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

  getAppointments() async {
    showLoading();
    isAppointmentEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();
      var userID = await MySharedPref.getUserName();
      var currentDateTime = DateTime.now();

      var response = await DioClient().get(
        url: ApiUrl.getAppointment,
        params: {
          "appointmentDate": dateTimeConverter(
              inputTime: currentDateTime.toString(),
              outputFormat: "yyyy/MM/dd"),
          "CompanyId": companyID,
          "userId": userID,
        },
      ).catchError(handleError);

      if (response == null) {
        hideLoading();
        showEmptyWidget();
        return;
      }

      if (response.isEmpty) {
        appointments.clear();
        hideLoading();
        showEmptyWidget();
        return;
      }

      appointments.assignAll(
          (response as List).map((e) => Appointments.fromJson(e)).toList());
      sortedAppointments
          .assignAll((response).map((e) => Appointments.fromJson(e)).toList());
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
        hideLoading();
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
      } else {
        appointments.clear();
        savedAppointments.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;
        hideLoading();
        showEmptyWidget();
      }
    }
  }

  clearSort() {
    selectedDate(null);
    selectedDateString('');
    sortedAppointments.clear();
    sortedAppointments.addAll(appointments);
  }

  sortAppointmentsText() {
    if (appointments.isEmpty) return;

    selectedDateString('');
    if (sortTextController.text.isEmpty) {
      selectedDate(null);
      sortedAppointments.clear();
      sortedAppointments.addAll(appointments);
    } else {
      final list = appointments.where(
        (p0) {
          final fName =
              '${p0.customer!.firstName ?? ''} ${p0.customer!.lastName ?? ''}';
          return fName
              .toLowerCase()
              .contains(sortTextController.text.toLowerCase());
        },
      ).toList();
      sortedAppointments.clear();
      sortedAppointments.addAll(list);
    }
  }

  sortAppointmentsDate() {
    if (selectedDate.value != null) {
      sortTextController.clear();
      final list = appointments.where((p0) {
        final date = DateFormat("yyyy/MM/dd hh:mm a").parse(p0.startDateTime!);
        final formattedDate = DateFormat("yyyy/MM/dd").format(date);
        final formattedSelectedDate =
            DateFormat("yyyy/MM/dd").format(selectedDate.value!);
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

  updateAppointment() async {
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
              inputFormat: "MM/dd/yyyy hh:mm a"),
          "StartDateTime": dateTimeConverter(
              inputTime: startDate,
              outputFormat: "yyyy/MM/dd hh:mm a",
              inputFormat: "MM/dd/yyyy hh:mm a"),
          "EndDateTime": dateTimeConverter(
              inputTime: endDate,
              outputFormat: "yyyy/MM/dd hh:mm a",
              inputFormat: "MM/dd/yyyy hh:mm a"),
          "CreatedDateTime": dateTimeConverter(
              inputTime: requestDate,
              outputFormat: "yyyy/MM/dd hh:mm a",
              inputFormat: "MM/dd/yyyy hh:mm a"),
          "TimeSlot": timeSlot,
          "Note": noteTextController.text,
          "PromoCode": promoCode,
          "StatusId":
              settingController.selectedAppointmentsStatus.value!.statusId,
          "TicketStatusId": settingController.selectedTicket.value!.statusId,
          "UserID": userID,
          "CreatedBy": createdBy
        }
      },
    ).catchError(handleError);

    if (response == null) return;

    await getAppointments();

    hideLoading();
    Get.back();
    MySnackBar.showToast(message: response);
  }

  void showEmptyWidget() {
    isAppointmentEmpty.value = true;
  }

  @override
  void onReady() async {
    await Future.wait(<Future<dynamic>>[
      getAppointments(),
      settingController.getAppointmentStatus(),
      settingController.getTicketStatus(),
      invoiceController.getTax(),
    ]);
    super.onReady();
  }
}
