import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/routing/route_parser.dart';
import 'package:grocery_manager/screens/authentication/login/login_screen.dart';
import 'package:grocery_manager/screens/households/households_screen.dart';

class GroceryRouterDelegate extends RouterDelegate<RouteEnum>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  late StreamSubscription _bolcSub;
  AppState _savedAppState;
  RouteEnum? _currentConfiguration;
  final AppBloc _appBloc;

  GroceryRouterDelegate({ required AppBloc appBloc}):
        _savedAppState = appBloc.state,
        _appBloc = appBloc
  {
    _bolcSub = appBloc.stream.listen((newAppState) {
      _setCurrentConfiguration();
      //azért runtimeType, mert ha a user adatai megváltoznak
      // AuthenticatedAppState-en belül, attól még nem kell navigálni
      if(newAppState.runtimeType != _savedAppState.runtimeType){
        _savedAppState = newAppState;
        _setCurrentConfiguration();
        notifyListeners();
      }
    });
  }

  @override
  RouteEnum? get currentConfiguration => _currentConfiguration;

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_savedAppState is AuthenticatedAppState) const MaterialPage(
          key: ValueKey('HouseholdsPage'),
          child: HouseholdsScreen(),
        ),
        if (_savedAppState is UnAuthenticatedAppState) const MaterialPage(
          key: ValueKey('LoginPage'),
          child: LoginScreen(),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        notifyListeners();

        return true;
      },
    );
  }

  void _setCurrentConfiguration(){
    if (_savedAppState is AuthenticatedAppState){
      _currentConfiguration = RouteEnum.home;
    }
    else if (_savedAppState is UnAuthenticatedAppState){
      _currentConfiguration = RouteEnum.login;
    }else {
      _currentConfiguration = RouteEnum.unknown;
    }
  }

  @override
  Future<void> setNewRoutePath(RouteEnum configuration) async {
    if(configuration == RouteEnum.login){
      _appBloc.add(const LogoutRequestedEvent());
    }
  }

  @override
  void dispose() {
    _bolcSub.cancel();
    super.dispose();
  }

}

