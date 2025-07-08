import 'package:get/get.dart';

import '../controllers/billable_item_controller.dart';

class BillableItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillableItemController>(
      () => BillableItemController(),
    );
  }
}
