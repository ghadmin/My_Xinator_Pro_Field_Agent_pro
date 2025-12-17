import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../components/global-widgets/text_widget.dart';

class BnplView extends GetView {
  const BnplView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(text: 'BnplView'),
        centerTitle: true,
      ),
      body: const Center(
        child: TextWidget(
          text: 'BnplView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
