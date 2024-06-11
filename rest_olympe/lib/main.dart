import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rest_olympe/util/http_initialize.dart';
import 'package:rest_olympe/util/notification_setup.dart';
import 'package:rest_olympe/util/route_generator.dart';
import 'package:rest_olympe/util/signalr_connection.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    if (kDebugMode) {
      HttpOverrides.global = MyHttpOverrides();
    }
    await initNotifications();
    initSignalRHub();
    await requestNotifPermissions();

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
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: "/login",
    );
  }
}