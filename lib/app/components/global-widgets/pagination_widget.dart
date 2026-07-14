import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Pagination controller to manage page state
class PaginationController extends GetxController {
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalPages = 1.obs;

  void updatePagination(int totalItems) {
    totalPages.value = (totalItems / itemsPerPage.value).ceil();
    // Ensure current page is valid
    if (currentPage.value > totalPages.value) {
      currentPage.value = totalPages.value > 0 ? totalPages.value : 1;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void changeItemsPerPage(int value) {
    itemsPerPage.value = value;
    currentPage.value = 1; // Reset to first page when changing items per page
  }

  List<int> getVisiblePages() {
    List<int> pages = [];
    int total = totalPages.value;
    int current = currentPage.value;

    // Show all pages if total is small
    if (total <= 7) {
      for (int i = 1; i <= total; i++) {
        pages.add(i);
      }
    } else {
      // Always show first page
      pages.add(1);

      // Show pages around current page
      if (current <= 4) {
        // Near the beginning
        for (int i = 2; i <= 5; i++) {
          pages.add(i);
        }
        if (total > 6) pages.add(-1); // Ellipsis
        if (total > 5) pages.add(total);
      } else if (current >= total - 3) {
        // Near the end
        if (total > 5) pages.add(-1); // Ellipsis
        for (int i = total - 4; i <= total; i++) {
          pages.add(i);
        }
      } else {
        // Middle
        if (current > 3) pages.add(-1); // Ellipsis
        for (int i = current - 1; i <= current + 1; i++) {
          pages.add(i);
        }
        if (current < total - 2) pages.add(-1); // Ellipsis
        pages.add(total);
      }
    }

    return pages;
  }
}

/// Reusable pagination widget
class PaginationWidget extends StatelessWidget {
  final PaginationController controller;
  final Function(int)? onPageChanged;
  final bool showItemsPerPageSelector;

  const PaginationWidget({
    super.key,
    required this.controller,
    this.onPageChanged,
    this.showItemsPerPageSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Items per page selector
            if (showItemsPerPageSelector)
              Row(
                children: [
                  Text('Items per page:', style: theme.textTheme.bodySmall),
                  SizedBox(width: 8.w),
                  _buildItemsPerPageDropdown(theme),
                ],
              ),

            // Page navigation
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavigationButton(
                    icon: Icons.chevron_left,
                    onPressed: controller.currentPage.value > 1
                        ? () {
                            controller.previousPage();
                            onPageChanged?.call(controller.currentPage.value);
                          }
                        : null,
                    theme: theme,
                  ),
                  SizedBox(width: 8.w),
                  ..._buildPageNumbers(theme),
                  SizedBox(width: 8.w),
                  _buildNavigationButton(
                    icon: Icons.chevron_right,
                    onPressed:
                        controller.currentPage.value <
                            controller.totalPages.value
                        ? () {
                            controller.nextPage();
                            onPageChanged?.call(controller.currentPage.value);
                          }
                        : null,
                    theme: theme,
                  ),
                ],
              ),
            ),

            // Page info
            Text(
              'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildItemsPerPageDropdown(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<int>(
        value: controller.itemsPerPage.value,
        underline: const SizedBox.shrink(),
        isDense: true,
        items: const [5, 10, 20, 50, 100].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.changeItemsPerPage(value);
          }
        },
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: onPressed != null ? theme.primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18.sp),
        color: Colors.white,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  List<Widget> _buildPageNumbers(ThemeData theme) {
    final visiblePages = controller.getVisiblePages();
    final List<Widget> pageWidgets = [];

    for (final pageData in visiblePages) {
      if (pageData == -1) {
        // Ellipsis
        pageWidgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        );
      } else {
        final page = pageData;
        final isActive = page == controller.currentPage.value;

        pageWidgets.add(
          GestureDetector(
            onTap: () {
              controller.goToPage(page);
              onPageChanged?.call(page);
            },
            child: Container(
              width: 32.w,
              height: 32.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isActive ? theme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isActive ? theme.primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  page.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isActive ? Colors.white : theme.primaryColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return pageWidgets;
  }
}

/// Paginated ListView wrapper - makes it easy to add pagination to any ListView
class PaginatedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, int, T) itemBuilder;
  final PaginationController paginationController;
  final Widget? separatorBuilder;
  final bool showPagination;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.paginationController,
    this.separatorBuilder,
    this.showPagination = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Update pagination when items change
      paginationController.updatePagination(items.length);

      final currentPage = paginationController.currentPage.value;
      final itemsPerPage = paginationController.itemsPerPage.value;

      // Calculate items for current page
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage).clamp(0, items.length);
      final currentPageItems = items.sublist(startIndex, endIndex);

      return Column(
        children: [
          Flexible(
            child: ListView.separated(
              itemCount: currentPageItems.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) =>
                  separatorBuilder ?? const Divider(height: 1),
              itemBuilder: (context, index) {
                return itemBuilder(
                  context,
                  startIndex + index,
                  currentPageItems[index],
                );
              },
            ),
          ),
          if (showPagination && paginationController.totalPages.value > 1)
            Padding(
              padding: EdgeInsets.only(top: 16.sp),
              child: PaginationWidget(
                controller: paginationController,
                onPageChanged: (page) {
                  // Scroll to top when page changes
                  // Optional: Add scroll controller logic if needed
                },
              ),
            ),
        ],
      );
    });
  }
}
