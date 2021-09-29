import 'package:formz/formz.dart';

enum DisplayNameValidationError { invalid }

class DisplayName extends FormzInput<String, DisplayNameValidationError> {
  const DisplayName.pure() : super.pure('');
  const DisplayName.dirty({String value = ''}) : super.dirty(value);


  @override
  DisplayNameValidationError? validator(String? value) {
    if (value == null) {
      return DisplayNameValidationError.invalid;
    }
    return value.length >= 3
        ? null
        : DisplayNameValidationError.invalid;
  }
}