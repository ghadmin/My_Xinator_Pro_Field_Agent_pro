import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/item_list_model.dart';

class ItemController extends GetxController with ExceptionHandler {
  RxBool isItemsEmpty = false.obs;

  /// API ///
  final items = RxList<ItemListModel>();
  final TextEditingController sortTextController = TextEditingController();
  final sortedItems = RxList<ItemListModel>();

  Future<void> getItems(bool isShowLoading) async {
    if (isShowLoading) showLoading(debugInfo: "getItems - Start");
    isItemsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient().get(
          url: ApiUrl.getItems,
          params: {"CompanyId": companyID}).catchError(handleError);

      if (response == null) {
        if (isShowLoading) hideLoading(debugInfo: "getItems - Response null");
        showEmptyWidget();
        return;
      }
      if (response.isEmpty) {
        items.clear();
        sortedItems.clear();
        if (isShowLoading) hideLoading(debugInfo: "getItems - Response empty");
        showEmptyWidget();
        return;
      }

      items.assignAll(
        (response as List).map((e) => ItemListModel.fromJson(e)).toList(),
      );
      sortedItems.addAll(items);
      await MyHive.saveItemList(items);
      if (isShowLoading) hideLoading(debugInfo: "getItems - Success");
      if (items.isEmpty) {
        showEmptyWidget();
      }
    } else {
      var savedItems = MyHive.getAllItemList();

      if (savedItems.isNotEmpty) {
        items.assignAll(savedItems);
        sortedItems.addAll(savedItems);
        hideLoading(debugInfo: "getItems - No network - Using cached");
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        items.clear();
        sortedItems.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;
        if (isShowLoading)
          hideLoading(debugInfo: "getItems - No network - No cached data");
        showEmptyWidget();
      }
    }
  }

  void sortItems() {
    if (items.isEmpty) return;

    if (sortTextController.text.isEmpty) {
      sortedItems.clear();
      sortedItems.addAll(items);
    } else {
      final list = items.where((p0) {
        return p0.name!.toLowerCase().contains(
              sortTextController.text.toLowerCase(),
            );
      }).toList();
      sortedItems.clear();
      sortedItems.addAll(list);
    }
  }

  void showEmptyWidget() {
    isItemsEmpty.value = true;
  }

  @override
  void onReady() async {
    await getItems(false);
    super.onReady();
  }
}
