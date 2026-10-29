import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/customer_model.dart';
import '../../appointment/controllers/create_appointment_controller.dart';
import '../../appointment/models/appointment_model.dart';

class CustomerController extends GetxController with ExceptionHandler {
  String businessName = "";
  String title = "";
  String address = "";
  String phoneNumber = "";
  String mobileNumber = "";
  final TextEditingController sortTextController = TextEditingController();
  String email = "";
  RxBool isCustomerEmpty = false.obs;
  final selectedCustomer = Rx<CustomerModel?>(null);

  // Getter to access CreateAppointmentController
  CreateAppointmentController get createAppointmentController =>
      Get.find<CreateAppointmentController>();

  /// API ///
  final customers = RxList<CustomerModel>();
  final sortedCustomers = RxList<CustomerModel>();
  void sortAppointmentsText() {
    if (customers.isEmpty) return;

    // selectedDateString('');
    if (sortTextController.text.isEmpty) {
      // selectedDate(null);
      // sortedAppointments.clear();
      // sortedAppointments.addAll(appointments);
    } else {
      final list = customers.where((p0) {
        final combinedText = [
          p0.firstName,
          p0.lastName,
          p0.address1,
          p0.mobile,
          p0.phone,
          p0.email,
        ].where((e) => e != null).join(' ').toLowerCase();

        return combinedText.contains(sortTextController.text.toLowerCase());
      }).toList();
      sortedCustomers.clear();
      sortedCustomers.addAll(list);
    }
  }

  Future<void> getCustomers() async {
    isCustomerEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var currentDateTime = DateTime.now();
      var response = await DioClient()
          .get(
            url: ApiUrl.getCustomer,
            params: {
              "Date": dateTimeConverter(
                inputTime: currentDateTime.toString(),
                outputFormat: "yyyy/MM/dd",
              ),
              "CompanyId": companyID,
            },
          )
          .catchError(handleError);
      kLog("customer res ${jsonEncode(response)}");
      if (response == null) {
        showEmptyWidget();
        return;
      }
      if (response.isEmpty) {
        customers.clear();
        sortedCustomers.clear();

        showEmptyWidget();
        return;
      }
      customers.assignAll(
        (response as List).map((e) => CustomerModel.fromJson(e)).toList(),
      );
      sortedCustomers.addAll(customers);
      await MyHive.saveAllCustomers(customers);

      if (customers.isEmpty) {
        showEmptyWidget();
      }
    } else {
      var savedCustomers = MyHive.getAllCustomers();

      if (savedCustomers.isNotEmpty) {
        customers.assignAll(savedCustomers);
        sortedCustomers.assignAll(savedCustomers);

        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        customers.clear();
        savedCustomers.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;

        showEmptyWidget();
      }
    }
  }

  void showEmptyWidget() {
    isCustomerEmpty.value = true;
  }

  /// ─── Customer appointment history (GetCustomerAppointments) ───
  /// Paginated history of one customer's appointments. Shown under the CSL
  /// tab screen (via AppointmentController.customerController) and the
  /// Customers drawer tab → customer details.
  final customerAppointmentHistory = RxList<Appointments>();
  final isCustomerHistoryLoading = RxBool(false);
  final hasMoreCustomerHistory = RxBool(false);
  int _customerHistoryPage = 1;
  static const int _customerHistoryPageSize = 1000;

  /// The customer/site of the last history request — load-more must ask for
  /// the same page set the initial fetch used.
  dynamic _historyCustomerId;
  int _historySiteId = 0;

  /// Fresh history for [customerId] (page 1). Pass [siteId] to scope the
  /// history to one customer site; 0 means all sites.
  Future<void> getCustomerAppointments({
    dynamic customerId,
    int siteId = 0,
  }) async {
    if (customerId == null || customerId.toString().isEmpty) return;
    _historyCustomerId = customerId;
    _historySiteId = siteId;
    _customerHistoryPage = 1;
    hasMoreCustomerHistory.value = false;
    isCustomerHistoryLoading.value = true;
    customerAppointmentHistory.clear();
    await _fetchCustomerAppointments();
  }

  /// Next page for the customer/site of the last [getCustomerAppointments].
  Future<void> loadMoreCustomerAppointments() async {
    if (isCustomerHistoryLoading.value || !hasMoreCustomerHistory.value) return;
    isCustomerHistoryLoading.value = true;
    await _fetchCustomerAppointments(loadMore: true);
  }

  Future<void> _fetchCustomerAppointments({bool loadMore = false}) async {
    try {
      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = MySharedPref.getCompanyID();
        final year = DateTime.now().year;

        var response = await DioClient()
            .get(
              url: ApiUrl.getCustomerAppointmentsUrl,
              params: {
                "companyId": companyID,
                // The API takes a numeric id; customer ids are stored as
                // strings locally, so parse when possible.
                "customerId":
                    int.tryParse("$_historyCustomerId") ?? _historyCustomerId,
                "siteId": _historySiteId,
                "statusId": "",
                "fromDate": "$year-01-01",
                "toDate": "$year-12-31",
                "pageNumber": _customerHistoryPage,
                "pageSize": _customerHistoryPageSize,
              },
            )
            .catchError(handleError);
        kLog('extra appt.response: $response');
        // Some .asmx endpoints wrap the list; unwrap the common envelopes
        // before parsing so either shape works.
        dynamic data = response;
        if (data is Map) {
          for (final key in const ["d", "Data", "data", "Result", "result"]) {
            if (data[key] is List) {
              data = data[key];
              break;
            }
          }
        }

        final fetched = (data is List)
            ? data.map((e) => Appointments.fromJson(e)).toList()
            : <Appointments>[];

        // Skip rows already in the list: guards against a server that caps
        // pageSize and keeps returning the same page forever.
        final existingIds = customerAppointmentHistory
            .map((a) => a.apptID)
            .toSet();
        final fresh = fetched
            .where((a) => !existingIds.contains(a.apptID))
            .toList();

        if (loadMore) {
          customerAppointmentHistory.addAll(fresh);
        } else {
          customerAppointmentHistory.assignAll(fetched);
        }

        hasMoreCustomerHistory.value =
            fetched.length >= _customerHistoryPageSize && fresh.isNotEmpty;
        if (hasMoreCustomerHistory.value) {
          _customerHistoryPage += 1;
        }
      } else {
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
      }
    } catch (e, s) {
      kLog(e);
      kLog(s);
    } finally {
      isCustomerHistoryLoading.value = false;
    }
  }

  @override
  void onReady() async {
    await getCustomers();
    super.onReady();
  }
}
