import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/search_text_field.dart';
import 'package:xinator_fsm_pro/app/modules/billAbleItem/controllers/billable_item_controller.dart';

import '../../../../config/theme/light_theme_colors.dart';

class BillableItemsMobileScreen extends GetView<BillableItemController> {
  BillableItemsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log(controller.searchTextController.value.text, name: "text editing text");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billable Items"),
        actions: [
          IconButton(
            onPressed: () {
              // Sync action
            },
            icon: const Icon(Icons.sync, color: LightThemeColors.appBlackColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: null,
                      decoration: const InputDecoration(
                        labelText: 'Select Item',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text("All")),
                        ...controller.categories.map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            )),
                      ],
                      onChanged: (val) {
                        controller.selectedItem.value = val ?? 'All';
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SearchTextField(
                      textEditingController:
                          controller.searchTextController.value,
                      hint: 'Search...',
                      submit: null,
                      clearing: null,
                      isClearButtonVisible: false,
                      isSearchButtonVisible: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...controller.filteredItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.hardEdge,
                      borderOnForeground: true,
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Icon(
                                Icons.edit,
                                color: LightThemeColors.primaryColor,
                              )
                            ],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildDetailRow(
                                  title: 'Category', value: item['category']),
                              _buildDetailRow(
                                  title: 'Desc',
                                  value: item['description'] != ''
                                      ? item['description']
                                      : 'N/A'),
                              _buildDetailRow(title: 'SKU', value: item['sku']),
                              _buildDetailRow(
                                  title: 'Price', value: item['price']),
                              _buildDetailRow(
                                  title: 'Taxable',
                                  value: item['taxable'],
                                  isDividerShow: false),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailRow(
    {String? title, String? value, bool isDividerShow = true}) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "$title:",
                maxLines: 2,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(value ?? ''),
            ),
          ],
        ),
        if (isDividerShow)
          Divider(
            color: Colors.grey.shade300,
            height: 20,
            thickness: 3,
          ),
      ],
    ),
  );
}
