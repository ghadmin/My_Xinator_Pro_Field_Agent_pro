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
import '../models/item_bundle_model.dart';

enum SearchByType { name, group, bundle }

extension SearchByTypeExtension on SearchByType {
  String get displayName {
    switch (this) {
      case SearchByType.name:
        return "Name";
      case SearchByType.group:
        return "Group";
      case SearchByType.bundle:
        return "Bundle";
    }
  }
}

class ItemController extends GetxController with ExceptionHandler {
  RxBool isItemsEmpty = false.obs;
  RxBool isItemGroupsEmpty = false.obs;
  RxBool isItemBundlesEmpty = false.obs;

  /// API ///
  final items = RxList<ItemListModel>();
  final itemGroups = RxList<ItemGroupModel>();
  final itemBundles = RxList<ItemBundleModel>();
  final selectedItemGroupItems = Rx<ItemGroupModel?>(null);
  final Rx<ItemGroupModel?> selectedItemGroup = Rx<ItemGroupModel?>(null);
  final Rx<ItemBundleModel?> selectedItemBundle = Rx<ItemBundleModel?>(null);
  final TextEditingController sortTextController = TextEditingController();
  final sortedItems = RxList<ItemListModel>();

  /// Search and Filter logic (same as billable items view)
  final Rx<SearchByType> searchByType = SearchByType.name.obs;
  final List<SearchByType> searchOptions = SearchByType.values;

  /// Pagination ///
  final RxInt totalItems = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreItems = true.obs;

  Future<void> getItems(bool isShowLoading) async {
    if (isShowLoading) showLoading(debugInfo: "getItems - Start");
    isItemsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .get(
            url: ApiUrl.getItems,
            params: {"CompanyId": companyID, 'pageNumber': 1, 'pageSize': 1000},
          )
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

      // Handle paginated response format
      List<dynamic> itemsList;
      if (response is Map && response.containsKey('Items')) {
        // New paginated format: {Items: [...], PageNumber: 1, PageSize: 1000, TotalItems: 53}
        itemsList = response['Items'];
        kLog('Total items count: ${response['TotalItems']}');
      } else if (response is List) {
        // Legacy format: direct array
        itemsList = response;
      } else {
        // Unexpected format
        items.clear();
        sortedItems.clear();
        if (isShowLoading) {
          hideLoading(debugInfo: "getItems - Invalid response format");
        }
        showEmptyWidget();
        return;
      }

      // Filter out deleted items and parse
      final parsedItems = itemsList
          .where((itemJson) => !(itemJson['IsDeleted'] == true))
          .map((e) => ItemListModel.fromJson(e))
          .toList();

      items.assignAll(parsedItems);
      sortItems();
      await MyHive.saveItemList(items);
      if (isShowLoading) hideLoading(debugInfo: "getItems - Success");
      if (items.isEmpty) {
        showEmptyWidget();
      }
    } else {
      var savedItems = MyHive.getAllItemList();

      if (savedItems.isNotEmpty) {
        items.assignAll(savedItems);
        sortItems();
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

  Future<void> getItemGroups() async {
    showLoading(debugInfo: "getItemGroups - Start");
    isItemGroupsEmpty.value = false;
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .get(
            url: ApiUrl.getItemGroups,
            params: {"companyId": companyID},
          ) // Correct: lowercase companyId
          .catchError(handleError);
      kLog("getItemGroups - Response. $response");
      if (response == null) {
        hideLoading(debugInfo: "getItemGroups - Response null");

        showItemGroupsEmptyWidget();
        return;
      }
      if (response.isEmpty) {
        itemGroups.clear();

        hideLoading(debugInfo: "getItemGroups - Response empty");

        showItemGroupsEmptyWidget();
        return;
      }

      // Server returned an unexpected body (e.g. an HTML error page instead
      // of JSON) — treat it as an unavailable service, not an empty result.
      if (response is! List) {
        itemGroups.clear();
        hideLoading(debugInfo: "getItemGroups - Unexpected response format");
        MySnackBar.showErrorToast(
          message: "Service is currently unavailable. Please try again later.",
        );
        showItemGroupsEmptyWidget();
        return;
      }

      itemGroups.assignAll(
        response.map((e) => ItemGroupModel.fromJson(e)).toList(),
      );
      await MyHive.saveItemGroupList(itemGroups);
      hideLoading(debugInfo: "getItemGroups - Success");
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

        hideLoading(debugInfo: "getItemGroups - No network - No cached data");

        showItemGroupsEmptyWidget();
      }
    }
  }

  Future<void> getItemGroupById({
    int? pageNumber,
    int? pageSize,
    bool isShowLoading = true,
    bool appendItems = false,
  }) async {
    // Use pagination state if not provided
    final page = pageNumber ?? currentPage.value;
    final size = pageSize ?? this.pageSize.value;

    if (isShowLoading) showLoading(debugInfo: "getItemGroupById - Start");

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .get(
            url: ApiUrl.getItemGroupById,
            params: {
              "id": selectedItemGroup.value?.id,
              "companyId": companyID,
              "pageNumber": page,
              "pageSize": size,
            },
          )
          .catchError(handleError);

      if (response == null || response == false) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemGroupById - Response null");
        }
        MySnackBar.showErrorToast(message: "Failed to load item group details");
        return;
      }

      if (response is! Map) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemGroupById - Unexpected response format");
        }
        MySnackBar.showErrorToast(
          message: "Service is currently unavailable. Please try again later.",
        );
        return;
      }

      final itemGroup = ItemGroupModel.fromJson(response);

      // Update pagination info from response
      if (response.containsKey('TotalItems')) {
        totalItems.value = response['TotalItems'] ?? 0;
      }
      if (response.containsKey('PageNumber')) {
        currentPage.value = response['PageNumber'] ?? 1;
      }
      if (response.containsKey('PageSize')) {
        this.pageSize.value = response['PageSize'] ?? 20;
      }

      // Check if there are more items to load
      final totalLoaded = itemGroup.items?.length ?? 0;
      hasMoreItems.value = totalLoaded < totalItems.value;

      // Update the item group in the list if it exists
      final existingIndex = itemGroups.indexWhere(
        (group) => group.id == selectedItemGroup.value?.id,
      );
      if (existingIndex != -1) {
        itemGroups[existingIndex] = itemGroup;
      }

      selectedItemGroup.value = itemGroup;
      currentPage.value = page;
      this.pageSize.value = size;
      sortItems();

      if (isShowLoading) hideLoading(debugInfo: "getItemGroupById - Success");
    } else {
      MySnackBar.showErrorToast(message: "No network available");
      if (isShowLoading) {
        hideLoading(debugInfo: "getItemGroupById - No network");
      }
    }
  }

  Future<void> loadMoreGroupItems() async {
    if (isLoadingMore.value || !hasMoreItems.value) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    await getItemGroupById(
      pageNumber: nextPage,
      isShowLoading: false,
    );

    isLoadingMore.value = false;
  }

  /// Auto-selects the first group (if any) and loads its items.
  /// The user can still change the selection from the dropdown.
  Future<void> autoSelectFirstGroup() async {
    if (itemGroups.isEmpty) return;
    final firstGroup = itemGroups.first;
    selectedItemGroup.value = firstGroup;
    if (firstGroup.id != null) {
      await getItemGroupById(isShowLoading: false);
    }
  }

  Future<void> getBundles(bool isShowLoading) async {
    if (isShowLoading) showLoading(debugInfo: "getBundles - Start");
    isItemBundlesEmpty.value = false;

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .post(
            url: ApiUrl.getBundles,
            body: {"companyId": companyID},
          ) // Correct: lowercase companyId
          .catchError(handleError);

      kLog("getBundles - Response: $response");

      if (response == null) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getBundles - Response null");
        }
        showItemBundlesEmptyWidget();
        return;
      }

      // Handle HTTP 500 error case specific to bundles
      if (response is Map && response.containsKey('error')) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getBundles - Server error");
        }
        MySnackBar.showErrorToast(
          message: "Error loading bundles: ${response['error']}",
        );
        showItemBundlesEmptyWidget();
        return;
      }

      if (response.isEmpty) {
        itemBundles.clear();
        if (isShowLoading) {
          hideLoading(debugInfo: "getBundles - Response empty");
        }
        showItemBundlesEmptyWidget();
        return;
      }

      // Server returned an unexpected body (e.g. an HTML error page instead
      // of JSON) — treat it as an unavailable service, not an empty result.
      if (response is! List) {
        itemBundles.clear();
        if (isShowLoading) {
          hideLoading(debugInfo: "getBundles - Unexpected response format");
        }
        MySnackBar.showErrorToast(
          message: "Service is currently unavailable. Please try again later.",
        );
        showItemBundlesEmptyWidget();
        return;
      }

      itemBundles.assignAll(
        response.map((e) => ItemBundleModel.fromJson(e)).toList(),
      );
      await MyHive.saveItemBundleList(itemBundles);

      if (isShowLoading) {
        hideLoading(debugInfo: "getBundles - Success");
      }

      if (itemBundles.isEmpty) {
        showItemBundlesEmptyWidget();
      }
    } else {
      // Try to load from cache
      var savedItemBundles = MyHive.getAllItemBundles();

      if (savedItemBundles.isNotEmpty) {
        itemBundles.assignAll(savedItemBundles);
        hideLoading(debugInfo: "getBundles - No network - Using cached");
        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        itemBundles.clear();
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;
        if (isShowLoading) {
          hideLoading(debugInfo: "getBundles - No network - No cached data");
        }
        showItemBundlesEmptyWidget();
      }
    }
  }

  Future<void> getItemsByBundleId({
    int? pageNumber,
    int? pageSize,
    bool isShowLoading = true,
  }) async {
    // Use pagination state if not provided
    final page = pageNumber ?? currentPage.value;
    final size = pageSize ?? this.pageSize.value;

    if (isShowLoading) {
      showLoading(debugInfo: "getItemsByBundleId - Start");
    }

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = MySharedPref.getCompanyID();
      var response = await DioClient()
          .post(
            url: ApiUrl.getItemsByBundleId,
            body: {
              "id": selectedItemBundle.value?.id,
              "companyId": companyID,
              "pageNumber": page,
              "pageSize": size,
            },
          )
          .catchError(handleError);

      if (response == null || response == false) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemsByBundleId - Response null");
        }
        MySnackBar.showErrorToast(message: "Failed to load bundle details");
        return;
      }

      // Handle HTTP 500 error case specific to bundles
      if (response is Map && response.containsKey('error')) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemsByBundleId - Server error");
        }
        MySnackBar.showErrorToast(
          message: "Error loading bundle items: ${response['error']}",
        );
        return;
      }

      if (response is! Map) {
        if (isShowLoading) {
          hideLoading(debugInfo: "getItemsByBundleId - Unexpected response format");
        }
        MySnackBar.showErrorToast(
          message: "Service is currently unavailable. Please try again later.",
        );
        return;
      }

      final itemBundle = ItemBundleModel.fromJson(response);

      // Update pagination info from response
      if (response.containsKey('TotalItems')) {
        totalItems.value = response['TotalItems'] ?? 0;
      }
      if (response.containsKey('PageNumber')) {
        currentPage.value = response['PageNumber'] ?? 1;
      }
      if (response.containsKey('PageSize')) {
        this.pageSize.value = response['PageSize'] ?? 20;
      }

      // Check if there are more items to load
      final totalLoaded = itemBundle.items?.length ?? 0;
      hasMoreItems.value = totalLoaded < totalItems.value;

      // Update the bundle in the list if it exists
      final existingIndex = itemBundles.indexWhere((bundle) => bundle.id == itemBundle.id);
      if (existingIndex != -1) {
        itemBundles[existingIndex] = itemBundle;
      }

      selectedItemBundle.value = itemBundle;
      currentPage.value = page;
      this.pageSize.value = size;
      sortItems();

      if (isShowLoading) {
        hideLoading(debugInfo: "getItemsByBundleId - Success");
      }
    } else {
      MySnackBar.showErrorToast(message: "No network available");
      if (isShowLoading) {
        hideLoading(debugInfo: "getItemsByBundleId - No network");
      }
    }
  }

  Future<void> loadMoreBundleItems() async {
    if (isLoadingMore.value || !hasMoreItems.value) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    await getItemsByBundleId(
      pageNumber: nextPage,
      isShowLoading: false,
    );

    isLoadingMore.value = false;
  }

  /// Auto-selects the first bundle (if any) and loads its items.
  /// The user can still change the selection from the dropdown.
  Future<void> autoSelectFirstBundle() async {
    if (itemBundles.isEmpty) return;
    final firstBundle = itemBundles.first;
    selectedItemBundle.value = firstBundle;
    if (firstBundle.id != null) {
      await getItemsByBundleId(isShowLoading: false);
    }
  }

  void sortItems() {
    // Source list depends on the current search-by mode; the view always
    // renders [sortedItems], so search filters in every mode.
    final List<ItemListModel> source;
    switch (searchByType.value) {
      case SearchByType.name:
        source = items;
        break;
      case SearchByType.group:
        source = selectedItemGroup.value?.items ?? const <ItemListModel>[];
        break;
      case SearchByType.bundle:
        source = selectedItemBundle.value?.items ?? const <ItemListModel>[];
        break;
    }

    final query = sortTextController.text.trim().toLowerCase();
    final list = query.isEmpty
        ? source
        : source
            .where(
              (item) => (item.name ?? '').toLowerCase().contains(query),
            )
            .toList();
    sortedItems.assignAll(list);
  }

  /// Pagination Methods ///
  int get totalPages => (totalItems.value / pageSize.value).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;

      // Reload data based on current selection
      if (selectedItemGroup.value != null) {
        getItemGroupById(pageNumber: page, isShowLoading: false);
      } else if (selectedItemBundle.value != null) {
        getItemsByBundleId(pageNumber: page, isShowLoading: false);
      }
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      goToPage(currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 1);
    }
  }

  void changePageSize(int size) {
    pageSize.value = size;
    currentPage.value = 1; // Reset to first page when changing page size

    // Reload data based on current selection
    if (selectedItemGroup.value != null) {
      getItemGroupById(pageNumber: 1, pageSize: size, isShowLoading: false);
    } else if (selectedItemBundle.value != null) {
      getItemsByBundleId(pageNumber: 1, pageSize: size, isShowLoading: false);
    }
  }

  void resetPagination() {
    currentPage.value = 1;
    totalItems.value = 0;
    pageSize.value = 20;
    hasMoreItems.value = true;
  }

  void showEmptyWidget() {
    isItemsEmpty.value = true;
  }

  void showItemGroupsEmptyWidget() {
    isItemGroupsEmpty.value = true;
  }

  void showItemBundlesEmptyWidget() {
    isItemBundlesEmpty.value = true;
  }

  @override
  void onReady() async {
    await getItems(false);
    // await getItemGroups(false);
    super.onReady();
  }
}
