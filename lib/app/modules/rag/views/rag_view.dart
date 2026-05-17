// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/rag_controller.dart';

// class RAGView extends GetView<RAGController> {
//   const RAGView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ChatBot'),
//         backgroundColor: Get.theme.colorScheme.primary,
//         foregroundColor: Colors.white,
//         actions: [],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildQuestionInput(),
//             const SizedBox(height: 16),
//             // _buildSuggestedQuestions(),
//             // const SizedBox(height: 24),
//             _buildAnswerSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionInput() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         TextField(
//           controller: controller.questionController,
//           decoration: InputDecoration(
//             hintText: 'Ask about your appointments...',
//             prefixIcon: const Icon(Icons.search),
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.send),
//               onPressed: controller.askQuestion,
//             ),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: Colors.grey[100],
//           ),
//           maxLines: null,
//           textInputAction: TextInputAction.newline,
//           onSubmitted: (_) => controller.askQuestion(),
//         ),
//         const SizedBox(height: 8),
//         Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         }),
//       ],
//     );
//   }

//   Widget _buildSuggestedQuestions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Suggested Questions:',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: controller.getSuggestedQuestions().map((question) {
//             return ActionChip(
//               label: Text(question),
//               onPressed: () {
//                 controller.questionController.text = question;
//                 controller.askQuestion();
//               },
//               backgroundColor: Get.theme.colorScheme.primaryContainer,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildAnswerSection() {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return const SizedBox.shrink();
//       }

//       if (controller.hasError.value) {
//         return Card(
//           color: Colors.red[50],
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 const Icon(Icons.error, color: Colors.red),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     controller.errorMessage.value,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }

//       if (controller.answer.value.isEmpty) {
//         return Card(
//           color: Colors.grey[100],
//           child: const Padding(
//             padding: EdgeInsets.all(24),
//             child: Center(
//               child: Text(
//                 'Ask a question to see results here',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//         );
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.psychology, color: Colors.blue),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'Answer',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(controller.answer.value),
//                 ],
//               ),
//             ),
//           ),
//           if (controller.sources.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             const Text(
//               'Sources',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...controller.sources.map(
//               (source) => Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: ExpansionTile(
//                   title: Text(
//                     source.metadata.title ?? 'Unknown Appointment',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(source.metadata.startDateTime ?? 'No date'),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (source.metadata.customerName != null) ...[
//                             const Text(
//                               'Customer:',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(source.metadata.customerName!),
//                             const SizedBox(height: 8),
//                           ],
//                           if (source.metadata.location != null) ...[
//                             const Text(
//                               'Location:',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(source.metadata.location!),
//                             const SizedBox(height: 8),
//                           ],
//                           if (source.metadata.status != null) ...[
//                             const Text(
//                               'Status:',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(source.metadata.status!),
//                             const SizedBox(height: 8),
//                           ],
//                           const Divider(),
//                           const Text(
//                             'Full Context:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(source.content),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       );
//     });
//   }

//   Color _getConfidenceColor(double confidence) {
//     if (confidence >= 0.8) return Colors.green;
//     if (confidence >= 0.5) return Colors.orange;
//     return Colors.red;
//   }
// }
