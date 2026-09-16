import 'package:flutter/material.dart';

/// Tablet/phone detection and shared responsive building blocks.
///
/// Two detection layers with different lifecycles:
///  * [AppDevice] — computed once at launch (pre-runApp). Used for the
///    orientation lock and ScreenUtil designSize, which must not flip mid-
///    session. Falls back to phone behaviour when the view metrics are not
///    ready yet (Size.zero), so the default stays "exactly as today".
///  * [TabletContext.isTabletLayout] — evaluated per build from MediaQuery,
///    so layout branches follow rotation and window resizing (iPad Split
///    View / Stage Manager).
///
/// The 600-logical-pixel breakpoint matches the precedent already used in
/// `CustomDrawer` (`size.width > 600`).
class AppDevice {
  AppDevice._();

  static bool? _isTablet;
  static double _shortestSide = 0;

  /// True when the device is a tablet/iPad. Computed lazily from the first
  /// platform view's logical size; cached for the app lifetime.
  static bool get isTabletDevice {
    if (_isTablet != null) return _isTablet!;
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    _shortestSide = size.shortestSide;
    // Size.zero (metrics not ready yet) lands below the breakpoint and keeps
    // the phone behaviour — the safe default.
    _isTablet = _shortestSide >= 600;
    return _isTablet!;
  }

  /// Shortest logical side in dp at launch. Only meaningful when
  /// [isTabletDevice] is true; 0 otherwise.
  static double get shortestLogicalSide {
    if (_isTablet == null) isTabletDevice;
    return _shortestSide;
  }
}

extension TabletContext on BuildContext {
  /// Runtime layout breakpoint: true on tablets (or any window at least
  /// 600dp on its shortest side). Re-evaluates on rotation/resize.
  bool get isTabletLayout => MediaQuery.sizeOf(this).shortestSide >= 600;
}

/// Constrains content to [maxWidth], centered, on tablets only.
///
/// On phones (or narrow windows) it returns [child] untouched, so existing
/// phone layouts are unaffected. Alignment is top-center so scrollable form
/// content starts at the top as expected.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (!context.isTabletLayout) return child;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// List on phones, card grid on tablets.
///
/// Phone rendering is a plain `ListView.separated` — identical to the call
/// sites it replaces. On tablets the same [itemBuilder] output is laid out
/// in a grid whose column count follows the available width
/// ([tabletMaxColumnExtent] caps how wide a single card may get).
class AdaptiveListGrid extends StatelessWidget {
  const AdaptiveListGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.tabletMaxColumnExtent = 420,
    /// width / height of a grid cell; tune per screen to fit its card.
    this.tabletChildAspectRatio = 3.2,
    this.tabletSpacing = 12,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;
  final double tabletMaxColumnExtent;
  final double tabletChildAspectRatio;
  final double tabletSpacing;

  @override
  Widget build(BuildContext context) {
    if (!context.isTabletLayout) {
      return ListView.separated(
        padding: padding,
        physics: physics,
        controller: controller,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder ?? (_, _) => const SizedBox.shrink(),
      );
    }
    return GridView.builder(
      padding: padding,
      physics: physics,
      controller: controller,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: tabletMaxColumnExtent,
        childAspectRatio: tabletChildAspectRatio,
        crossAxisSpacing: tabletSpacing,
        mainAxisSpacing: tabletSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
