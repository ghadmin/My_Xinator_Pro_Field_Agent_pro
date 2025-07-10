import 'package:get/get.dart';

import '../modules/appointment/bindings/appointment_binding.dart';
import '../modules/appointment/views/appointment_details_view.dart';
import '../modules/appointment/views/appointment_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/sign_up_view.dart';
import '../modules/billAbleItem/bindings/billable_item_binding.dart';
import '../modules/billAbleItem/views/billable_item_screen.dart';
import '../modules/customer/bindings/customer_binding.dart';
import '../modules/customer/views/customer_details_view.dart';
import '../modules/customer/views/customer_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/create_invoice_view.dart';
import '../modules/invoice/views/invoice_details_view.dart';
import '../modules/invoice/views/manual_payment_view.dart';
import '../modules/invoice/views/payment_by_a_c_h_view.dart';
import '../modules/invoice/views/payment_by_cash_view.dart';
import '../modules/invoice/views/payment_by_check_view.dart';
import '../modules/invoice/views/payment_method_selection_view.dart';
import '../modules/item/bindings/item_binding.dart';
import '../modules/item/views/item_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/appointment_settings_view.dart';
import '../modules/settings/views/appointment_status_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/views/ticket_status_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT,
      page: () => const AppointmentView(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT_DETAILS,
      page: () => const AppointmentDetailsView(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.BILLABLE_ITEMS,
      page: () => BillableItemsMobileScreen(),
      binding: BillableItemBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT_SETTINGS,
      page: () => const AppointmentSettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_DETAILS,
      page: () => const CustomerDetailsView(),
      binding: CustomerBinding(),
    ),
    // GetPage(
    //   name: _Paths.INVOICE,
    //   page: () => const InvoiceView(),
    //   binding: InvoiceBinding(),
    // ),
    GetPage(
      name: _Paths.INVOICE_CREATE,
      page: () => const CreateInvoiceView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.INVOICE_DETAILS,
      page: () => const InvoiceDetailsView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.TICKET_STATUS,
      page: () => const TicketStatusView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT_STATUS,
      page: () => const AppointmentStatusView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.ITEM,
      page: () => const ItemView(),
      binding: ItemBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_METHOD_SELECTION,
      page: () => const PaymentMethodSelectionView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_BY_CASH,
      page: () => const PaymentByCashView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_BY_CHECK,
      page: () => const PaymentByCheckView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_BY_BANK_TRANSFER,
      page: () => const PaymentByACHView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.MANUAL_PAYMENT,
      page: () => const ManualPaymentView(),
      binding: InvoiceBinding(),
    ),
  ];
}
