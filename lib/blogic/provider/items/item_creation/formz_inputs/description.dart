import 'package:formz/formz.dart';

enum DescriptionValidationError {
  tooLong,
}

class Description extends FormzInput<String?, DescriptionValidationError> {
  const Description.pure() : super.pure(null);
  const Description.dirty({String? value}) : super.dirty(value);

  @override
  DescriptionValidationError? validator(String? value) {
    if (value == null) {
      return null;
    }
    return value.length <= 150
        ? null
        : DescriptionValidationError.tooLong;
  }
}