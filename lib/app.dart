import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:grocery_manager/repositories/user/user_repository.dart';
import 'package:grocery_manager/screens/login/login_screen.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'blogic/bloc/app/app_bloc.dart';

class MyApp extends StatelessWidget {

  final UserRepository _userRepo = UserRepository();
  late final AuthenticationRepository _authRepo;

  MyApp({Key? key}) : super(key: key){
    _authRepo = AuthenticationRepository(_userRepo);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepo),
        RepositoryProvider.value(value: _userRepo),
        // RepositoryProvider(create: (_) => UserRepository()),
      ],
      child: BlocProvider(
        create: (_) => AppBloc(authenticationRepository: _authRepo, userRepository: _userRepo),
        child: const _AppWidget(),
      ),
    );
  }


}

class _AppWidget extends StatelessWidget {
  const _AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Manager',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: const LoginScreen(),
    );
  }
}
