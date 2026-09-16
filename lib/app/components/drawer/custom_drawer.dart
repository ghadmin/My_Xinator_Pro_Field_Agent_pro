//ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'drawer_menu_content.dart';

/// Phone drawer: a Material [Drawer] hosting the shared menu. On tablets the
/// menu renders as a permanent side rail instead — see [AdaptiveNavShell].
class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key, required this.indexClicked});
  final int indexClicked;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      width: size.width > 600 ? 230.w : null,
      child: DrawerMenuContent(indexClicked: indexClicked),
    );
  }
}
