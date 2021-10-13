import 'package:formz/formz.dart';

enum UnitValidationError {
  tooLong,
}

class Unit extends FormzInput<String?, UnitValidationError> {
  const Unit.pure() : super.pure(null);
  const Unit.dirty({String? value}) : super.dirty(value);

  @override
  UnitValidationError? validator(String? value) {
    if (value == null) {
      return null;
    }
    return value.length <= 10
        ? null
        : UnitValidationError.tooLong;
  }
}