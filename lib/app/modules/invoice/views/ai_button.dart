// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';
// import 'package:xinator_fsm_pro/app/modules/item/controllers/item_controller.dart';

// class Message {
//   final String text;
//   final bool isUserMessage;

//   Message({required this.text, this.isUserMessage = true});
// }

// class GioPagla extends GetxController {
//   final isTyping = false.obs;
//   final loading = false.obs;
//   final itemController = Get.find<ItemController>();
//   final inController = Get.find<InvoiceController>();
//   // Assuming InvoiceController is defined elsewhere
//   final tcontroller = Rx<TextEditingController>(TextEditingController());
//   final focusNode = Rx<FocusNode>(FocusNode());
//   final List<Message> messages = [];
//   void sendMessage() {
//     final text = tcontroller.value.text.trim();
//     if (text.isNotEmpty) {
//       if (text == "hello" || text == "hi") {
//         messages.add(Message(
//             text: "Hi there! How can I assist you today?",
//             isUserMessage: false));
//       } else if (text.contains("add item")) {
//         messages.add(Message(
//           text:
//               "Sure! Please tell me what item you'd like to add. \n\n${itemController.sortedItems.map((item) => item.name).join(', \n')}",
//           isUserMessage: false,
//         ));
//       } else if (text.contains("IT Service")) {
//         messages.add(Message(
//           text: "Sure!",
//           isUserMessage: false,
//         ));

//         inController.selectedItemList.add(itemController.sortedItems.first);
//         inController.editAmountControllers.add(TextEditingController(
//             text: inController.selectedItemList.first.price.toString()));
//         inController.editDescriptionControllers.add(TextEditingController(
//             text: inController.selectedItemList.first.description ?? ""));
//         inController.editQuantityControllers
//             .add(TextEditingController(text: '1'));
//         inController.createTotalForEdit();
//       }
//     }
//     messages.add(Message(text: text));
//     tcontroller.value.clear();
//     // controller.isTyping(false);
//     focusNode.value.unfocus();
//   }

//   void toggleTyping() {
//     if (isTyping.value) {
//       isTyping(false);
//       tcontroller.value.clear();
//       focusNode.value.unfocus();
//       messages.clear();
//     } else {
//       isTyping(true);
//       Future.delayed(const Duration(milliseconds: 100), () {
//         focusNode.value.requestFocus();
//       });
//     }
//   }
// }

// Widget floatButton(BuildContext context) {
//   final GioPagla controller = Get.put(GioPagla());

//   return Obx(
//     () => Stack(
//       children: [
//         // Mini conversation card (top of FAB)
//         Positioned(
//           bottom: 90,
//           right: 20,
//           child: AnimatedOpacity(
//             opacity: controller.messages.isNotEmpty ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 300),
//             child: controller.messages.isNotEmpty
//                 ? Container(
//                     width: 230,
//                     padding: const EdgeInsets.all(25),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         // crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: controller.messages.reversed
//                             .take(3)
//                             .map((msg) => Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 2),
//                                   child: Align(
//                                     child: Text(msg.text,
//                                         style: TextStyle(
//                                             overflow: TextOverflow.visible,
//                                             fontSize: 20,
//                                             color: msg.isUserMessage
//                                                 ? Colors.black
//                                                 : Colors.blue,
//                                             fontWeight: FontWeight.w500)),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ),

//         // Input Field
//         Positioned(
//           bottom: 20,
//           right: 80,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: controller.isTyping.value ? 220 : 0,
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 5,
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: controller.isTyping.value
//                 ? Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: controller.tcontroller.value,
//                           focusNode: controller.focusNode.value,
//                           decoration: const InputDecoration(
//                             hintText: "Type...",
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send, color: Colors.blue),
//                         onPressed: controller.sendMessage,
//                       ),
//                     ],
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ),

//         // Chat Button
//         Positioned(
//           bottom: 20,
//           right: 20,
//           child: FloatingActionButton(
//             onPressed: controller.toggleTyping,
//             child: Icon(controller.isTyping.value ? Icons.close : Icons.chat),
//           ),
//         ),
//       ],
//     ),
//   );
// }
