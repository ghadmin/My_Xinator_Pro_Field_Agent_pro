import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/appointment_controller.dart';

class TagSelectionScreen extends GetView<AppointmentController> {
  TagSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Get.size.width <= 440
          ? AppBar(title: Text("Select or Add Tag"), centerTitle: false)
          : PreferredSize(
              preferredSize: Size.fromHeight(40.sp),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: AppBar(
                  title: Text("Select or Add Tag"),
                  centerTitle: false,
                ),
              ),
            ),
      body: Obx(() {
        if (controller.isTaglistLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // Search field
            SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search tag...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  controller.filterTags(value);
                },
              ),
            ),

            // Tags list
            Expanded(
              child: Obx(() {
                return controller.filteredTags.isNotEmpty
                    ? ListView.builder(
                        itemCount: controller.filteredTags.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              title: Text(
                                controller.filteredTags[index].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Get.back();
                                controller.selectedTagController.value.text =
                                    controller.filteredTags[index].name;
                                controller.selectedTagId(
                                  controller.filteredTags[index].id,
                                );
                              },
                            ),
                          );
                        },
                      )
                    : const Center(child: Text("No tags found"));
              }),
            ),

            // Add New button
            SafeArea(
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showAddTagDialog(context),
                      child: controller.addNewTagLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Add New"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final newTagController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Tag"),
        content: TextField(
          controller: newTagController,
          decoration: const InputDecoration(hintText: "Enter tag name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (newTagController.text.trim().isNotEmpty) {
                Get.back(); // close input dialog
                await controller.addNewTag(newTagController.text);
                // Optional: refresh or scroll to the new tag
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
