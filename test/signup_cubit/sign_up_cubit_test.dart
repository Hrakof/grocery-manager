import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/formz_inputs/inputs.dart';
import 'package:grocery_manager/blogic/bloc/authentication/signup/sign_up_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_up_cubit_test.mocks.dart';

@GenerateMocks([AuthenticationRepository])
void main() {
  group('SignupCubit tests.', () {

    final authRepo = MockAuthenticationRepository();
    late SignUpCubit signupCubit;

    setUp(() {
      reset(authRepo);
      signupCubit = SignUpCubit(authRepo);
    });

    tearDown((){
      signupCubit.close();
    });

    test('State setup.', () {
      expect(signupCubit.state.email , const Email.pure());
      expect(signupCubit.state.password , const Password.pure());
      expect(signupCubit.state.verifyPassword , const VerifyPassword.pure());
      expect(signupCubit.state.displayName , const DisplayName.pure());
      expect(signupCubit.state.status , FormzStatus.pure);
      expect(signupCubit.state.errorMessage , '');
    });

    test('Email changes.', () {
      signupCubit.emailChanged('test@email.com');
      expect(signupCubit.state.email , const Email.dirty(value: 'test@email.com'));
      expect(signupCubit.state.status , FormzStatus.invalid);
    });

    test('Password changes.', () {
      signupCubit.passwordChanged('pw1234');
      expect(signupCubit.state.password , const Password.dirty(value: 'pw1234'));
      expect(signupCubit.state.status , FormzStatus.invalid);
    });

    test('VerifyPassword changes.', () {
      signupCubit.verifyPasswordChanged('pw1234');
      expect(signupCubit.state.verifyPassword , const VerifyPassword.dirty(value: 'pw1234', password: Password.pure()));
      expect(signupCubit.state.status , FormzStatus.invalid);
    });

    test('DisplayName changes.', () {
      signupCubit.displayNameChanged('test user');
      expect(signupCubit.state.displayName , const DisplayName.dirty(value: 'test user'));
      expect(signupCubit.state.status , FormzStatus.invalid);
    });

    test('The form is invalid, when passwords dont match.', () {
      signupCubit.emailChanged('test@email.com');
      signupCubit.passwordChanged('pw1234');
      signupCubit.verifyPasswordChanged('pw123456');
      signupCubit.displayNameChanged('test user');
      expect(signupCubit.state.status , FormzStatus.invalid);
    });

    test('Successful sign up.', () async {
      signupCubit.emailChanged('test@email.com');
      signupCubit.passwordChanged('pw1234');
      signupCubit.verifyPasswordChanged('pw1234');
      signupCubit.displayNameChanged('test user');
      await signupCubit.signUp();

      verify(authRepo.signUp(
        email: 'test@email.com',
        password: 'pw1234',
        displayName: 'test user'
      )).called(1);
      expect(signupCubit.state.status, FormzStatus.submissionSuccess);
    });

    test('Unsuccessful sign up with valid form.', () async {
      reset(authRepo);
      when(authRepo.signUp(email: anyNamed('email'), password: anyNamed('password'), displayName: anyNamed('displayName')))
          .thenAnswer((_) {
        throw SignUpException('message');
      });

      signupCubit.emailChanged('test@email.com');
      signupCubit.passwordChanged('pw1234');
      signupCubit.verifyPasswordChanged('pw1234');
      signupCubit.displayNameChanged('test user');
      await signupCubit.signUp();

      verify(authRepo.signUp(
          email: 'test@email.com',
          password: 'pw1234',
          displayName: 'test user'
      )).called(1);
      expect(signupCubit.state.status, FormzStatus.submissionFailure);
    });

  });
}