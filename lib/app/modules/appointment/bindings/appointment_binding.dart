import 'package:get/get.dart';

import '../controllers/appointment_controller.dart';
import '../parts/image/controllers/image_controller.dart';
import '../parts/file/controllers/file_controller.dart';
import '../parts/notes/controllers/notes_controller.dart';
import '../parts/equipment/controllers/equipment_controller.dart';

class AppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentController>(
      () => AppointmentController(),
    );
    Get.lazyPut<ImageController>(
      () => ImageController(),
    );
    Get.lazyPut<FileController>(
      () => FileController(),
    );
    Get.lazyPut<NotesController>(
      () => NotesController(),
    );
    Get.lazyPut<EquipmentController>(
      () => EquipmentController(),
    );
  }
}
