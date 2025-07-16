import 'package:flutter/material.dart';

import 'package:get/get.dart';

class BnplView extends GetView {
  const BnplView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BnplView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BnplView is working',
          textScaler: TextScaler.linear(1.0),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
