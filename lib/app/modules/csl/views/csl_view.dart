// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../../utils/constants.dart';
// import '../../../components/drawer/custom_drawer.dart';
// import '../../../components/global-widgets/asset_image_box.dart';

// class CslScreen extends StatefulWidget {
//   const CslScreen({super.key});

//   @override
//   _CslScreenState createState() => _CslScreenState();
// }

// class _CslScreenState extends State<CslScreen> {
//   String? selectedStatus = "All Statuses";
//   bool hideNAPending = false;
//   int entriesPerPage = 10;
//   String searchQuery = "";

//   // final List<Map<String, dynamic>> data = [
//   //   {'firstName': 'Abrar', 'lastName': 'Hasan', 'status': 'Scheduled'},
//   //   {'firstName': 'bd', 'lastName': 'ratul', 'status': 'Scheduled'},
//   //   {'firstName': 'Bob', 'lastName': 'Builder', 'status': 'Scheduled'},
//   //   {'firstName': 'Brad', 'lastName': 'Haddin', 'status': 'Pending'},
//   //   {'firstName': 'Dallas', 'lastName': 'Greene', 'status': 'Scheduled'},
//   //   {
//   //     'firstName': 'Data',
//   //     'lastName': 'Test',
//   //     'status': 'Pending',
//   //   }, // Highlighted row
//   // ];

//   final List<String> statusOptions = ['All Statuses', 'Scheduled', 'Pending'];

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);

//     return Scaffold(
//       appBar: Get.size.width <= 440
//           ? AppBar(
//               title: Text(
//                 "Customer Service Locations",
//                 style: TextStyle(fontSize: 15.sp),
//               ),
//               actions: [
//                 InkWell(
//                   onTap: () {},
//                   child: Padding(
//                     padding: EdgeInsets.only(right: 18.sp),
//                     child: SizedBox(
//                       width: 35.sp, // Specify the width and height you want
//                       height: 35.sp,
//                       child: CircleAvatar(
//                         child: ClipOval(
//                           child: AssetImageBox(
//                             height: 35.sp,
//                             width: 35.sp,
//                             assetImage: AppImages.kDemoUser,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : PreferredSize(
//               preferredSize: Size.fromHeight(40.sp),
//               child: Padding(
//                 padding: EdgeInsets.only(top: 15.sp),
//                 child: AppBar(
//                   title: Padding(
//                     padding: EdgeInsets.only(top: 8.sp),
//                     child: Text(
//                       "Appointments",
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ),
//                   actions: [
//                     InkWell(
//                       onTap: () {},
//                       child: Padding(
//                         padding: EdgeInsets.only(right: 18.sp, top: 8.sp),
//                         child: SizedBox(
//                           width: 20.sp, // Specify the width and height you want
//                           height: 20.sp,
//                           child: CircleAvatar(
//                             child: ClipOval(
//                               child: AssetImageBox(
//                                 height: 20.sp,
//                                 width: 20.sp,
//                                 assetImage: AppImages.kDemoUser,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//       drawer: CustomDrawer(indexClicked: 2),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Filter by Status Dropdown
//                 SizedBox(height: 20.h),

//                 // Dropdown + Search
//                 SizedBox(
//                   width: 120.w,
//                   child: DropdownButtonFormField<String>(
//                     initialValue: selectedStatus,
//                     items: statusOptions.map((e) {
//                       return DropdownMenuItem(value: e, child: Text(e));
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedStatus = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 10.h,
//                         horizontal: 10.w,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Container(
//                   margin: EdgeInsets.only(left: 20.w),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Search',
//                       prefixIcon: Icon(Icons.search),
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 10.h,
//                         horizontal: 10.w,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         searchQuery = value;
//                       });
//                     },
//                   ),
//                 ),

//                 SizedBox(height: 30.h),

//                 // DataTable
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withValues(alpha: 0.2),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minWidth: constraints.maxWidth,
//                         ),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: DataTable(
//                             columns: [
//                               DataColumn(
//                                 label: SizedBox(
//                                   width: 100.w,
//                                   child: Text(
//                                     'First Name',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14.sp,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: SizedBox(
//                                   width: 100.w,
//                                   child: Text(
//                                     'Last Name',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14.sp,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: SizedBox(
//                                   width: 100.w,
//                                   child: Text(
//                                     'Status',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14.sp,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: SizedBox(
//                                   width: 60.w,
//                                   child: Text(
//                                     'Action',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14.sp,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                             rows: data
//                                 .where((item) {
//                                   final firstName = item['firstName']
//                                       .toLowerCase();
//                                   final lastName = item['lastName']
//                                       .toLowerCase();
//                                   final status = item['status'].toLowerCase();
//                                   final query = searchQuery.toLowerCase();

//                                   if (selectedStatus == 'All Statuses') {
//                                     return firstName.contains(query) ||
//                                         lastName.contains(query) ||
//                                         status.contains(query);
//                                   } else {
//                                     return (selectedStatus!.toLowerCase() ==
//                                                 status ||
//                                             status.contains(query)) &&
//                                         (firstName.contains(query) ||
//                                             lastName.contains(query));
//                                   }
//                                 })
//                                 .map((item) {
//                                   Color statusColor =
//                                       item['status'] == 'Scheduled'
//                                       ? Colors.green
//                                       : Colors.amber;

//                                   return DataRow(
//                                     selected:
//                                         item['firstName'] == 'Data' &&
//                                         item['lastName'] == 'Test',
//                                     onSelectChanged: (value) {
//                                       // Handle selection if needed
//                                     },
//                                     cells: [
//                                       DataCell(
//                                         SizedBox(
//                                           width: 100.w,
//                                           child: Text(
//                                             item['firstName'],
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 100.w,
//                                           child: Text(
//                                             item['lastName'],
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         Container(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 10.w,
//                                             vertical: 5.h,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: statusColor,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             item['status'],
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 12.sp,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         IconButton(
//                                           icon: Icon(Icons.edit),
//                                           onPressed: () {},
//                                           iconSize: 18.sp,
//                                         ),
//                                         onTap: () {
//                                           // Optional: handle tap
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 })
//                                 .toList(),
//                             columnSpacing: 10.w,
//                             horizontalMargin: 10.w,
//                             // Optional: control text overflow
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
