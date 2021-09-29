import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/routing/route_parser.dart';
import 'package:grocery_manager/screens/home/home_screen.dart';
import 'package:grocery_manager/screens/login/login_screen.dart';

class GroceryRouterDelegate extends RouterDelegate<RouteEnum>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  late StreamSubscription _bolcSub;
  AppState _savedAppState;

  GroceryRouterDelegate({ required AppBloc appBloc}):
        _savedAppState = appBloc.state
  {
    _bolcSub = appBloc.stream.listen((newAppState) {
      //azért runtimeType, mert ha a user adatai megváltoznak
      // AuthenticatedAppState-en belül, attól még nem kell navigálni
      if(newAppState.runtimeType != _savedAppState.runtimeType){
        _savedAppState = newAppState;
        notifyListeners();
      }
    });
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_savedAppState is AuthenticatedAppState) const MaterialPage(
          key: ValueKey('HomePage'),
          child: HomeScreen(),
        ),
        if (_savedAppState is UnAuthenticatedAppState) const MaterialPage(
          key: ValueKey('LoginPage'),
          child: LoginScreen(),
        ),
      ],
      onPopPage: (route, result) {
        print('--- onPopPage1');
        if (!route.didPop(result)) {
          return false;
        }
        print('--- onPopPage2');
        //TODO ???
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RouteEnum configuration) async {
    print('--- setNewRoutePath: $configuration');
    if (configuration == RouteEnum.login){
      //TODO send logout request?
    }
  }

  @override
  void dispose() {
    print("--- Navigator dispose");
    _bolcSub.cancel();
    super.dispose();
  }

}

