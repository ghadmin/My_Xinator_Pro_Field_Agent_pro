import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/modules/item/models/item_list_model.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';

class ItemController extends GetxController with ExceptionHandler {
  RxBool isItemsEmpty = false.obs;

  /// API ///
  final items = RxList<ItemListModel>();
  final TextEditingController sortTextController = TextEditingController();
  final sortedItems = RxList<ItemListModel>();

  getItems() async {
    showLoading();
    isItemsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();
      var response = await DioClient().get(
        url: ApiUrl.getItems,
        params: {
          "CompanyId": companyID,
        },
      ).catchError(handleError);

      if (response == null) {
        hideLoading();
        showEmptyWidget();
        return;
      }
      if (response.isEmpty) {
        items.clear();
        sortedItems.clear();
        hideLoading();
        showEmptyWidget();
        return;
      }

      items.assignAll(
          (response as List).map((e) => ItemListModel.fromJson(e)).toList());
      sortedItems.addAll(items);
      await MyHive.saveItemList(items);
      hideLoading();
      if (items.isEmpty) {
        showEmptyWidget();
      }
    } else {
      var savedItems = MyHive.getAllItemList();

      if (savedItems.isNotEmpty) {
        items.assignAll(savedItems);
        sortedItems.addAll(savedItems);
        hideLoading();
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        items.clear();
        sortedItems.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;
        hideLoading();
        showEmptyWidget();
      }
    }
  }

  sortItems() {
    log("ontap  ${items.length}");
    if (items.isEmpty) return;

    if (sortTextController.text.isEmpty) {
      sortedItems.clear();
      final alphabetSorted = items.toList()
        ..sort((a, b) => a.name!.compareTo(b.name!));
      sortedItems.addAll(alphabetSorted);
    } else {
      final list = items.where(
        (p0) {
          return p0.name!
              .toLowerCase()
              .contains(sortTextController.text.toLowerCase());
        },
      ).toList()
        ..sort((a, b) => a.name!.compareTo(b.name!));
      sortedItems.clear();
      sortedItems.addAll(list);
    }

    for (var element in sortedItems) {
      print("qbo sorted item ${element.qboId}");
    }
  }

  void showEmptyWidget() {
    isItemsEmpty.value = true;
  }

  @override
  void onReady() async {
    await getItems();
    super.onReady();
  }
}
