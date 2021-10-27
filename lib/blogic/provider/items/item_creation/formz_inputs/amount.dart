import 'package:formz/formz.dart';

enum AmountValidationError {
  negative,
  notANumber
}

class Amount extends FormzInput<String?, AmountValidationError> {
  const Amount.pure() : super.pure(null);
  const Amount.dirty({String? value}) : super.dirty(value);

  @override
  AmountValidationError? validator(String? value) {
    if (value == null){
      return null;
    }
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