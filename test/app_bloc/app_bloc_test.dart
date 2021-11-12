import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'app_bloc_test.mocks.dart';

@GenerateMocks([AuthenticationRepository, UserRepository])
void main() {
  group('AppBloc tests.', () {

    final userRepo = MockUserRepository();
    final authRepo = MockAuthenticationRepository();

    const user = User(displayName: 'user name', id: 'user_id', email: 'user@email.com');

    late AppBloc appBloc;

    setUp(() async {
      // AuthenticationRepository
      reset(authRepo);
      when(authRepo.userChangedStream)
          .thenAnswer((_) => const Stream.empty());

      // UserRepository
      reset(userRepo);
      when(userRepo.getUserStream(user.id))
          .thenAnswer((_) async* {
        yield user;
      });

      appBloc = AppBloc(
          authenticationRepository: authRepo,
          userRepository: userRepo
      );

      //wait for streams to send initial data
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('State setup.', () async {
      expect(appBloc.state, const TypeMatcher<UnAuthenticatedAppState>());
    });

    test('User logs in.', () async {
      // AuthenticationRepository
      reset(authRepo);
      when(authRepo.userChangedStream)
          .thenAnswer((_) async* {
        yield '';
        await Future.delayed(const Duration(milliseconds: 100));
        yield user.id;
      });
      appBloc = AppBloc(
          authenticationRepository: authRepo,
          userRepository: userRepo
      );
      await Future.delayed(const Duration(milliseconds: 50));
      expect(appBloc.state, const TypeMatcher<UnAuthenticatedAppState>());
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appBloc.state, const TypeMatcher<AuthenticatedAppState>());
      final currentState = appBloc.state as AuthenticatedAppState;
      expect(currentState.currentUser, user);

    });

    test('User logs out.', () async {
      // AuthenticationRepository
      reset(authRepo);
      when(authRepo.userChangedStream)
          .thenAnswer((_) async* {
        yield user.id;
      });
      appBloc = AppBloc(
          authenticationRepository: authRepo,
          userRepository: userRepo
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(appBloc.state, const TypeMatcher<AuthenticatedAppState>());

      appBloc.add(const LogoutRequestedEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      verify(authRepo.logout()).called(1);
    });

  });
}