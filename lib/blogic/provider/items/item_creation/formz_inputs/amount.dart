import 'package:formz/formz.dart';

enum AmountValidationError {
  negative,
  notANumber
}

class Amount extends FormzInput<String, AmountValidationError> {
  const Amount.pure() : super.pure('');
  const Amount.dirty({String value = ''}) : super.dirty(value);

  @override
  AmountValidationError? validator(String value) {
    double number = 0.0;
    try{
      number = double.parse(value);
    } on FormatException {
      return AmountValidationError.notANumber;
    }

    return number >= 0.0
        ? null
        : AmountValidationError.negative;
  }
}