import 'package:formz/formz.dart';
import 'package:projekt/blogic/bloc/authentication/formz_inputs/password.dart';

enum PasswordVerificationError { doesNotMatch }

class VerifyPassword extends FormzInput<String, PasswordVerificationError> {
  const VerifyPassword.pure() : password = null, super.pure('');
  const VerifyPassword.dirty({required this.password, String value = ''}) : super.dirty(value);

  final Password? password;

  @override
  PasswordVerificationError? validator(String? value) {
    if(value != password?.value){
      return PasswordVerificationError.doesNotMatch;
    }
    return null;
  }
}