import 'package:flutter/material.dart';
import 'package:rest_olympe/pages/create_lobby.dart';
import 'package:rest_olympe/pages/join_lobby.dart';
import 'package:rest_olympe/pages/lobby_list.dart';
import 'package:rest_olympe/pages/login_screen.dart';
import 'package:rest_olympe/pages/main_menu.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      
        case '/': 
          return MaterialPageRoute(builder: (context) => const MainMenu());
        // case '/login': 
        //   if (args is String)
        //   {
        //     return MaterialPageRoute(builder: (context) => const LoginScreen());
        //   }
        // return _errorRoute();
        case '/lobby': 
          return MaterialPageRoute(builder: (context) => const CreateLobby());
        case '/lobby/create': 
          return MaterialPageRoute(builder: (context) => const CreateLobby());
        case '/lobby/join': 
          return MaterialPageRoute(builder: (context) => const JoinLobby());
        case '/lobby/list': 
          return MaterialPageRoute(builder: (context) => const LobbyList());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Placeholder();
    });
  }
}