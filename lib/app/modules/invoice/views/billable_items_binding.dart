import 'package:get/get.dart';
import '../../item/controllers/item_controller.dart';

class BillableItemsBinding extends Bindings {
  @override
  void dependencies() {
    // ItemController needs to be initialized before BillableItemsController
    // because BillableItemsController depends on it.
    Get.lazyPut<ItemController>(() => ItemController());
  }
}
