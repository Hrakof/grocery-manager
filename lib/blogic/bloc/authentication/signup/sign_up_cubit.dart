import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import '../formz_inputs/inputs.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository) : super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String newValue) {
    final email = Email.dirty(value: newValue);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password, state.verifyPassword, state.displayName]),
    ));
  }

  void passwordChanged(String newValue) {
    final password = Password.dirty(value: newValue);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password, state.verifyPassword, state.displayName]),
    ));
  }

  void verifyPasswordChanged(String newValue) {
    final verifyPassword = VerifyPassword.dirty(password: state.password, value: newValue);
    emit(state.copyWith(
      verifyPassword: verifyPassword,
      status: Formz.validate([state.email, state.password, verifyPassword, state.displayName]),
    ));
  }

  void displayNameChanged(String newValue) {
    final displayName = DisplayName.dirty(value: newValue);
    emit(state.copyWith(
      displayName: displayName,
      status: Formz.validate([state.email, state.password, state.verifyPassword, displayName]),
    ));
  }

  Future<void> signUp() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
        displayName: state.displayName.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    }on SignUpException catch(e){
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
