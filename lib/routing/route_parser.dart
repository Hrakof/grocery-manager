
import 'package:flutter/material.dart';

//Ez helyett lehetne egy osztály, ami több infót tartalmaz. Pl.: az id-jét az oldalon megjelenítendő felhasználónak
enum RouteEnum {
  login,
  home,
  unknown
}

class GroceryRouteInformationParser extends RouteInformationParser<RouteEnum> {
  @override
  Future<RouteEnum> parseRouteInformation(RouteInformation routeInformation) async {

    final uri = Uri.parse(routeInformation.location!);

    // Handle '/login'
    if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'login') {
      return RouteEnum.login;
    }

    // Handle '/home'
    if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'home') {
      return RouteEnum.home;
    }

    // Handle unknown routes
    return RouteEnum.unknown;
  }

  @override
  RouteInformation? restoreRouteInformation(RouteEnum configuration) {
    switch (configuration){

      case RouteEnum.login:
        return const RouteInformation(location: '/login');
      case RouteEnum.home:
        return const RouteInformation(location: '/home');
      case RouteEnum.unknown:
        return const RouteInformation(location: '/404');
    }
  }
}