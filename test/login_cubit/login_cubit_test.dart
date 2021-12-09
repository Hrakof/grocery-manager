import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/formz_inputs/inputs.dart';
import 'package:grocery_manager/blogic/bloc/authentication/login/login_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([AuthenticationRepository])
void main() {
  group('LoginCubit tests.', () {

    final authRepo = MockAuthenticationRepository();
    late LoginCubit loginCubit;

    setUp(() {
      reset(authRepo);
      loginCubit = LoginCubit(authRepo);
    });

    tearDown((){
      loginCubit.close();
    });

    test('State setup.', () {
      expect(loginCubit.state.email , const Email.pure());
      expect(loginCubit.state.password , const Password.pure());
      expect(loginCubit.state.status , FormzStatus.pure);
      expect(loginCubit.state.errorMessage , '');
    });

    test('Password changes.', () {
      loginCubit.passwordChanged('pw1234');
      expect(loginCubit.state.password , const Password.dirty(value: 'pw1234'));
      expect(loginCubit.state.status , FormzStatus.invalid);
    });

    test('Email changes.', () {
      loginCubit.emailChanged('test@email.com');
      expect(loginCubit.state.email , const Email.dirty(value: 'test@email.com'));
      expect(loginCubit.state.status , FormzStatus.invalid);
    });

    test('Login form filled out and valid.', () {
      loginCubit.emailChanged('test@email.com');
      loginCubit.passwordChanged('pw1234');
      expect(loginCubit.state.email , const Email.dirty(value: 'test@email.com'));
      expect(loginCubit.state.password , const Password.dirty(value: 'pw1234'));
      expect(loginCubit.state.status , FormzStatus.valid);
    });

    test('Login form filled out and valid.', () {
      loginCubit.emailChanged('test@email.com');
      loginCubit.passwordChanged('pw1234');
      expect(loginCubit.state.email , const Email.dirty(value: 'test@email.com'));
      expect(loginCubit.state.password , const Password.dirty(value: 'pw1234'));
      expect(loginCubit.state.status , FormzStatus.valid);
    });

    test('Tried to login with invalid form.', () async {
      loginCubit.emailChanged('email.com');
      loginCubit.passwordChanged('pw34');
      await loginCubit.login();

      expect(loginCubit.state.status , FormzStatus.invalid);
      verifyNever(authRepo.login(email: anyNamed('email'), password: anyNamed('password')));
    });

    test('Successful login.', () async {
      loginCubit.emailChanged('test@email.com');
      loginCubit.passwordChanged('pw1234');
      await loginCubit.login();

      verify(authRepo.login(email: 'test@email.com', password: 'pw1234')).called(1);
      expect(loginCubit.state.status, FormzStatus.submissionSuccess);
    });

    test('Unsuccessful login with valid form.', () async {
      reset(authRepo);
      when(authRepo.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) {
        throw LoginException('message');
      });

      loginCubit.emailChanged('test@email.com');
      loginCubit.passwordChanged('pw1234');
      await loginCubit.login();

      verify(authRepo.login(email: 'test@email.com', password: 'pw1234')).called(1);
      expect(loginCubit.state.status, FormzStatus.submissionFailure);
    });

  });
}