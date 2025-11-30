import 'dart:convert';

class JsonValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter JSON data';
    }
    try {
      jsonDecode(value);
      return null;
    } catch (e) {
      return 'Invalid JSON format';
    }
  }

  static Map<String, dynamic>? tryParse(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
