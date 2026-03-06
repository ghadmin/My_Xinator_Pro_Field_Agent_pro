import '../../item/models/item_list_model.dart';

class InvoiceBackupModel {
  List<ItemListModel> items;
  List<String> quantities;
  List<String> amounts;
  List<String> descriptions;
  String note;
  String discount;
  String tax;

  InvoiceBackupModel({
    required this.items,
    required this.quantities,
    required this.amounts,
    required this.descriptions,
    required this.note,
    required this.discount,
    required this.tax,
  });

  factory InvoiceBackupModel.empty() {
    return InvoiceBackupModel(
      items: [],
      quantities: [],
      amounts: [],
      descriptions: [],
      note: "",
      discount: "",
      tax: "",
    );
  }

  bool get isEmpty => items.isEmpty;

  void clear() {
    items.clear();
    quantities.clear();
    amounts.clear();
    descriptions.clear();
    note = "";
    discount = "";
    tax = "";
  }
}
