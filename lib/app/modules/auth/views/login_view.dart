// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:remixicon/remixicon.dart';

// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../../utils/constants.dart';
// import '../../../components/global-widgets/my_buttons.dart';
// import '../controllers/auth_controller.dart';

// class LoginView extends GetView<AuthController> {
//   const LoginView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       body: LayoutBuilder(builder: (context, constraints) {
//         if (constraints.maxWidth > 599) {
//           return Obx(() => SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 reverse: true,
//                 child: _loginBigPadWidget(theme, context),
//               ));
//         } else if (constraints.maxWidth > 374 && constraints.maxWidth < 430) {
//           return Obx(() => SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 reverse: true,
//                 child: _loginSmallPadWidget(theme, context),
//               ));
//         } else {
//           return Obx(() => SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 reverse: true,
//                 child: _loginPhoneWidget(theme, context),
//               ));
//         }
//       }),
//     );
//   }

//   _loginPhoneWidget(ThemeData theme, BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 30.sp),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 "Login",
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   color: LightThemeColors.bodyTextColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 100.sp),
//           Center(
//             child: Container(
//               height: 100.sp,
//               width: 260.sp,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(AppImages.kCECIcon),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 120.sp),
//           SizedBox(
//             height: 50.sp,
//             child: TextFormField(
//               controller: controller.emailLoginTextController,
//               style: theme.textTheme.bodyMedium,
//               textInputAction: TextInputAction.next,
//               keyboardType: TextInputType.emailAddress,
//               cursorColor: LightThemeColors.primaryColor,
//               focusNode: controller.emailFocusNode,
//               onTapOutside: (event) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//                 controller.setTextFieldFocus(false);
//               },
//               onEditingComplete: () {
//                 FocusScope.of(context)
//                     .requestFocus(controller.passwordFocusNode);
//               },
//               onSaved: (value) {
//                 controller.emailLoginTextController.text = value!;
//               },
//               onTap: () {
//                 controller.setTextFieldFocus(true);
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: LightThemeColors.fillColor,
//                 prefixIcon: Icon(
//                   Remix.mail_line,
//                   color: LightThemeColors.iconColor,
//                 ),
//                 errorStyle: TextStyle(
//                   height: .1,
//                   fontSize: 12.sp,
//                 ),
//                 errorMaxLines: 1,
//                 hintText: "Email",
//                 hintStyle: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           controller.emailValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.emailValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 15.sp),
//           Container(
//             height: 50.sp,
//             decoration: BoxDecoration(
//               color: LightThemeColors.fillColor,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(
//                 width: 1,
//                 color: controller.passwordValidator.value ==
//                         "Password should be at least 8 characters long!"
//                     ? Colors.red
//                     : LightThemeColors.buttonBorderColor,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.passwordLoginTextController,
//                     style: theme.textTheme.bodyMedium,
//                     textInputAction: TextInputAction.done,
//                     keyboardType: TextInputType.text,
//                     cursorColor: LightThemeColors.primaryColor,
//                     focusNode: controller.passwordFocusNode,
//                     obscureText: !controller.isPasswordVisible.value,
//                     onTapOutside: (event) {
//                       FocusManager.instance.primaryFocus?.unfocus();
//                       controller.setTextFieldFocus(false);
//                     },
//                     onSaved: (value) {
//                       controller.passwordLoginTextController.text = value!;
//                     },
//                     onTap: () {
//                       controller.setTextFieldFocus(true);
//                     },
//                     decoration: InputDecoration(
//                       filled: true,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15.sp),
//                       fillColor: LightThemeColors.fillColor,
//                       prefixIcon: Icon(
//                         Remix.lock_line,
//                         color: LightThemeColors.iconColor,
//                       ),
//                       errorStyle: TextStyle(
//                         height: .1,
//                         fontSize: 12.sp,
//                       ),
//                       errorMaxLines: 1,
//                       hintText: "Enter your password",
//                       hintStyle: TextStyle(
//                         color: LightThemeColors.bodyTextSecondaryColor,
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5.sp),
//                 Padding(
//                   padding: EdgeInsets.only(right: 15.sp),
//                   child: IconButton(
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       onPressed: controller.togglePasswordVisibility,
//                       icon: Icon(
//                         size: 18.sp,
//                         !controller.isPasswordVisible.value
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: LightThemeColors.bodyTextSecondaryColor,
//                       )),
//                 ),
//               ],
//             ),
//           ),
//           controller.passwordValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.passwordValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 50.sp),
//           SizedBox(
//             height: 48.sp,
//             width: double.infinity,
//             child: PrimaryButton(
//               title: "Sign in",
//               onPressed: () async {
//                 // Email validation
//                 String email = controller.emailLoginTextController.text;
//                 String password = controller.passwordLoginTextController.text;

//                 if (email.isNotEmpty && password.length > 5) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value = "";

//                   // Call login method
//                   await controller.login(email, password);
//                 } else if (email.isEmpty && password.length > 5) {
//                   controller.passwordValidator.value = "";
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                 } else if (email.isNotEmpty && password.length < 6) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 } else if (email.isEmpty && password.length < 6) {
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 }
//               },
//               inactive: !controller.isButtonActive.value,
//             ),
//           ),

//           controller.isTextFieldFocused.value
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 180.sp),
//                   child: Center(
//                     child: Image.asset(
//                       AppImages.kCECBrand,
//                       width: 130.sp,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//           // SizedBox(height: 20.sp),
//           // Column(
//           //   children: [
//           //     Text("Forgot password?", style: theme.textTheme.bodyMedium),
//           //     SizedBox(height: 5.sp),
//           //     Row(
//           //       mainAxisAlignment: MainAxisAlignment.center,
//           //       children: [
//           //         Text("Don't have an account? ",
//           //             style: theme.textTheme.bodyMedium),
//           //         TextButton(
//           //           style: ButtonStyle(
//           //             minimumSize: WidgetStatePropertyAll(Size.zero),
//           //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           //             padding: WidgetStatePropertyAll(
//           //               EdgeInsets.zero,
//           //             ),
//           //           ),
//           //           onPressed: () {
//           //             Get.toNamed(Routes.SIGNUP);
//           //           },
//           //           child: Text(
//           //             "Create new",
//           //             style: TextStyle(
//           //               color: LightThemeColors.primaryColor,
//           //               fontSize: MyFonts.body1TextSize,
//           //               fontWeight: FontWeight.bold,
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ],
//           // )
//         ],
//       ),
//     );
//   }

//   _loginBigPadWidget(ThemeData theme, BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 10.sp),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 "Login",
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   color: LightThemeColors.bodyTextColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20.sp,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 30.sp),
//           Center(
//             child: Container(
//               height: 80.sp,
//               width: 220.sp,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(AppImages.kCECIcon),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 60.sp),
//           SizedBox(
//             height: 40.sp,
//             child: TextFormField(
//               controller: controller.emailLoginTextController,
//               style: theme.textTheme.bodyMedium,
//               textInputAction: TextInputAction.next,
//               keyboardType: TextInputType.emailAddress,
//               cursorColor: LightThemeColors.primaryColor,
//               focusNode: controller.emailFocusNode,
//               onTapOutside: (event) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//                 controller.setTextFieldFocus(false);
//               },
//               onEditingComplete: () {
//                 FocusScope.of(context)
//                     .requestFocus(controller.passwordFocusNode);
//               },
//               onSaved: (value) {
//                 controller.emailLoginTextController.text = value!;
//               },
//               onTap: () {
//                 controller.setTextFieldFocus(true);
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: LightThemeColors.fillColor,
//                 prefixIcon: Icon(
//                   Remix.mail_line,
//                   color: LightThemeColors.iconColor,
//                 ),
//                 errorStyle: TextStyle(
//                   height: .1,
//                   fontSize: 12.sp,
//                 ),
//                 errorMaxLines: 1,
//                 hintText: "Email",
//                 hintStyle: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           controller.emailValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.emailValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 15.sp),
//           Container(
//             height: 40.sp,
//             decoration: BoxDecoration(
//               color: LightThemeColors.fillColor,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(
//                 width: 1,
//                 color: controller.passwordValidator.value ==
//                         "Password should be at least 8 characters long!"
//                     ? Colors.red
//                     : LightThemeColors.buttonBorderColor,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.passwordLoginTextController,
//                     style: theme.textTheme.bodyMedium,
//                     textInputAction: TextInputAction.done,
//                     keyboardType: TextInputType.text,
//                     cursorColor: LightThemeColors.primaryColor,
//                     focusNode: controller.passwordFocusNode,
//                     obscureText: !controller.isPasswordVisible.value,
//                     onTapOutside: (event) {
//                       FocusManager.instance.primaryFocus?.unfocus();
//                       controller.setTextFieldFocus(false);
//                     },
//                     onSaved: (value) {
//                       controller.passwordLoginTextController.text = value!;
//                     },
//                     onTap: () {
//                       controller.setTextFieldFocus(true);
//                     },
//                     decoration: InputDecoration(
//                       filled: true,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 15.sp),
//                       fillColor: LightThemeColors.fillColor,
//                       prefixIcon: Icon(
//                         Remix.lock_line,
//                         color: LightThemeColors.iconColor,
//                       ),
//                       errorStyle: TextStyle(
//                         height: .1,
//                         fontSize: 12.sp,
//                       ),
//                       errorMaxLines: 1,
//                       hintText: "Enter your password",
//                       hintStyle: TextStyle(
//                         color: LightThemeColors.bodyTextSecondaryColor,
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5.sp),
//                 Padding(
//                   padding: EdgeInsets.only(right: 15.sp),
//                   child: IconButton(
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       onPressed: controller.togglePasswordVisibility,
//                       icon: Icon(
//                         size: 18.sp,
//                         !controller.isPasswordVisible.value
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: LightThemeColors.bodyTextSecondaryColor,
//                       )),
//                 ),
//               ],
//             ),
//           ),
//           controller.passwordValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.passwordValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 50.sp),
//           SizedBox(
//             height: 40.sp,
//             width: double.infinity,
//             child: PrimaryButton(
//               title: "Sign in",
//               onPressed: () async {
//                 // Email validation
//                 String email = controller.emailLoginTextController.text;
//                 String password = controller.passwordLoginTextController.text;

//                 if (email.isNotEmpty && password.length > 5) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value = "";

//                   // Call login method
//                   await controller.login(email, password);
//                 } else if (email.isEmpty && password.length > 5) {
//                   controller.passwordValidator.value = "";
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                 } else if (email.isNotEmpty && password.length < 6) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 } else if (email.isEmpty && password.length < 6) {
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 }
//               },
//               inactive: !controller.isButtonActive.value,
//             ),
//           ),

//           controller.isTextFieldFocused.value
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 150.sp),
//                   child: Center(
//                     child: Image.asset(
//                       AppImages.kCECBrand,
//                       width: 130.sp,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//           // SizedBox(height: 20.sp),
//           // Column(
//           //   children: [
//           //     Text("Forgot password?", style: theme.textTheme.bodyMedium),
//           //     SizedBox(height: 5.sp),
//           //     Row(
//           //       mainAxisAlignment: MainAxisAlignment.center,
//           //       children: [
//           //         Text("Don't have an account? ",
//           //             style: theme.textTheme.bodyMedium),
//           //         TextButton(
//           //           style: ButtonStyle(
//           //             minimumSize: WidgetStatePropertyAll(Size.zero),
//           //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           //             padding: WidgetStatePropertyAll(
//           //               EdgeInsets.zero,
//           //             ),
//           //           ),
//           //           onPressed: () {
//           //             Get.toNamed(Routes.SIGNUP);
//           //           },
//           //           child: Text(
//           //             "Create new",
//           //             style: TextStyle(
//           //               color: LightThemeColors.primaryColor,
//           //               fontSize: MyFonts.body1TextSize,
//           //               fontWeight: FontWeight.bold,
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ],
//           // )
//         ],
//       ),
//     );
//   }

//   _loginSmallPadWidget(ThemeData theme, BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 10.sp),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 "Login",
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   color: LightThemeColors.bodyTextColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20.sp,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 30.sp),
//           Center(
//             child: Container(
//               height: 80.sp,
//               width: 220.sp,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(AppImages.kCECIcon),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 100.sp),
//           SizedBox(
//             height: 50.sp,
//             child: TextFormField(
//               controller: controller.emailLoginTextController,
//               style: theme.textTheme.bodyMedium,
//               textInputAction: TextInputAction.next,
//               keyboardType: TextInputType.emailAddress,
//               cursorColor: LightThemeColors.primaryColor,
//               focusNode: controller.emailFocusNode,
//               onTapOutside: (event) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//                 controller.setTextFieldFocus(false);
//               },
//               onEditingComplete: () {
//                 FocusScope.of(context)
//                     .requestFocus(controller.passwordFocusNode);
//               },
//               onSaved: (value) {
//                 controller.emailLoginTextController.text = value!;
//               },
//               onTap: () {
//                 controller.setTextFieldFocus(true);
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: LightThemeColors.fillColor,
//                 prefixIcon: Icon(
//                   Remix.mail_line,
//                   color: LightThemeColors.iconColor,
//                 ),
//                 errorStyle: TextStyle(
//                   height: .1,
//                   fontSize: 12.sp,
//                 ),
//                 errorMaxLines: 1,
//                 hintText: "Email",
//                 hintStyle: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: Colors.red,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     width: 1,
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                   borderSide: const BorderSide(
//                     color: LightThemeColors.buttonBorderColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           controller.emailValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.emailValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 15.sp),
//           Container(
//             height: 50.sp,
//             decoration: BoxDecoration(
//               color: LightThemeColors.fillColor,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(
//                 width: 1,
//                 color: controller.passwordValidator.value ==
//                         "Password should be at least 8 characters long!"
//                     ? Colors.red
//                     : LightThemeColors.buttonBorderColor,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 50.sp,
//                     child: TextFormField(
//                       controller: controller.passwordLoginTextController,
//                       style: theme.textTheme.bodyMedium,
//                       textInputAction: TextInputAction.done,
//                       keyboardType: TextInputType.text,
//                       cursorColor: LightThemeColors.primaryColor,
//                       focusNode: controller.passwordFocusNode,
//                       obscureText: !controller.isPasswordVisible.value,
//                       onTapOutside: (event) {
//                         FocusManager.instance.primaryFocus?.unfocus();
//                         controller.setTextFieldFocus(false);
//                       },
//                       onSaved: (value) {
//                         controller.passwordLoginTextController.text = value!;
//                       },
//                       onTap: () {
//                         controller.setTextFieldFocus(true);
//                       },
//                       decoration: InputDecoration(
//                         filled: true,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 15.sp),
//                         fillColor: LightThemeColors.fillColor,
//                         prefixIcon: Icon(
//                           Remix.lock_line,
//                           color: LightThemeColors.iconColor,
//                         ),
//                         errorStyle: TextStyle(
//                           height: .1,
//                           fontSize: 12.sp,
//                         ),
//                         errorMaxLines: 1,
//                         hintText: "Enter your password",
//                         hintStyle: TextStyle(
//                           color: LightThemeColors.bodyTextSecondaryColor,
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5.sp),
//                 Padding(
//                   padding: EdgeInsets.only(right: 15.sp),
//                   child: IconButton(
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       onPressed: controller.togglePasswordVisibility,
//                       icon: Icon(
//                         size: 18.sp,
//                         !controller.isPasswordVisible.value
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: LightThemeColors.bodyTextSecondaryColor,
//                       )),
//                 ),
//               ],
//             ),
//           ),
//           controller.passwordValidator.value == ""
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
//                   child: Text(
//                     controller.passwordValidator.value,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//           SizedBox(height: 50.sp),
//           SizedBox(
//             height: 50.sp,
//             width: double.infinity,
//             child: PrimaryButton(
//               title: "Sign in",
//               onPressed: () async {
//                 // Email validation
//                 String email = controller.emailLoginTextController.text;
//                 String password = controller.passwordLoginTextController.text;

//                 if (email.isNotEmpty && password.length > 5) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value = "";

//                   // Call login method
//                   await controller.login(email, password);
//                 } else if (email.isEmpty && password.length > 5) {
//                   controller.passwordValidator.value = "";
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                 } else if (email.isNotEmpty && password.length < 6) {
//                   controller.emailValidator.value = "";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 } else if (email.isEmpty && password.length < 6) {
//                   controller.emailValidator.value =
//                       "Email address is not valid!";
//                   controller.passwordValidator.value =
//                       "Password should be at least 6 characters long!";
//                 }
//               },
//               inactive: !controller.isButtonActive.value,
//             ),
//           ),

//           controller.isTextFieldFocused.value
//               ? const SizedBox.shrink()
//               : Padding(
//                   padding: EdgeInsets.only(top: 180.sp),
//                   child: Center(
//                     child: Image.asset(
//                       AppImages.kCECBrand,
//                       width: 130.sp,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//           // SizedBox(height: 20.sp),
//           // Column(
//           //   children: [
//           //     Text("Forgot password?", style: theme.textTheme.bodyMedium),
//           //     SizedBox(height: 5.sp),
//           //     Row(
//           //       mainAxisAlignment: MainAxisAlignment.center,
//           //       children: [
//           //         Text("Don't have an account? ",
//           //             style: theme.textTheme.bodyMedium),
//           //         TextButton(
//           //           style: ButtonStyle(
//           //             minimumSize: WidgetStatePropertyAll(Size.zero),
//           //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           //             padding: WidgetStatePropertyAll(
//           //               EdgeInsets.zero,
//           //             ),
//           //           ),
//           //           onPressed: () {
//           //             Get.toNamed(Routes.SIGNUP);
//           //           },
//           //           child: Text(
//           //             "Create new",
//           //             style: TextStyle(
//           //               color: LightThemeColors.primaryColor,
//           //               fontSize: MyFonts.body1TextSize,
//           //               fontWeight: FontWeight.bold,
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ],
//           // )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Form Content
            Obx(
              () => SingleChildScrollView(
                reverse: true, // Helps push focused field above keyboard
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Login",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: LightThemeColors.bodyTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.sp),
                    Image.asset(
                      AppImages.kFSMProIcon,
                      width: 180.sp,
                      height: 100.sp,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 40.sp),

                    // Email Field
                    TextFormField(
                      controller: controller.emailLoginTextController,
                      focusNode: controller.emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: LightThemeColors.primaryColor,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(controller.passwordFocusNode),
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Remix.mail_line),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    if (controller.emailValidator.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.sp, left: 5.sp),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.emailValidator.value,
                            style:
                                TextStyle(color: Colors.red, fontSize: 12.sp),
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),

                    // Password Field
                    TextFormField(
                      controller: controller.passwordLoginTextController,
                      focusNode: controller.passwordFocusNode,
                      obscureText: !controller.isPasswordVisible.value,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Remix.lock_line),
                        suffixIcon: IconButton(
                          icon: Icon(controller.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: controller.togglePasswordVisibility,
                          iconSize: 18.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    if (controller.passwordValidator.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.sp, left: 5.sp),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.passwordValidator.value,
                            style:
                                TextStyle(color: Colors.red, fontSize: 12.sp),
                          ),
                        ),
                      ),
                    SizedBox(height: 25.sp),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 45.sp,
                      child: PrimaryButton(
                        title: "Sign in",
                        onPressed: () async {
                          final email =
                              controller.emailLoginTextController.text;
                          final password =
                              controller.passwordLoginTextController.text;
                          if (email.isNotEmpty && password.length > 5) {
                            controller.emailValidator.value = '';
                            controller.passwordValidator.value = '';
                            await controller.login(email, password);
                          } else {
                            controller.emailValidator.value = email.isEmpty
                                ? "Email address is not valid!"
                                : '';
                            controller.passwordValidator.value = password
                                        .length <
                                    6
                                ? "Password should be at least 6 characters long!"
                                : '';
                          }
                        },
                        inactive: !controller.isButtonActive.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image Always at Bottom
            if (!controller.isTextFieldFocused.value)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.sp),
                  child: Image.asset(
                    AppImages.kCECBrand,
                    width: 130.sp,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
