import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/formz_inputs/inputs.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(const LoginState());

  final AuthenticationRepository _authRepo;

  void emailChanged(String newValue) {
    final email = Email.dirty(value: newValue);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String newValue) {
    final password = Password.dirty(value: newValue);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }

  Future<void> login() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authRepo.login(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    }on LoginException catch(e){
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: e.message,
      ));
    }
    on Exception{
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: 'Unkown error',
      ));
    }
  }
}
