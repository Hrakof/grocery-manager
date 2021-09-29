part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.verifyPassword = const VerifyPassword.pure(),
    this.displayName = const DisplayName.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage = '',
  });

  final Email email;
  final Password password;
  final VerifyPassword verifyPassword;
  final DisplayName displayName;
  final FormzStatus status;
  final String errorMessage;

  @override
  List<Object> get props => [email, password, verifyPassword, displayName, status, errorMessage];

  SignUpState copyWith({
    Email? email,
    Password? password,
    VerifyPassword? verifyPassword,
    DisplayName? displayName,
    FormzStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      verifyPassword: verifyPassword ?? this.verifyPassword,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
