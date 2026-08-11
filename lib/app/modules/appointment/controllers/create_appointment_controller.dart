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
  final notesController = TextEditingController();

  // Form state
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();
  final selectedTimeSlot = Rxn<TimeSlotModel>();
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
        } else {
          timeSlotModels.clear();
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
    notesController.dispose();
    super.onClose();
  }

  // Calendar methods
  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    selectedStartDate.value = selected;
    selectedEndDate.value = selected;

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
  void selectTimeSlot(TimeSlotModel slot) {
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
  Future<void> submitAppointment() async {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    try {
      showLoading();

      if (await NetworkConnectivity.isNetworkAvailable()) {
        final customer = selectedCustomer.value;

        // Get required user data
        final companyID = await MySharedPref.getCompanyID();
        final userID = MySharedPref.getResourceID();
        final userEmail = await MySharedPref.getEmail();

        // Get the selected time slot model to extract TimeSlotId
        final selectedTimeSlotModel = timeSlotModels.firstWhereOrNull(
          (slot) => slot.startTime == selectedTimeSlot.value?.startTime,
        );

        if (selectedTimeSlotModel == null) {
          hideLoading();
          MySnackBar.showErrorToast(message: "Selected time slot not found");
          return;
        }

        // Format dates in ISO format (yyyy-MM-ddTHH:mm:ss)
        final startDateTime = _formatISODateTime(
          selectedStartDate.value,
          selectedTimeSlot.value!.startTime,
        );
        final endDateTime = _formatISOEndDate(
          selectedEndDate.value,
          selectedTimeSlot.value!.endTime,
          timeRequired.value,
        );

        // Create appointment data according to API requirements
        final appointmentData = {
          "appointment": {
            "CompanyID": companyID,
            "CustomerID": customer?.customerID ?? '',
            "ServiceTypeId": selectedServiceType.value?.toString() ?? '',
            "ResourceID": selectedResource.value ?? 0,
            "TimeSlotId": selectedTimeSlotModel.id,
            "StartDateTime": startDateTime,
            "EndDateTime": endDateTime,
            "StatusId": selectedStatus.value?.toString() ?? '2',
            "SchedulingCal": selectedCalendar.value.isNotEmpty
                ? selectedCalendar.value
                : 'CEC',
            "Note": notesController.text.isNotEmpty
                ? notesController.text
                : 'Appointment from mobile app',
            "SiteID": selectedSite.value?.toString() ?? '',
            "CreatedBy": userEmail?.isNotEmpty == true
                ? userEmail!.split('@')[0]
                : 'mobile_user',
            "UserID": userID,
          },
        };

        kLog("Creating appointment with data: $appointmentData");

        final response = await DioClient()
            .post(url: ApiUrl.createAppointmentUrl, body: appointmentData)
            .catchError(handleError);

        if (response == null) {
          hideLoading();
          return;
        }

        kLog("Create appointment response: $response");

        // Parse response
        if (response is Map<String, dynamic>) {
          final status = response['Status'];
          final message = response['Message'] ?? response['Response'];

          if (status == 'success' || status == 'Success') {
            hideLoading();

            MySnackBar.showToast(
              message: message ?? 'Appointment created successfully',
            );

            // Clear form and navigate back
            clearForm();
            Get.back(result: true); // Return true to indicate success
          } else {
            hideLoading();
            MySnackBar.showErrorToast(
              message: message ?? 'Failed to create appointment',
            );
          }
        } else {
          hideLoading();
          MySnackBar.showErrorToast(message: 'Invalid response from server');
        }
      } else {
        hideLoading();
        MySnackBar.showErrorToast(message: "No network connection");
      }
    } catch (e, s) {
      kLog(e.toString());
      kLog(s.toString());
      hideLoading();
      MySnackBar.showErrorToast(
        message: "Error creating appointment: ${e.toString()}",
      );
    }
  }

  // Validation
  bool _validateForm() {
    if (selectedStartDate.value == null) {
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

    // Validate 24-hour rule: EndDateTime cannot be more than 24 hours after StartDateTime
    if (selectedStartDate.value != null && selectedEndDate.value != null) {
      final difference = selectedEndDate.value!.difference(selectedStartDate.value!);
      if (difference.inHours > 24) {
        Get.snackbar(
          'Invalid Duration',
          'EndDateTime cannot be more than 24 hours after StartDateTime',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    }

    return true;
  }

  // Helper methods
  String _formatISODateTime(DateTime? date, String? time) {
    if (date == null || time == null) return '';
    // Parse the time slot (format: "10:30 AM" or similar)
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = timeFormat.parse(time);

    // Combine date with parsed time
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    // Return in ISO format: yyyy-MM-ddTHH:mm:ss
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(combinedDateTime);
  }

  String _formatISOEndDate(DateTime? date, String? time, String timeRequired) {
    if (date == null || time == null) return '';

    // Parse start time
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = timeFormat.parse(time);
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    // Parse time required (format: "1h 30m" or "30m" or "1h")
    int additionalMinutes = 0;
    if (timeRequired.isNotEmpty) {
      // Parse hours
      final hoursMatch = RegExp(r'(\d+)\s*h').firstMatch(timeRequired);
      if (hoursMatch != null) {
        additionalMinutes += int.parse(hoursMatch.group(1)!) * 60;
      }

      // Parse minutes
      final minutesMatch = RegExp(r'(\d+)\s*m').firstMatch(timeRequired);
      if (minutesMatch != null) {
        additionalMinutes += int.parse(minutesMatch.group(1)!);
      }

      // If no match found, try to parse as plain number (assuming minutes)
      if (hoursMatch == null && minutesMatch == null) {
        final numberMatch = RegExp(r'(\d+)').firstMatch(timeRequired);
        if (numberMatch != null) {
          additionalMinutes += int.parse(numberMatch.group(1)!);
        }
      }
    }

    // Add time required to start time
    final endDateTime = startDateTime.add(Duration(minutes: additionalMinutes));

    // Return in ISO format: yyyy-MM-ddTHH:mm:ss
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endDateTime);
  }

  String getFormattedSelectedDate() {
    if (selectedStartDate.value == null) return '';
    return DateFormat('MM/dd/yyyy').format(selectedStartDate.value!);
  }

  String getFormattedStartDate() {
    if (selectedStartDate.value != null && selectedTimeSlot.value != null) {
      return '${getFormattedSelectedDate()} ${selectedTimeSlot.value?.startTime ?? ""}';
    }
    return 'Select date and time slot';
  }

  String getFormattedEndDate() {
    if (selectedEndDate.value != null && selectedTimeSlot.value != null) {
      return '${getFormattedSelectedDate()} ${selectedTimeSlot.value?.endTime ?? ""}';
    }
    return 'Select date and time slot';
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

  /// Select date and time with AM/PM support
  Future<void> selectDateTime({
    required BuildContext context,
    required bool isStartDate,
  }) async {
    try {
      // Preselect today's date if no date is selected
      DateTime initialDate = isStartDate
          ? (selectedStartDate.value ?? DateTime.now())
          : (selectedEndDate.value ?? selectedStartDate.value ?? DateTime.now());

      // Ensure the initial date is not before today for start date
      if (isStartDate) {
        final now = DateTime.now();
        if (initialDate.isBefore(DateTime(now.year, now.month, now.day))) {
          initialDate = DateTime.now();
        }
      }

      // Show date picker
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: isStartDate ? DateTime.now() : DateTime(2020),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        // Show time picker after date is selected
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          // Combine date and time
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStartDate) {
            // Update start date
            selectedStartDate.value = selectedDateTime;

            // Auto-update end date to match start date if it's before or null
            if (selectedEndDate.value == null ||
                selectedEndDate.value!.isBefore(selectedDateTime)) {
              selectedEndDate.value = selectedDateTime;
            }

            // Update the selected day for calendar consistency
            selectedDay.value = pickedDate;
            focusedDay.value = pickedDate;
          } else {
            // For end date, ensure it's not before start date
            if (selectedStartDate.value != null &&
                selectedDateTime.isBefore(selectedStartDate.value!)) {
              Get.snackbar(
                'Invalid Date',
                'End date must be same as or after start date',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade400,
                colorText: Colors.white,
              );
              return;
            }

            // Ensure end date is not more than 24 hours after start date
            if (selectedStartDate.value != null) {
              final difference = selectedDateTime.difference(selectedStartDate.value!);
              if (difference.inHours > 24) {
                Get.snackbar(
                  'Invalid Date',
                  'EndDateTime cannot be more than 24 hours after StartDateTime',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade400,
                  colorText: Colors.white,
                );
                return;
              }
            }

            selectedEndDate.value = selectedDateTime;
          }

          // Refresh time slots if start date changed
          if (isStartDate) {
            await loadTimeSlots();
          }
        }
      }
    } catch (e) {
      kLog("Error selecting date time: $e");
    }
  }
}
