// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../../config/theme/light_theme_colors.dart';
// import '../../../utils/validators.dart';
// import '../../modules/auth/controllers/auth_controller.dart';
//
// final formValidator = Get.put(FormValidator());
//
// class AuthTextField extends StatelessWidget {
//   const AuthTextField({
//     super.key,
//     required this.textEditingController,
//     required this.controller,
//     required this.theme,
//     required this.type,
//     required this.hint,
//     required this.focusNode,
//     this.nextFocusNode,
//     this.fieldName,
//     this.suffixFunction,
//   });
//
//   final TextEditingController textEditingController;
//   final AuthController controller;
//   final ThemeData theme;
//   final String type;
//   final String hint;
//   final String? fieldName;
//   final FocusNode focusNode;
//   final FocusNode? nextFocusNode;
//   final Function()? suffixFunction;
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return SizedBox(
//       height: 46.sp,
//       child: type == "Password"
//           ? Obx(() => buildTextFormField(theme, context))
//           : buildTextFormField(theme, context),
//     );
//   }
//
//   TextFormField buildTextFormField(ThemeData theme, BuildContext context) {
//     return TextFormField(
//       controller: textEditingController,
//       obscureText:
//       type == "Password" ? !controller.isPasswordVisible.value : false,
//       style: theme.textTheme.bodyMedium,
//       focusNode: focusNode,
//       onTapOutside: (event) {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       onSaved: (value) {
//         textEditingController.text = value!;
//       },
//       onEditingComplete: nextFocusNode == null
//           ? null
//           : () {
//         FocusScope.of(context).requestFocus(nextFocusNode);
//       },
//       validator: (value) {
//         if (textEditingController.text.isEmpty) {
//           return formValidator.validateRequired(value!, fieldName!);
//         }
//
//         return type == "Email"
//             ? formValidator.validateEmail(value!)
//             : type == "Phone"
//             ? formValidator.validatePhoneNumber(value!)
//             : type == "String"
//             ? formValidator.validateRequired(value!, fieldName!)
//             : formValidator.validatePassword(value!);
//       },
//       keyboardType: type == "String" || type == "Password"
//           ? TextInputType.text
//           : type == "Email"
//           ? TextInputType.emailAddress
//           : type == "Phone"
//           ? TextInputType.phone
//           : TextInputType.number,
//       textInputAction:
//       type == "Password" ? TextInputAction.done : TextInputAction.next,
//       cursorColor: LightThemeColors.primaryColor,
//       decoration: InputDecoration(
//         filled: true,
//         contentPadding: type == "Password"
//             ? EdgeInsets.only(bottom: -22.sp, left: 15.sp, right: 15.sp)
//             : EdgeInsets.symmetric(horizontal: 15.sp),
//         fillColor: LightThemeColors.fillColor,
//         suffix: type == "Password"
//             ? IconButton(
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//           onPressed: controller.togglePasswordVisibility,
//           icon: Icon(
//             controller.isPasswordVisible.value
//                 ? Icons.visibility
//                 : Icons.visibility_off,
//             size: 20,
//           ),
//         )
//             : null,
//         errorStyle: TextStyle(
//           height: .1,
//           fontSize: 12.sp,
//         ),
//         errorMaxLines: 1,
//         hintText: hint,
//         hintStyle: TextStyle(
//           color: LightThemeColors.hintTextColor,
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w500,
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.r),
//           borderSide: const BorderSide(
//             width: 1,
//             color: Colors.red,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.r),
//           borderSide: const BorderSide(
//             width: 1,
//             color: Colors.red,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.r),
//           borderSide: const BorderSide(
//             width: 1,
//             color: LightThemeColors.buttonBorderColor,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.r),
//           borderSide: const BorderSide(
//             width: 1,
//             color: LightThemeColors.buttonBorderColor,
//           ),
//         ),
//       ),
//     );
//   }
// }
