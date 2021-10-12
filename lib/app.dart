import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grocery_manager/repositories/repositories.dart';
import 'package:grocery_manager/routing/route_parser.dart';
import 'package:grocery_manager/routing/router_delegate.dart';
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
        RepositoryProvider(create: (_) => HouseholdRepository()),
        RepositoryProvider(create: (_) => ItemRepository()),
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

    GroceryRouterDelegate _routerDelegate = GroceryRouterDelegate(
        appBloc: context.read<AppBloc>()
    );

    return MaterialApp.router(
      title: 'Grocery Manager',//TODO l10n
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      routerDelegate: _routerDelegate,
      //backButtonDispatcher: ,
      routeInformationParser: GroceryRouteInformationParser(),
    );
  }
}
