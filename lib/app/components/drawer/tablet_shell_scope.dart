import 'package:flutter/material.dart';

/// Scope wrapped around the screen hosted by TabletShellView.
///
/// The hosted screens keep their standard overlay drawer (hamburger tap) —
/// the shell itself draws no chrome. This scope tells the screens'
/// [CustomDrawer] that it is running inside the shell, so a menu tap swaps
/// the hosted screen ([onItemTap]) instead of pushing a route, and
/// [selectedIndex] keeps the active entry highlighted (the shell owns the
/// selection; the drawer reads it from here).
class TabletShellScope extends InheritedWidget {
  const TabletShellScope({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required super.child,
  });

  /// Menu index currently hosted by the shell (the indexNumber values in
  /// DrawerMenuContent).
  final int selectedIndex;

  /// Menu tap → swap the hosted screen (TabletShellView._select).
  final ValueChanged<int> onItemTap;

  static TabletShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabletShellScope>();

  @override
  bool updateShouldNotify(TabletShellScope oldWidget) =>
      oldWidget.selectedIndex != selectedIndex;
}
