import 'package:flutter/material.dart';

import '../../../utils/responsive.dart';
import 'drawer_menu_content.dart';

/// Adaptive navigation shell.
///
/// Phones: pure passthrough — the wrapped content renders exactly as before.
/// Tablets: the menu is a permanent side rail on the leading edge (left in
/// LTR, right in RTL), followed by a divider and the screen body fills the
/// remaining width.
class AdaptiveNavShell extends StatelessWidget {
  AdaptiveNavShell({super.key, required this.indexClicked, required this.child});

  final int indexClicked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Phones keep the overlay drawer; the shell is a no-op there.
    if (!context.isTabletLayout) return child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 250,
          child: DrawerMenuContent(indexClicked: indexClicked, asRail: true),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: child),
      ],
    );
  }
}
