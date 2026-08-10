import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/appointment_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/resource_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/service_type_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/time_slot_model.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../../utils/klog.dart';

class CreateAppointmentController extends GetxController with ExceptionHandler {
  // Text controllers for form fields
  final businessNameController = TextEditingController();
  final titleController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipCodeController = TextEditingController();
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final appointmentIdController = TextEditingController();
  final isAppointmentIdLoading = false.obs;
  final timeRequired = ''.obs;

  // Form state
  final selectedDate = Rxn<DateTime>();
  final selectedTimeSlot = Rxn<String>();
  final selectedCalendar = RxString('');
  final selectedCEC = RxString('');
  final selectedServiceType = Rxn<int>();
  final selectedResource = Rxn<int>();
  final selectedStatus = Rxn<int>();
  final selectedState = RxString('');
  final selectedSite = Rxn<int>();

  // Calendar state
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>();

  // UI state
  final currentStep = 0.obs; // 0: calendar, 1: slots, 2: form
  final isCalendarSelected = false.obs;
  final isSlotSelected = false.obs;
  final selectedCustomer = Rx<Customer?>(null);
  final isLoadingTimeSlots = false.obs;
  final isLoadingServiceTypes = false.obs;
  final isLoadingResources = false.obs;

  // Available time slots
  final availableSlots = <String>[].obs;
  final timeSlotModels = <TimeSlotModel>[].obs;

  // Service types from API
  final serviceTypeModels = <ServiceTypeModel>[].obs;

  // Resources from API
  final resourceModels = <ResourceModel>[].obs;

  // Dropdown options (these should be populated from API in real app)
  @Deprecated('Use resourceModels instead')
  final resources = <Map<String, dynamic>>[
    {'id': 1, 'name': 'John Doe'},
    {'id': 2, 'name': 'Jane Smith'},
    {'id': 3, 'name': 'Mike Johnson'},
  ].obs;

  final statuses = <Map<String, dynamic>>[
    {'id': 1, 'name': 'Pending'},
    {'id': 2, 'name': 'Scheduled'},
    {'id': 3, 'name': 'Cancelled'},
    {'id': 4, 'name': 'Completed'},
    {'id': 5, 'name': 'Closed'},
  ].obs;

  final states = <String>[
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ].obs;

  final sites = <Map<String, dynamic>>[
    {'id': 1, 'name': 'Main Office'},
    {'id': 2, 'name': 'Branch Office A'},
    {'id': 3, 'name': 'Branch Office B'},
  ].obs;

  final calendars = <String>['CEC', 'FSM'].obs;

  @override
  void onInit() {
    super.onInit();
    // Set default date to today
    focusedDay.value = DateTime.now();
    selectedDay.value = DateTime.now();
    // Load time slots
    loadTimeSlots();
    // Fetch next appointment number
    getNextAppointmentNumber();
  }

  // Load time slots from API
  Future<void> loadTimeSlots() async {
    try {
      isLoadingTimeSlots.value = true;
      await getTimeSlots(showLoader: false);
    } finally {
      isLoadingTimeSlots.value = false;
    }
  }

  /// Get time slots from API
  Future<void> getTimeSlots({bool showLoader = true}) async {
    try {
      if (showLoader) {
        showLoading();
      }

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        var response = await DioClient()
            .get(
              url: ApiUrl.getTimeSlotListUrl,
              params: {"companyId": companyID},
            )
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) {
            hideLoading();
          }
          return;
        }

        kLog("getTimeSlots response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          timeSlotModels.assignAll(
            response
                .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          );

          // Convert TimeSlotModel list to string list for display
          availableSlots.clear();
          for (var slot in timeSlotModels) {
            availableSlots.add(
              slot.startTime,
            ); // or use slot.label for full display
          }
        } else {
          timeSlotModels.clear();
          availableSlots.clear();
        }

        if (showLoader) {
          hideLoading();
        }
      } else {
        if (showLoader) {
          hideLoading();
        }
        MySnackBar.showErrorToast(message: "No network connection");
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) {
        hideLoading();
      }
    }
  }

  /// Get service types from API based on selected calendar
  Future<void> getServiceTypeList({bool showLoader = false}) async {
    try {
      if (showLoader) {
        showLoading();
      }
      isLoadingServiceTypes.value = true;

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        // Build request body based on selected calendar
        Map<String, dynamic> requestBody = {
          "companyId": companyID,
          "schedulingCal": selectedCalendar.value.isNotEmpty
              ? selectedCalendar.value
              : "",
        };

        var response = await DioClient()
            .post(url: ApiUrl.getServiceTypeListUrl, body: requestBody)
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) {
            hideLoading();
          }
          return;
        }

        kLog("getServiceTypeList response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          serviceTypeModels.assignAll(
            response
                .map(
                  (e) => ServiceTypeModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );

          // Clear previous service type selection if the list has changed
          if (selectedServiceType.value != null) {
            // Check if the selected service type still exists in the new list
            final exists = serviceTypeModels.any(
              (type) => type.serviceTypeId == selectedServiceType.value,
            );
            if (!exists) {
              selectedServiceType.value = null;
              timeRequired.value = '';
            }
          }
        } else {
          serviceTypeModels.clear();
          selectedServiceType.value = null;
          timeRequired.value = '';
        }

        if (showLoader) {
          hideLoading();
        }
      } else {
        if (showLoader) {
          hideLoading();
        }
        MySnackBar.showErrorToast(message: "No network connection");
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) {
        hideLoading();
      }
    } finally {
      isLoadingServiceTypes.value = false;
    }
  }

  /// Get resources from API based on service type and calendar
  Future<void> getResourceList({bool showLoader = false}) async {
    try {
      if (showLoader) {
        showLoading();
      }
      isLoadingResources.value = true;

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        // Build request body based on selected service type and calendar
        Map<String, dynamic> requestBody = {
          "companyId": companyID,
          "serviceTypeId": selectedServiceType.value?.toString() ?? "",
          "schedulingCal": selectedCalendar.value.isNotEmpty
              ? selectedCalendar.value
              : "",
        };

        var response = await DioClient()
            .post(url: ApiUrl.getResourceListUrl, body: requestBody)
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) {
            hideLoading();
          }
          return;
        }

        kLog("getResourceList response: $response");

        // Parse response - API returns an array
        if (response is List && response.isNotEmpty) {
          resourceModels.assignAll(
            response
                .map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          );

          // Auto-select resource matching logged-in user's email
          await _autoSelectResourceByEmail();

          // Clear previous resource selection if the list has changed
          if (selectedResource.value != null) {
            final exists = resourceModels.any(
              (resource) => resource.id == selectedResource.value,
            );
            if (!exists) {
              selectedResource.value = null;
            }
          }
        } else {
          resourceModels.clear();
          selectedResource.value = null;
        }

        if (showLoader) {
          hideLoading();
        }
      } else {
        if (showLoader) {
          hideLoading();
        }
        MySnackBar.showErrorToast(message: "No network connection");
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) {
        hideLoading();
      }
    } finally {
      isLoadingResources.value = false;
    }
  }

  /// Auto-select resource that matches logged-in user's email
  Future<void> _autoSelectResourceByEmail() async {
    try {
      final userEmail = await MySharedPref.getEmail();
      if (userEmail == null || userEmail.isEmpty) {
        kLog("No user email found in shared preferences");
        return;
      }

      // Find resource with matching email
      final matchingResource = resourceModels.firstWhereOrNull(
        (resource) =>
            resource.email.toLowerCase().trim() ==
            userEmail.toLowerCase().trim(),
      );

      if (matchingResource != null) {
        selectedResource.value = matchingResource.id;
        kLog(
          "Auto-selected resource: ${matchingResource.name} (${matchingResource.email})",
        );
      } else {
        kLog("No matching resource found for email: $userEmail");
      }
    } catch (e) {
      kLog("Error auto-selecting resource: $e");
    }
  }

  /// Get next appointment number from API
  Future<void> getNextAppointmentNumber({bool showLoader = false}) async {
    try {
      if (showLoader) {
        showLoading();
      }
      isAppointmentIdLoading.value = true;

      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        var response = await DioClient()
            .post(
              url: ApiUrl.getNextAppointmentNumberUrl,
              body: {"companyId": companyID},
            )
            .catchError(showLoader ? handleError : (e) => null);

        if (response == null) {
          if (showLoader) {
            hideLoading();
          }
          return;
        }

        kLog("getNextAppointmentNumber response: $response");

        // Parse response - Expected format: {"Status": "success", "Response": "10042"}
        if (response is Map<String, dynamic>) {
          final status = response['Status'];
          final appointmentNumber = response['Response'];

          if (status == 'success' && appointmentNumber != null) {
            appointmentIdController.text = appointmentNumber.toString();
          } else {
            kLog("Failed to get next appointment number: $status");
          }
        }

        if (showLoader) {
          hideLoading();
        }
      } else {
        if (showLoader) {
          hideLoading();
        }
        MySnackBar.showErrorToast(message: "No network connection");
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      if (showLoader) {
        hideLoading();
      }
    } finally {
      isAppointmentIdLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    businessNameController.dispose();
    titleController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    jobTitleController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    mobileController.dispose();
    phoneController.dispose();
    emailController.dispose();
    appointmentIdController.dispose();
    super.onClose();
  }

  // Calendar methods
  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    selectedDate.value = selected;
    isCalendarSelected.value = true;

    // Load time slots when moving to slot selection
    loadTimeSlots();

    // Move to slot selection step
    currentStep.value = 1;
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  // Slot selection
  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = slot;
    isSlotSelected.value = true;

    // Move to form step
    currentStep.value = 2;
  }

  // Service type selection
  void onServiceTypeSelected(int? serviceTypeId) {
    selectedServiceType.value = serviceTypeId;

    // Find the selected service type and update time required
    if (serviceTypeId != null) {
      final serviceType = serviceTypeModels.firstWhereOrNull(
        (type) => type.serviceTypeId == serviceTypeId,
      );

      if (serviceType != null) {
        // Set time required from the service type
        timeRequired.value = serviceType.timeDuration;
        kLog(
          "Service type selected: ${serviceType.serviceName}, "
          "Time required: ${serviceType.timeDuration}",
        );

        // Load resources for this service type
        getResourceList(showLoader: true);
      }
    } else {
      timeRequired.value = '';
      // Clear resources when no service type is selected
      resourceModels.clear();
      selectedResource.value = null;
    }
  }

  // Calendar selection handler
  void onCalendarSelected(String? calendar) {
    selectedCalendar.value = calendar ?? '';

    // Load service types when calendar changes
    if (calendar != null && calendar.isNotEmpty) {
      getServiceTypeList(showLoader: true);

      // Clear service type and resource selection
      selectedServiceType.value = null;
      timeRequired.value = '';
      resourceModels.clear();
      selectedResource.value = null;
    }
  }

  // Navigation methods
  void backToCalendar() {
    currentStep.value = 0;
  }

  void backToSlots() {
    // Reload time slots if needed (optional)
    if (timeSlotModels.isEmpty) {
      loadTimeSlots();
    }
    currentStep.value = 1;
  }

  // Form submission
  void submitAppointment() {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    final customer = selectedCustomer.value;
    final customerAddress =
        '${customer?.address1 ?? ''}${customer?.address2 != null && customer!.address2!.isNotEmpty ? ', ${customer.address2}' : ''}';

    // Create appointment data
    final appointmentData = {
      'startDate': _formatDateTime(selectedDate.value, selectedTimeSlot.value),
      'endDate': _formatEndDate(selectedDate.value, selectedTimeSlot.value),
      'calendar': selectedCalendar.value,
      'cec': selectedCEC.value,
      'appointmentId': appointmentIdController.text,
      'timeRequired': timeRequired.value,
      'serviceTypeId': selectedServiceType.value,
      'resourceId': selectedResource.value,
      'statusId': selectedStatus.value,
      'appointmentTime': selectedTimeSlot.value,
      'businessName': customer?.businessName ?? customer?.companyName ?? '',
      'title': customer?.title ?? '',
      'firstName': customer?.firstName ?? '',
      'lastName': customer?.lastName ?? '',
      'jobTitle': customer?.jobTitle ?? '',
      'address': customerAddress,
      'city': customer?.city ?? '',
      'state': customer?.state ?? '',
      'zipCode': customer?.zipCode ?? '',
      'mobile': customer?.mobile ?? '',
      'phone': customer?.phone ?? '',
      'email': customer?.email ?? '',
      'customerId': customer?.customerID ?? '',
      'siteId': selectedSite.value,
    };

    // Here you would make API call to create appointment
    print('Creating appointment with data: $appointmentData');

    // Show success message and navigate back
    Get.snackbar(
      'Success',
      'Appointment created successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate back to appointment list
    Get.back();
  }

  // Validation
  bool _validateForm() {
    if (selectedDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select a date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedTimeSlot.value == null) {
      Get.snackbar(
        'Error',
        'Please select a time slot',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Error',
        'Please select a customer',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final customer = selectedCustomer.value!;
    if (customer.firstName == null || customer.firstName!.isEmpty) {
      Get.snackbar(
        'Error',
        'Customer first name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (customer.lastName == null || customer.lastName!.isEmpty) {
      Get.snackbar(
        'Error',
        'Customer last name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (customer.email == null || customer.email!.isEmpty) {
      Get.snackbar(
        'Error',
        'Customer email is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!GetUtils.isEmail(customer.email!)) {
      Get.snackbar(
        'Error',
        'Customer email is invalid',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  // Helper methods
  String _formatDateTime(DateTime? date, String? time) {
    if (date == null || time == null) return '';
    final dateFormat = DateFormat('MM/dd/yyyy hh:mm a');
    // Parse the time slot and combine with date
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = timeFormat.parse(time);
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );
    return dateFormat.format(combinedDateTime);
  }

  String _formatEndDate(DateTime? date, String? time) {
    // For now, same as start date. You can add duration logic later
    return _formatDateTime(date, time);
  }

  String getFormattedSelectedDate() {
    if (selectedDate.value == null) return '';
    return DateFormat('MM/dd/yyyy').format(selectedDate.value!);
  }

  void clearForm() {
    businessNameController.clear();
    titleController.clear();
    firstNameController.clear();
    lastNameController.clear();
    jobTitleController.clear();
    addressController.clear();
    cityController.clear();
    zipCodeController.clear();
    mobileController.clear();
    phoneController.clear();
    emailController.clear();
    appointmentIdController.clear();
    timeRequired.value = '';

    selectedCalendar.value = '';
    selectedCEC.value = '';
    selectedServiceType.value = null;
    selectedResource.value = null;
    selectedStatus.value = null;
    selectedState.value = '';
    selectedSite.value = null;
    selectedCustomer.value = null;

    currentStep.value = 0;
    isCalendarSelected.value = false;
    isSlotSelected.value = false;
  }

  void generateAppointmentId() {
    // Generate a random appointment ID
    appointmentIdController.text = DateTime.now().millisecondsSinceEpoch
        .toString();
  }
}
