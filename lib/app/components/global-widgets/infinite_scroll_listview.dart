import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Infinite scroll ListView that loads more items when scrolling to end
class InfiniteScrollListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, int, T) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? separatorBuilder;
  final Widget? loadingWidget;
  final Widget? noMoreItemsWidget;
  final ScrollController? scrollController;

  const InfiniteScrollListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoading = false,
    this.separatorBuilder,
    this.loadingWidget,
    this.noMoreItemsWidget,
    this.scrollController,
  });

  @override
  State<InfiniteScrollListView<T>> createState() =>
      _InfiniteScrollListViewState<T>();
}

class _InfiniteScrollListViewState<T> extends State<InfiniteScrollListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore || widget.isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: widget.items.length + (_hasMoreContent() ? 1 : 0),
      padding: EdgeInsets.zero,
      shrinkWrap: false,
      separatorBuilder: (context, index) =>
          widget.separatorBuilder ?? const Divider(height: 1),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == widget.items.length && _hasMoreContent()) {
          return _buildLoadingWidget();
        }

        // Show normal item
        return widget.itemBuilder(context, index, widget.items[index]);
      },
    );
  }

  bool _hasMoreContent() {
    return widget.hasMore || _isLoadingMore;
  }

  Widget _buildLoadingWidget() {
    if (_isLoadingMore) {
      return widget.loadingWidget ??
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Center(child: CircularProgressIndicator()),
          );
    } else if (!widget.hasMore && widget.items.isNotEmpty) {
      return widget.noMoreItemsWidget ??
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Center(
              child: Text(
                'No more items',
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
    }
    return const SizedBox.shrink();
  }
}
