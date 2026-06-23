import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/item_list_model.dart';
import '../models/item_group_model.dart';

class ItemController extends GetxController with ExceptionHandler {
  RxBool isItemsEmpty = false.obs;
  RxBool isItemGroupsEmpty = false.obs;

  /// API ///
  final items = RxList<ItemListModel>();
  final itemGroups = RxList<ItemGroupModel>();
  final selectedItemGroupItems = Rx<ItemGroupModel?>(null);
  final Rx<ItemGroupModel?> selectedItemGroup = Rx<ItemGroupModel?>(null);
  final TextEditingController sortTextController = TextEditingController();
  final sortedItems = RxList<ItemListModel>();

  Future<void> getItems(bool isShowLoading) async {
    if (isShowLoading) showLoading(debugInfo: "getItems - Start");
    isItemsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .get(url: ApiUrl.getItems, params: {"CompanyId": companyID})
          .catchError(handleError);

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
        if (isShowLoading) {
          hideLoading(debugInfo: "getItems - No network - No cached data");
        }
        showEmptyWidget();
      }
    }
  }

  Future<void> getItemGroups(bool isShowLoading) async {
    if (isShowLoading) showLoading(debugInfo: "getItemGroups - Start");
    isItemGroupsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .post(url: ApiUrl.getItemGroups, body: {"companyId": companyID})
          .catchError(handleError);
      kLog(response + "getItemGroups - Response");
      if (response == null) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemGroups - Response null");
        }
        showItemGroupsEmptyWidget();
        return;
      }
      if (response.isEmpty) {
        itemGroups.clear();
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemGroups - Response empty");
        }
        showItemGroupsEmptyWidget();
        return;
      }

      itemGroups.assignAll(
        (response as List).map((e) => ItemGroupModel.fromJson(e)).toList(),
      );
      await MyHive.saveItemGroupList(itemGroups);
      if (isShowLoading) hideLoading(debugInfo: "getItemGroups - Success");
      if (itemGroups.isEmpty) {
        showItemGroupsEmptyWidget();
      }
    } else {
      var savedItemGroups = MyHive.getAllItemGroups();

      if (savedItemGroups.isNotEmpty) {
        itemGroups.assignAll(savedItemGroups);
        hideLoading(debugInfo: "getItemGroups - No network - Using cached");
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        itemGroups.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemGroups - No network - No cached data");
        }
        showItemGroupsEmptyWidget();
      }
    }
  }

  Future<void> getItemGroupById({
    required int id,
    int pageNumber = 1,
    int pageSize = 20,
    bool isShowLoading = true,
  }) async {
    if (isShowLoading) showLoading(debugInfo: "getItemGroupById - Start");

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .post(
            url: ApiUrl.getItemGroupById,
            body: {
              "id": id,
              "companyId": companyID,
              "pageNumber": pageNumber,
              "pageSize": pageSize,
            },
          )
          .catchError(handleError);

      if (response == null || response == false) {
        if (isShowLoading)
          hideLoading(debugInfo: "getItemGroupById - Response null");
        MySnackBar.showErrorToast(message: "Failed to load item group details");
        return;
      }

      final itemGroup = ItemGroupModel.fromJson(response);

      // Update the item group in the list if it exists
      final existingIndex = itemGroups.indexWhere((group) => group.id == id);
      if (existingIndex != -1) {
        itemGroups[existingIndex] = itemGroup;
      }

      selectedItemGroup.value = itemGroup;

      if (isShowLoading) hideLoading(debugInfo: "getItemGroupById - Success");
    } else {
      MySnackBar.showErrorToast(message: "No network available");
      if (isShowLoading)
        hideLoading(debugInfo: "getItemGroupById - No network");
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

  void showItemGroupsEmptyWidget() {
    isItemGroupsEmpty.value = true;
  }

  @override
  void onReady() async {
    await getItems(false);
    // await getItemGroups(false);
    super.onReady();
  }
}
