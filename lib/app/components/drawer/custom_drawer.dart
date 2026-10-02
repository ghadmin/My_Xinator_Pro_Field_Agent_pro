//ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'drawer_menu_content.dart';
import 'tablet_shell_scope.dart';

/// Drawer hosting the shared menu, hidden until opened (hamburger tap or
/// edge swipe).
///
/// Standalone (phone routes): items push their route via Get.toNamed.
/// Hosted by TabletShellView ([TabletShellScope]): items swap the shell's
/// screen instead, and the active entry comes from the scope's selection.
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.indexClicked});
  final int indexClicked;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shell = TabletShellScope.maybeOf(context);
    // Tablet width is a literal (like the old side rail): a 230.w drawer
    // shrank with ScreenUtil's scaleWidth when the window was narrower than
    // the launch design size (iPad Split View → ~200px) and the profile row
    // overflowed 16px. Phone (≤600) keeps the default 304px drawer.
    return Drawer(
      width: size.width > 600 ? 250 : null,
      child: DrawerMenuContent(
        indexClicked: shell?.selectedIndex ?? indexClicked,
        onItemTap: shell == null
            ? null
            : (indexNumber) {
                Get.back(); // close the drawer, then swap the hosted screen
                shell.onItemTap(indexNumber);
              },
      ),
    );
  }
}
