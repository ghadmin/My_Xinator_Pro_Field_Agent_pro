import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FormValidator extends GetxController {
  // Observables
  var email = ''.obs;
  var password = ''.obs;
  var phoneNumber = ''.obs;

  // Validators
  String? validateRequired(String value, String fieldName) {
    if (value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    } else if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password should be at least 6 characters long';
    }
    return null;
  }

  String? validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Check if phone number matches xxx-xxx-xxxx format
    final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number (xxx-xxx-xxxx)';
    }

    return null;
  }

  // Form submission
  bool submitForm() {
    final emailError = validateEmail(email.value);
    final passwordError = validatePassword(password.value);
    final phoneNumberError = validatePhoneNumber(phoneNumber.value);

    if (emailError != null ||
        passwordError != null ||
        phoneNumberError != null) {
      // Handle form validation errors
      if (kDebugMode) {
        print('Form validation failed!');
      }
      return false;
    }

    // Form is valid
    return true;
  }
}

//      ElevatedButton(
//               onPressed: () {
//                 if (formKey.currentState!.validate()) {
//                     formKey.currentState!.save();
//                     authController.login();
//                     }
//                   },
//               child: Text('Submit'),
//      ),
