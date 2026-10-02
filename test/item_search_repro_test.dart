import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:myxinator_pro_field_agent_pro/app/modules/item/controllers/item_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/item/models/item_bundle_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/item/models/item_group_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/item/models/item_list_model.dart';

class _FakeItem extends ItemListModel {
  _FakeItem(String? itemName) {
    name = itemName;
  }
}

class _FakeGroup extends ItemGroupModel {
  _FakeGroup(String groupName, List<ItemListModel> groupItems) {
    this.groupName = groupName;
    items = groupItems;
  }
}

void main() {
  // GetX keeps registrations across tests; drop them so each test gets a
  // fresh controller (otherwise a stale query/mode leaks between tests).
  tearDown(() {
    Get.reset();
  });

  ItemController buildController() {
    final controller = Get.put(ItemController());
    controller.items.assignAll([
      _FakeItem('Widget A'),
      _FakeItem('Gizmo B'),
      _FakeItem('Widget C'),
    ]);
    return controller;
  }

  testWidgets('name mode: typing filters the Obx list', (tester) async {
    final controller = buildController();
    controller.sortItems();

    int renderedCount = -1;
    Widget probe() => Obx(() {
          final List<ItemListModel> items = controller.sortedItems;
          renderedCount = items.length;
          return Text('count=$renderedCount');
        });

    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: probe())));
    expect(renderedCount, 3);

    controller.sortTextController.text = 'widget';
    controller.sortItems();
    await tester.pump();

    expect(controller.sortedItems.length, 2,
        reason: 'sortItems should filter into sortedItems');
    expect(renderedCount, 2, reason: 'Obx must rebuild on sortedItems change');
  });

  test('group mode: search filters the selected group items', () {
    final controller = buildController();
    controller.selectedItemGroup.value =
        _FakeGroup('Fasteners', [_FakeItem('Bolt'), _FakeItem('Nail')]);
    controller.searchByType.value = SearchByType.group;
    controller.sortItems();
    expect(controller.sortedItems.length, 2);

    controller.sortTextController.text = 'nail';
    controller.sortItems();
    expect(controller.sortedItems.length, 1);
    expect(controller.sortedItems.first.name, 'Nail');
  });

  test('bundle mode: search filters the selected bundle items', () {
    final controller = buildController();
    final bundle = ItemBundleModel();
    bundle.bundleName = 'Kit';
    bundle.items = [_FakeItem('Hammer'), _FakeItem('Screwdriver')];
    controller.selectedItemBundle.value = bundle;
    controller.searchByType.value = SearchByType.bundle;
    controller.sortItems();
    expect(controller.sortedItems.length, 2);

    controller.sortTextController.text = 'ham';
    controller.sortItems();
    expect(controller.sortedItems.length, 1);
  });

  test('null item names do not crash the filter', () {
    final controller = buildController();
    controller.items.add(_FakeItem(null));
    controller.sortTextController.text = 'widget';
    controller.sortItems();
    expect(controller.sortedItems.length, 2);
  });
}
