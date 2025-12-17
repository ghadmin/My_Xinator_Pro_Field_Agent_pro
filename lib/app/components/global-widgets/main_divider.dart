import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/light_theme_colors.dart';

class MainDivider extends StatelessWidget {
  const MainDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1.5.sp,
        thickness: 1.5.sp,
        color: LightThemeColors.dividerColor);
  }
}
