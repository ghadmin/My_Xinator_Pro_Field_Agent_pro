import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/customer_model.dart';

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
          p0.email
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
      var companyID = await MySharedPref.getCompanyID();
      var currentDateTime = DateTime.now();
      var response = await DioClient().get(
        url: ApiUrl.getCustomer,
        params: {
          "Date": dateTimeConverter(
              inputTime: currentDateTime.toString(),
              outputFormat: "yyyy/MM/dd"),
          "CompanyId": companyID,
        },
      ).catchError(handleError);
      log("customer res ${jsonEncode(response)}");
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
          (response as List).map((e) => CustomerModel.fromJson(e)).toList());
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

  @override
  void onReady() async {
    await getCustomers();
    super.onReady();
  }
}
