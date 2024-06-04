import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_olympe/ini/http_initialize.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {
  static final dio = Dio(BaseOptions(
    validateStatus: (status) {
      return status! < 500;
    },
    baseUrl: baseServerUrl
  ));

  static Future<UserModel?> createUser(String username) async
  {
    final response = await dio.post("/user", 
      data: FormData.fromMap({
        'username': username
      })
    );
    

    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data);
    }
    else {
      print("CreateUser responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return null;
  }

  static Future<LobbyModel?> createLobby(String lobbyName, int voteRadiusKm) async
  {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true);

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user"); 
    if (userJson == null) {
      throw ArgumentError.notNull("user");
    }
    final user = UserModel.fromJson(json.decode(userJson));

    final response = await dio.post("/lobby", 
      data: FormData.fromMap({
        'adminId': user.userId,
        'lobbyName': lobbyName,
        'longitude': position.longitude,
        'latitude': position.latitude,
        'voteRadiusKm': voteRadiusKm,
      })
    );

    if (response.statusCode == 201) {
      return LobbyModel.fromJson(response.data);
    }
    else {
      print("createLobby responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return null;
  }
}