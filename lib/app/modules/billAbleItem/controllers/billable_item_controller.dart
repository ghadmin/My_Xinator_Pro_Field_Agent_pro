import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/service/handler/exception_handler.dart';

class BillableItemController extends GetxController with ExceptionHandler {
  final selectedItem = Rx<String>('All');
  final searchTextController =
      Rx<TextEditingController>(TextEditingController());
  final categories = RxList<String>([
    'Service',
    'Parts',
    'NonInventory',
    'OtherCharge',
    'Inventory',
    'Group'
  ]);

  final items = RxList<Map<String, String>>([
    {
      "name": "Ac Repair",
      "category": "Inventory",
      "description":
          "Commercial grade large widgets	Commercial grade large widgets	",
      "sku": "4755235654",
      "price": "100",
      "taxable": "NO"
    },
    {
      "name": "Car wash",
      "category": "Inventory",
      "description": "",
      "sku": "8456986980",
      "price": "20",
      "taxable": "NO"
    },
    {
      "name": "Commercial Widgets",
      "category": "Inventory",
      "description": "Commercial grade large widgets",
      "sku": "123456",
      "price": "1500",
      "taxable": "YES"
    },
    {
      "name": "Delivery",
      "category": "Inventory",
      "description": "test",
      "sku": "D-121",
      "price": "100",
      "taxable": "NO"
    },
    {
      "name": "Hours",
      "category": "Inventory",
      "description": "Billable labor rates",
      "sku": "B-1234",
      "price": "50",
      "taxable": "NO"
    },
    {
      "name": "House Cleaning",
      "category": "Inventory",
      "description": "",
      "sku": "b31",
      "price": "45",
      "taxable": "NO"
    },
    {
      "name": "IT Service",
      "category": "Inventory",
      "description": "",
      "sku": "IS-321",
      "price": "85",
      "taxable": "NO"
    },
    {
      "name": "Mobile Body Change",
      "category": "Service",
      "description": "Mobile full body change",
      "sku": "123456789",
      "price": "5000",
      "taxable": "NO"
    },
    {
      "name": "Mobile Display Change",
      "category": "Service",
      "description": "Display Change",
      "sku": "12345678323",
      "price": "1200",
      "taxable": "NO"
    },
    {
      "name": "Mobile Service",
      "category": "Service",
      "description": "Mobile Check And Service",
      "sku": "12345678",
      "price": "750",
      "taxable": "NO"
    }

    // ... Add all other items here
  ]);

  List<Map<String, String>> get filteredItems {
    if (searchTextController.value.text.isNotEmpty) {
      return items.where((p0) {
        final matchesSearch = p0.values.any(
          (value) => (value.toLowerCase())
              .contains(searchTextController.value.text.toLowerCase()),
        );
        return matchesSearch;
      }).toList();
    }
    if (selectedItem.value == 'All') {
      return items;
    }
    return items
        .where((item) => item['category'] == selectedItem.value)
        .toList();
  }
}
