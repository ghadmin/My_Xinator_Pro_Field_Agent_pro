import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/appointment/bindings/appointment_binding.dart';
import '../../modules/appointment/bindings/custom_fields_binding.dart';
import '../../modules/appointment/controllers/appointment_controller.dart';
import '../../modules/appointment/controllers/create_appointment_controller.dart';
import '../../modules/appointment/controllers/custom_fields_controller.dart';
import '../../modules/appointment/parts/equipment/controllers/equipment_controller.dart';
import '../../modules/appointment/parts/file/controllers/file_controller.dart';
import '../../modules/appointment/parts/image/controllers/image_controller.dart';
import '../../modules/appointment/parts/notes/controllers/notes_controller.dart';
import '../../modules/appointment/views/appointment_view.dart';
import '../../modules/customer/bindings/customer_binding.dart';
import '../../modules/customer/controllers/customer_controller.dart';
import '../../modules/customer/views/customer_view.dart';
import '../../modules/forms/binding/form_bindings.dart';
import '../../modules/forms/controllers/forms_controller.dart';
import '../../modules/invoice/controllers/invoice_controller.dart';
import '../../modules/item/bindings/item_binding.dart';
import '../../modules/item/controllers/item_controller.dart';
import '../../modules/item/views/item_view.dart';
import '../../modules/settings/controllers/settings_controller.dart';
import 'tablet_shell_scope.dart';

/// Tablet landing page.
///
/// Instead of pushing a route per menu entry, the shell is ONE route: the
/// menu itself is hidden — each hosted screen shows the standard overlay
/// drawer (hamburger tap) — and tapping an item there just swaps the hosted
/// screen (see [TabletShellScope]). Phones never reach this route; they push
/// navigation per drawer tap.
///
/// Controller lifecycle: each hosted screen is bound by replaying the same
/// bindings its route uses (see [_ensureDependencies]) on first visit, and
/// the instances stay alive across switches so list state is preserved.
/// Because there is no route pop to trigger GetX's cleanup, [dispose]
/// deletes them — logout removes this route, so the next login starts with
/// a fresh set instead of the previous session's data.
class TabletShellView extends StatefulWidget {
  const TabletShellView({super.key});

  @override
  State<TabletShellView> createState() => _TabletShellViewState();
}

class _TabletShellViewState extends State<TabletShellView> {
  /// Menu indices — must match the indexNumbers in DrawerMenuContent.
  static const int _homeIndex = 0;
  static const int _itemsIndex = 1;
  static const int _customersIndex = 2;

  int _selectedIndex = _homeIndex;

  @override
  void initState() {
    super.initState();
    // The first screen builds immediately, so its controller must be
    // registered before GetView runs Get.find.
    _ensureDependencies(_selectedIndex);
  }

  /// Menu tap → swap the hosted screen. No route is pushed; tapping the
  /// already-selected item is a no-op (a menu entry must not navigate).
  void _select(int indexNumber) {
    if (indexNumber == _selectedIndex) return;
    setState(() {
      _ensureDependencies(indexNumber);
      _selectedIndex = indexNumber;
    });
  }

  /// Replay the route bindings of the tapped menu entry — the same set its
  /// GetPage in app_pages.dart applies. Guarded by isRegistered because the
  /// entries only run once per session here (and detail routes pushed from
  /// the hosted screens may have registered some of them already).
  void _ensureDependencies(int indexNumber) {
    switch (indexNumber) {
      case _homeIndex:
        if (!Get.isRegistered<AppointmentController>()) {
          AppointmentBinding().dependencies();
          CustomFieldsBinding().dependencies();
          FormBindings().dependencies();
        }
        break;
      case _itemsIndex:
        if (!Get.isRegistered<ItemController>()) {
          ItemBinding().dependencies();
        }
        break;
      case _customersIndex:
        if (!Get.isRegistered<CustomerController>()) {
          CustomerBinding().dependencies();
        }
        break;
    }
  }

  /// Deletes every controller the shell's bindings (and
  /// AppointmentController's own field initializers) registered, mirroring
  /// what GetX's SmartManagement does when a route stack is popped.
  void _disposeControllers() {
    void delete<T>() {
      if (Get.isRegistered<T>()) Get.delete<T>(force: true);
    }

    // Hosted tab screens
    delete<AppointmentController>();
    delete<ItemController>();
    delete<CustomerController>();

    // Registered alongside: AppointmentBinding parts, FormBindings, and the
    // controllers AppointmentController's field initializers Get.put.
    delete<ImageController>();
    delete<FileController>();
    delete<NotesController>();
    delete<EquipmentController>();
    delete<FormsController>();
    delete<CustomFieldsController>();
    delete<SettingsController>();
    delete<InvoiceController>();
    delete<CreateAppointmentController>();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Widget get _currentScreen {
    switch (_selectedIndex) {
      case _itemsIndex:
        return const ItemView();
      case _customersIndex:
        return const CustomerView();
      default:
        return const AppointmentView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // No shell chrome: the hosted screen fills the window and draws its own
    // overlay drawer (hidden until the hamburger tap) at every width. The
    // scope carries the selection so that drawer swaps screens instead of
    // pushing routes.
    return TabletShellScope(
      selectedIndex: _selectedIndex,
      onItemTap: _select,
      child: _currentScreen,
    );
  }
}
