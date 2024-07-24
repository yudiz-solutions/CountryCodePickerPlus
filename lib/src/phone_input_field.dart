import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker_plus/src/country.dart';
import 'package:country_code_picker_plus/src/phone_service.dart';

import 'constants.dart';
import 'text_formatter.dart';

class PhoneNumber {
  final String number;
  final String internationalizedPhoneNumber;
  final Country country;

  PhoneNumber(this.number, this.internationalizedPhoneNumber, this.country);

  @override
  String toString() {
    // TODO: implement toString
    return "\nNumber: $number, InternationalizedPhoneNumber: $internationalizedPhoneNumber, Country: $country";
  }
}

/// A widget for entering an international phone number with a country picker.
class PhoneInputField extends StatefulWidget {
  /// Callback to execute with the normalized phone number, its international format, and the ISO code.
  final Function(bool isValid, PhoneNumber? phoneNumber) onPhoneNumberValidated;

  final InputDecoration? decoration;

  final ValueChanged<Country>? onChanged;

  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PhoneInputField({
    super.key,
    required this.onPhoneNumberValidated,
    this.decoration,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  /// Controller for the text field.
  TextEditingController controller = TextEditingController();

  /// List of countries loaded from assets.
  List<Country> countries = [];

  /// Indicates if the current phone number is valid.
  bool isValid = false;

  /// Stores the last valid phone number.
  String controlNumber = '';

  /// Flag to control validation execution.
  bool performValidation = true;

  @override
  void initState() {
    super.initState();
    countries = countryCodes.map((json) => Country.fromJson(json)).toList();
  }

  /// Handles changes in the text field.
  void onChanged(String content) {
    // Prevent updating text if the new content is longer but the phone number was already valid.
    if (isValid && controller.text.length > controlNumber.length) {
      // setState(() {
      //   controller.text = controlNumber;
      // });
    }

    // Avoid re-validation if the text hasn't changed.
    if (controller.text == controlNumber) {
      setState(() {
        performValidation = false;
      });
    } else {
      setState(() {
        performValidation = true;
      });
    }

    // Perform validation if required.
    if (performValidation) {
      _validatePhoneNumber(controller.text, countries).then((fullNumber) {
        setState(() {
          controlNumber = fullNumber ?? '';
        });
      });
    }

    // Ensure the cursor remains at the end of the input.
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
  }

  /// Validates the phone number against the list of countries.
  Future<String?> _validatePhoneNumber(
      String number, List<Country> countries) async {
    String fullNumber = "";
    if (number.isNotEmpty && countries.isNotEmpty) {
      // Reduce processing by filtering potential countries based on input.
      List<Country> potentialCountries =
          PhoneService.getPotentialCountries(number, countries);

      for (var country in potentialCountries) {
        String localNumber = number.substring(country.dialCode.length - 1);
        isValid =
            await PhoneService.parsePhoneNumber(localNumber, country.code) ??
                false;
        if (isValid) {
          fullNumber = await PhoneService.getNormalizedPhoneNumber(
                  localNumber, country.code) ??
              "";
          widget.onPhoneNumberValidated(
              true, PhoneNumber(localNumber, fullNumber, country));
        } else {
          fullNumber = "";
          widget.onPhoneNumberValidated(false, null);
        }
      }
    }
    return fullNumber;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: widget.focusNode,
        keyboardType: TextInputType.phone,
        controller: controller,
        onChanged: onChanged,
        validator: widget.validator,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          PhoneNumberFormatterWithCountryCode(),
        ],
        decoration: widget.decoration,
        textInputAction: widget.textInputAction);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }
}
