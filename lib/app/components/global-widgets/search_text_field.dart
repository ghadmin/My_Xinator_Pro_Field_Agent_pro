import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import '../../../config/theme/light_theme_colors.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.textEditingController,
    required this.submit,
    required this.clearing,
    required this.hint,
    required this.isClearButtonVisible,
    required this.isSearchButtonVisible,
  });

  final TextEditingController textEditingController;
  final dynamic submit;
  final dynamic clearing;
  final String hint;
  final bool isClearButtonVisible;
  final bool isSearchButtonVisible;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      height: 45.sp,
      decoration: BoxDecoration(
        color: LightThemeColors.fillColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          width: 1,
          color: LightThemeColors.buttonBorderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: textEditingController,
              style: theme.textTheme.bodyMedium,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              cursorColor: LightThemeColors.primaryColor,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onSaved: (value) {
                textEditingController.text = value!;
              },
              onFieldSubmitted: submit,
              decoration: InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 15.sp),
                fillColor: LightThemeColors.fillColor,
                errorStyle: TextStyle(
                  height: .1,
                  fontSize: 12.sp,
                ),
                errorMaxLines: 1,
                hintText: hint,
                hintStyle: TextStyle(
                  color: LightThemeColors.bodyTextSecondaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.sp),
          Visibility(
            visible: isClearButtonVisible,
            child: Padding(
              padding: EdgeInsets.only(right: 15.sp),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: clearing,
                  icon: Icon(
                    Remix.close_circle_fill,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  )),
            ),
          ),
          Visibility(
            visible: isSearchButtonVisible,
            child: Padding(
              padding: EdgeInsets.only(right: 15.sp),
              child: Icon(
                Remix.search_line,
                color: LightThemeColors.bodyTextSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
