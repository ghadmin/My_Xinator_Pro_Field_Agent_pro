// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:xinator_fsm_pro/app/modules/customer/models/customer_model.dart';

// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../../utils/url_launcher.dart';
// import '../../../components/global-widgets/main_divider.dart';
// import '../controllers/customer_controller.dart';

// class CustomerDetailsView extends StatefulWidget {
//   const CustomerDetailsView({super.key});

//   @override
//   State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
// }

// class _CustomerDetailsViewState extends State<CustomerDetailsView>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   final controller = Get.find<CustomerController>();

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 6, vsync: this);
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const  TextWidget(text:'Customer Details'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TabBar(
//               isScrollable: true,
//               controller: tabController,
//               labelColor: Colors.blue, // Selected tab text color
//               unselectedLabelColor: Colors.black, // Unselected tab text color
//               indicatorColor: Colors.blue, // Underline color for selected tab
//               tabs: const [
//                 Tab(text: "Basic Details"),
//                 Tab(text: "Appointments"),
//                 Tab(text: "Invoice & Estimates"),
//                 Tab(text: "Equipment"),
//                 Tab(text: "Maintenance Agreement"),
//                 Tab(text: "Pictures"),
//               ],
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     BasicDetailsWidget(
//                         theme: theme,
//                         customer: controller.selectedCustomer.value!),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BasicDetailsWidget extends StatelessWidget {
//   const BasicDetailsWidget(
//       {super.key, required this.theme, required this.customer});

//   final ThemeData theme;
//   final CustomerModel customer;

//   @override
//   Widget build(BuildContext context) {
//     final fullName = (customer.firstName?.isNotEmpty == true &&
//             customer.lastName?.isNotEmpty == true)
//         ? '${customer.firstName} ${customer.lastName}'
//         : (customer.firstName?.isNotEmpty == true)
//             ? customer.firstName!
//             : (customer.lastName?.isNotEmpty == true)
//                 ? customer.lastName!
//                 : 'N/A';

//     return Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16), // <-- set your radius here
//         ),
//         color: Colors.white,
//         child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                    TextWidget(text:
//                     fullName,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: LightThemeColors.appBlackColor,
//                       fontSize: 27.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.email_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Email",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.email ?? "N/A",
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.end,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Address",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.address1 ?? "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.call,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Phone",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.phone ?? "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Image.asset(
//                               'assets/images/customers/status_icon.png',
//                               width: 20,
//                               height: 20,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Status",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             "Scheduled",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               color: Colors.green,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_month_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Created On",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.createdDateTime != null
//                                 ? customer.createdDateTime.runtimeType == String
//                                     ? DateFormat("M/d/yyyy h:mm:ss a")
//                                         .parse(customer.createdDateTime!)
//                                         .toLocal()
//                                         .toString()
//                                     : customer.createdDateTime!
//                                         .toLocal()
//                                         .toString()
//                                 : "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               color: LightThemeColors.hintTextColor,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   // Row(
//                   //   children: [
//                   //     Expanded(
//                   //       flex: 2,
//                   //       child: Row(
//                   //         children: [
//                   //           Image.asset(
//                   //             'assets/images/customers/instrunction.png',
//                   //             width: 20,
//                   //             height: 20,
//                   //             color: Colors.grey,
//                   //           ),
//                   //           SizedBox(
//                   //             width: 5,
//                   //           ),
//                   //            TextWidget(text:
//                   //             "Special Instruction",
//                   //             style: theme.textTheme.bodyLarge?.copyWith(
//                   //               color: LightThemeColors.hintTextColor,
//                   //               fontSize: 14.sp,
//                   //               overflow: TextOverflow.ellipsis,
//                   //               fontWeight: FontWeight.w500,
//                   //             ),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //     Expanded(
//                   //       flex: 3,
//                   //       child: SizedBox(
//                   //         child:  TextWidget(text:
//                   //           customer.jobTitle ?? "N/A",
//                   //           textAlign: TextAlign.end,
//                   //           style: theme.textTheme.bodyLarge?.copyWith(
//                   //             fontSize: 14.sp,
//                   //             color: LightThemeColors.hintTextColor,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     )
//                   //   ],
//                   // ),
//                   // SizedBox(
//                   //   height: 10.h,
//                   // ),
//                 ])));
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/url_launcher.dart';
import '../../../components/global-widgets/main_divider.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../controllers/customer_controller.dart';

class CustomerDetailsView extends GetView<CustomerController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Platform.isAndroid
            ? kToolbarHeight
            : kToolbarHeight + 60,
        title: const TextWidget(text: 'Customer Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfoCard(theme),
                    SizedBox(height: 20.h),
                    _buildCreateAppointmentButton(theme, context),
                    SizedBox(height: 25.h),
                    _buildAppointmentSection(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CUSTOMER INFO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildCustomerInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        children: [
          _tile(
            "Business Name",
            controller.businessName != '' ? controller.businessName : "N/A",
            theme,
          ),
          MainDivider(),
          _tile(
            "Title",
            controller.title != '' ? controller.title : "N/A",
            theme,
          ),
          MainDivider(),
          _tile(
            "Address",
            controller.address != '' ? controller.address : "N/A",
            theme,
            multiLine: true,
          ),
          MainDivider(),
          _callTile(
            "Mobile",
            controller.mobileNumber != '' ? controller.mobileNumber : "N/A",
            theme,
          ),
          MainDivider(),
          _callTile(
            "Phone",
            controller.phoneNumber != '' ? controller.phoneNumber : "N/A",
            theme,
          ),
          MainDivider(),
          _emailTile(
            "Email",
            controller.email != '' ? controller.email : "N/A",
            theme,
          ),
          // MainDivider(),
          // _navTile("Invoices", "See Invoices >", theme),
          // MainDivider(),
          // _navTile("Estimates", "See Estimates >", theme),
          // MainDivider(),
          // _navTile("Appointments", "See Appointments >", theme),
          // MainDivider(),
          // _navTile("Files", "View Files >", theme),
          // MainDivider(),
          // _navTile("Email History", "See History >", theme),
        ],
      ),
    );
  }

  Widget _tile(
    String title,
    String value,
    ThemeData theme, {
    bool multiLine = false,
  }) {
    return ListTile(
      title: TextWidget(
        text: title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: LightThemeColors.hintTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: SizedBox(
        width: multiLine ? 220.sp : null,
        child: TextWidget(
          text: value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.end,
          maxLines: 100, // 👉 IMPORTANT — full text, no ellipsis
        ),
      ),
    );
  }

  Widget _callTile(String title, String number, ThemeData theme) {
    return ListTile(
      title: TextWidget(
        text: title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: LightThemeColors.hintTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: InkWell(
        onTap: () => UrlLauncher.phoneCall(number),
        child: TextWidget(
          text: number,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _emailTile(String title, String email, ThemeData theme) {
    return ListTile(
      title: TextWidget(
        text: title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: LightThemeColors.hintTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: InkWell(
        onTap: () => UrlLauncher.email(email),
        child: SizedBox(
          width: 220.sp,
          child: TextWidget(
            text: email,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
            textAlign: TextAlign.end,
            maxLines: 100,
          ),
        ),
      ),
    );
  }

  Widget _navTile(String title, String buttonText, ThemeData theme) {
    return ListTile(
      title: TextWidget(
        text: title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: LightThemeColors.hintTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: TextWidget(
        text: buttonText,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CREATE APPOINTMENT BUTTON
  // ---------------------------------------------------------------------------

  void openCreateAppointmentPopup(BuildContext context) {
    Get.bottomSheet(
      CreateAppointmentSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildCreateAppointmentButton(ThemeData theme, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => openCreateAppointmentPopup(context),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.sp),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: TextWidget(
          text: "Create Appointment",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APPOINTMENTS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildAppointmentSection(ThemeData theme) {
    // final list = controller.appointments;
    final list = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: "Appointments",
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),

        /// No Appointments
        if (list.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: TextWidget(
                text: "No appointment found",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 350.h,
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => MainDivider(),
              itemBuilder: (_, index) {
                final appt = list[index];
                return ListTile(
                  title: TextWidget(
                    text: appt.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: TextWidget(
                    text: appt.date,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14),
                );
              },
            ),
          ),
      ],
    );
  }
}

class CreateAppointmentSheet extends StatefulWidget {
  @override
  State<CreateAppointmentSheet> createState() => _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends State<CreateAppointmentSheet> {
  DateTime? selectedDate;
  Map<String, dynamic>? selectedTimeSlot;
  String? selectedType;
  final TextEditingController noteCtrl = TextEditingController();

  final List<String> appointmentTypes = [
    "Inspection",
    "Follow Up",
    "Diagnostic",
    "Repair",
    "Maintenance",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DRAG BAR
            Center(
              child: Container(
                width: 55,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Create Appointment",
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),

            // DATE PICKER
            _label("Date"),
            _selectBox(
              text: selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}",
              onTap: pickDate,
            ),
            SizedBox(height: 18),

            // TIME SLOT PICKER
            _label("Time Slot"),
            _selectBox(
              text: selectedTimeSlot == null
                  ? "Select Time Slot"
                  : "${selectedTimeSlot!["title"]} (${selectedTimeSlot!["time"]})",
              onTap: openTimeSlotSheet,
            ),
            SizedBox(height: 18),

            // APPOINTMENT TYPE
            _label("Appointment Type"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: _decoration(),
              child: DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                underline: SizedBox(),
                hint: Text("Choose Type"),
                items: appointmentTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v),
              ),
            ),
            SizedBox(height: 18),

            // NOTE
            _label("Note"),
            Container(
              decoration: _decoration(),
              child: TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Submit to CEC",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // UI HELPERS
  BoxDecoration _decoration() => BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  Widget _selectBox({required String text, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: _decoration(),
        child: Text(text, style: TextStyle(fontSize: 14)),
      ),
    );
  }

  // PICKERS
  Future<void> pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> openTimeSlotSheet() async {
    final slot = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TimeSlotPicker(),
    );

    if (slot != null) setState(() => selectedTimeSlot = slot);
  }

  void submit() {
    if (selectedDate == null ||
        selectedTimeSlot == null ||
        selectedType == null) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    Get.back();
    Get.defaultDialog(
      title: "Success",
      middleText: "Appointment submitted",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }
}

class TimeSlotPicker extends StatefulWidget {
  const TimeSlotPicker({super.key});

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  final List<Map<String, dynamic>> slots = [
    {"title": "Morning", "time": "9:00 AM - 11:00 AM", "blocked": false},
    {"title": "Afternoon", "time": "1:00 PM - 3:00 PM", "blocked": true},
    {"title": "Evening", "time": "6:00 PM - 9:00 PM", "blocked": false},
  ];

  int? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Time Slot",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...List.generate(slots.length, (i) {
            final s = slots[i];

            return GestureDetector(
              onTap: s["blocked"] ? null : () => setState(() => selected = i),
              child: Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: s["blocked"]
                      ? Colors.grey.shade200
                      : selected == i
                      ? Colors.blue.shade50
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == i ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s["title"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          s["time"],
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                    s["blocked"]
                        ? Icon(Icons.lock, color: Colors.grey)
                        : selected == i
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : Icon(Icons.circle_outlined, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: selected == null
                ? null
                : () => Navigator.pop(context, slots[selected!]),
            child: Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }
}
