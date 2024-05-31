import 'package:flutter/material.dart';
import 'package:rest_olympe/pages/create_lobby.dart';
import 'package:rest_olympe/pages/join_lobby.dart';
import 'package:rest_olympe/pages/login_screen.dart';
import 'package:rest_olympe/pages/main_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light, 
          primary: Color(0xff845f4d),
          onPrimary: Color(0xfff4e8d6),
          secondary: Color(0xfff4e8d6), 
          onSecondary: Color(0xff845f4d),
          background: Color(0xfff4e8d6),
          onBackground: Color(0xff845f4d), 
          error: Colors.red,
          onError: Colors.white, 
          surface: Color(0xff845f4d),
          onSurface: Color(0xfff4e8d6),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/' : (context) => const MainMenu(),
        '/login' : (context) => const LoginScreen(),
        '/lobby/create' : (context) => const CreateLobby(),
        '/lobby/join' : (context) => const JoinLobby(),
      },
      initialRoute: "/login",
    );
  }
}