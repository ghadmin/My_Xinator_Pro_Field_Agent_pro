import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_buttons.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/equipment/controllers/equipment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/equipment_form_modal.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';

class EquipmentTabScreen extends StatefulWidget {
  const EquipmentTabScreen({super.key});

  @override
  State<EquipmentTabScreen> createState() => _EquipmentTabScreenState();
}

class _EquipmentTabScreenState extends State<EquipmentTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  final EquipmentController equipmentController = Get.find<EquipmentController>();

  @override
  void initState() {
    super.initState();
    controller.getCustomerSite(showLoader: true);
    final appointment = controller.selectedAppointment.value;
    if (appointment != null) {
      equipmentController.fetchEquipment(
        customerGuid: appointment.customer?.customerGuid ?? '',
        siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
        companyId: appointment.companyID,
      );
      equipmentController.fetchEquipmentTypes(
        companyId: appointment.companyID,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text(
          'Equipment',
          style: WarmOrganicBlueTheme.headingMedium,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(
          () => Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryButtonWithIcon(
                  title: 'Add Equipment',
                  onPressed: () {
                    Get.bottomSheet(
                      EquipmentFormModal(
                        equipmentTypes: equipmentController.equipmentTypes,
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  iconData: Icons.add,
                  inactive: false,
                ),
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: equipmentController.equipment.isNotEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrganicSectionTitle(title: 'Equipment List'),
                            ...equipmentController.equipment.map(
                              (equipment) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: EquipmentCard(
                                  equipment: equipment,
                                  onEdit: () => Get.bottomSheet(
                                    EquipmentFormModal(
                                      equipment: equipment,
                                      equipmentTypes: equipmentController.equipmentTypes,
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  onDelete: () async {
                                    final confirm = await Get.dialog<bool>(
                                      AlertDialog(
                                        title: const Text('Delete Equipment'),
                                        content: const Text(
                                          'Are you sure you want to delete this equipment?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(result: false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.back(result: true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final appointment =
                                          controller.selectedAppointment.value;
                                      if (appointment != null) {
                                        await equipmentController.deleteEquipment(
                                          id: equipment.id,
                                          customerGuid:
                                              appointment.customer?.customerGuid ?? '',
                                          siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
                                          companyId: appointment.companyID,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 80.h),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.construction, size: 64.sp, color: Colors.grey),
                            SizedBox(height: 16.h),
                            Text(
                              'No equipment added yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
