import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../config/theme/my_fonts.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/auth_controller.dart';

class SignUpView extends GetView<AuthController> {
  const SignUpView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              reverse: true,
              child: Column(
                children: [
                  SizedBox(height: 30.sp),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 50.sp,
                          width: 50.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: LightThemeColors.buttonBorderColor,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left_sharp,
                            size: 40.sp,
                            color: LightThemeColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: LightThemeColors.bodyTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "You have chance to create new account if you really want to.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 30.sp),
                  SizedBox(
                    height: 50.sp,
                    child: TextFormField(
                      controller: controller.fullNameTextController,
                      style: theme.textTheme.bodyMedium,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      cursorColor: LightThemeColors.primaryColor,
                      focusNode: controller.nameFocusNode,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onEditingComplete: () {
                        FocusScope.of(context)
                            .requestFocus(controller.signEmailFocusNode);
                      },
                      onSaved: (value) {
                        controller.fullNameTextController.text = value!;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: LightThemeColors.fillColor,
                        prefixIcon: Icon(
                          Remix.user_line,
                          color: LightThemeColors.iconColor,
                        ),
                        errorStyle: TextStyle(
                          height: .1,
                          fontSize: 12.sp,
                        ),
                        errorMaxLines: 1,
                        hintText: "Full Name",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
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
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  SizedBox(
                    height: 50.sp,
                    child: TextFormField(
                      controller: controller.emailSignupTextController,
                      style: theme.textTheme.bodyMedium,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: LightThemeColors.primaryColor,
                      focusNode: controller.signEmailFocusNode,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onEditingComplete: () {
                        FocusScope.of(context)
                            .requestFocus(controller.signPasswordFocusNode);
                      },
                      onSaved: (value) {
                        controller.emailSignupTextController.text = value!;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: LightThemeColors.fillColor,
                        prefixIcon: Icon(
                          Remix.mail_line,
                          color: LightThemeColors.iconColor,
                        ),
                        errorStyle: TextStyle(
                          height: .1,
                          fontSize: 12.sp,
                        ),
                        errorMaxLines: 1,
                        hintText: "Email",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
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
                    ),
                  ),
                  controller.emailValidator.value == ""
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: 5.sp, left: 15.sp),
                          child: Text(
                            controller.emailValidator.value,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                  SizedBox(height: 15.sp),
                  Container(
                    height: 50.sp,
                    decoration: BoxDecoration(
                      color: LightThemeColors.fillColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        width: 1,
                        color: controller.passwordValidator.value ==
                                "Password should be at least 8 characters long!"
                            ? Colors.red
                            : LightThemeColors.buttonBorderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.passwordSignupTextController,
                            style: theme.textTheme.bodyMedium,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            focusNode: controller.signPasswordFocusNode,
                            cursorColor: LightThemeColors.primaryColor,
                            obscureText: !controller.isPasswordVisible.value,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onSaved: (value) {
                              controller.passwordSignupTextController.text =
                                  value!;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.sp),
                              fillColor: LightThemeColors.fillColor,
                              prefixIcon: Icon(
                                Remix.lock_line,
                                color: LightThemeColors.iconColor,
                              ),
                              errorStyle: TextStyle(
                                height: .1,
                                fontSize: 12.sp,
                              ),
                              errorMaxLines: 1,
                              hintText: "Enter your password",
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
                        Padding(
                          padding: EdgeInsets.only(right: 15.sp),
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                size: 18.sp,
                                !controller.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: LightThemeColors.bodyTextSecondaryColor,
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.sp),
                  SizedBox(
                    height: 48.sp,
                    width: double.infinity,
                    child: PrimaryButton(
                      title: "Sign up",
                      onPressed: () {},
                      inactive: false,
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have account? ",
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.zero,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "Go here",
                          style: TextStyle(
                            color: LightThemeColors.primaryColor,
                            fontSize: MyFonts.body1TextSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
