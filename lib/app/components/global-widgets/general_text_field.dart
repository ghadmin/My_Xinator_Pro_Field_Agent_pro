import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../utils/validators.dart';

final formValidator = Get.put(FormValidator());

class GeneralTextField extends StatelessWidget {
  const GeneralTextField({
    super.key,
    required this.hint,
    this.focusNode,
    this.nextFocusNode,
    required this.theme,
    this.fieldName,
    this.suffixIcon,
    required this.textEditingController,
    this.textInputAction,
    this.textInputType,
    this.submit,
    this.onChanged,
    this.suffix,
    this.readOnly,
    this.maxLine,
    this.minLine,
    this.textAlignment,
  });

  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final ThemeData theme;
  final String? fieldName;
  final TextEditingController textEditingController;
  final String hint;
  final Icon? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final dynamic submit;
  final dynamic onChanged;
  final Widget? suffix;
  final bool? readOnly;
  final int? maxLine;
  final int? minLine;
  final TextAlign? textAlignment;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      style: readOnly == true
          ? theme.textTheme.bodyMedium
              ?.copyWith(color: LightThemeColors.bodyTextSecondaryColor)
          : theme.textTheme.bodyMedium,
      textInputAction: textInputAction ?? TextInputAction.done,
      keyboardType: textInputType ?? TextInputType.text,
      cursorColor: LightThemeColors.primaryColor,
      focusNode: focusNode,
      readOnly: readOnly ?? false,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: maxLine,
      minLines: maxLine,
      textAlign: textAlignment ?? TextAlign.start,
      onChanged: onChanged,
      onEditingComplete: nextFocusNode == null
          ? null
          : () {
              FocusScope.of(context).requestFocus(nextFocusNode);
            },
      onSaved: (value) {
        textEditingController.text = value!;
      },
      onFieldSubmitted: submit,
      validator: (value) {
        if (fieldName?.toLowerCase() != "website url" &&
            textEditingController.text.isEmpty) {
          return formValidator.validateRequired(value!, fieldName!);
        }

        if (fieldName?.toLowerCase() == "website url" &&
            textEditingController.text.isNotEmpty) {
          // Check if the value is a valid URL
          const urlPattern = r'(http|https):\/\/([^\s$.?#].[^\s]*)';
          final regExp = RegExp(urlPattern);

          if (!regExp.hasMatch(value!)) {
            return "Please enter a valid website URL.";
          }
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        contentPadding: Get.size.width <= 440
            ? EdgeInsets.symmetric(horizontal: 15.sp)
            : null,
        fillColor: readOnly == true
            ? LightThemeColors.bodyTextSecondaryColor.withValues(alpha: .1)
            : LightThemeColors.fillColor,
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
        suffixIcon: suffixIcon,
        suffix: suffix,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            width: 1,
            color: LightThemeColors.buttonBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: LightThemeColors.buttonBorderColor,
          ),
        ),
      ),
    );
  }
}
