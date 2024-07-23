import 'package:flutter/services.dart';
import 'package:country_code_picker_plus/src/constants.dart';

import 'country.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;

    String newText = newValue.text;
    String formattedText = '';

    if (newTextLength >= 4) {
      formattedText = '(${newText.substring(0, 3)}) ';
      if (newTextLength >= 7) {
        formattedText += '${newText.substring(3, 6)}-';
        formattedText += newText.substring(6, newTextLength);
      } else {
        formattedText += newText.substring(3, newTextLength);
      }
    } else {
      formattedText = newText;
    }

    selectionIndex = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class PhoneNumberFormatterWithCountryCode extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // If the text is empty, return the new value
    if (text.isEmpty) {
      return newValue;
    }

    // Determine the country code length dynamically
    final countryCodeLength = getCountryCodeLength(text);

    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int nonDigitCount = 0;

    for (int i = 0; i < text.length; i++) {
      if (i == countryCodeLength) {
        newText.write(' ');
        nonDigitCount++;
      } else if (i == countryCodeLength + 3 || i == countryCodeLength + 7) {
        newText.write('-');
        nonDigitCount++;
      }
      newText.write(text[i]);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection:
          TextSelection.collapsed(offset: selectionIndex + nonDigitCount),
    );
  }

  int getCountryCodeLength(String text) {
    // Iterate over the keys in the countryCodes map
    for (var code in countryCodes) {
      Country country = Country.fromJson(code);
      String dialCode = country.dialCode.replaceAll("+", "");
      // If the text starts with the country code, return the length of the code
      if (text.startsWith(dialCode)) {
        return dialCode.length;
      }
    }
    // Default to 1 if no country code is found
    return 1;
  }
}
