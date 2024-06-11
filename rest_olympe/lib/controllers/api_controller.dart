import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_olympe/util/http_initialize.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  static Future<LobbyModel?> getLobby(String lobbyId) async
  {
    print(lobbyId);
    final response = await dio.get("/lobby/$lobbyId");
    
    if (response.statusCode == 200) {
      return LobbyModel.fromJson(response.data['lobby']);
    }
    else {
      print("getLobby responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return null;
  }

  static Future<bool> joinLobby(String lobbyId) async
  {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user"); 
    if (userJson == null) {
      throw ArgumentError.notNull("user");
    }
    final user = UserModel.fromJson(json.decode(userJson));

    final response = await dio.post("/lobby/$lobbyId/join", 
      data: FormData.fromMap({
        'userId': user.userId
      })
    );
    

    if (response.statusCode == 204) {
      return true;
    }
    else {
      print("joinLobby responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return false;
  }

  static Future<List<LobbyModel>> getLobbiesOfUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user"); 
    if (userJson == null) {
      throw ArgumentError.notNull("user");
    }
    final user = UserModel.fromJson(json.decode(userJson));

    final response = await dio.get("/user/${user.userId}/lobby");

    if (response.statusCode == 200)
    {
      return List.from(response.data["lobbies"].map((e) => LobbyModel.fromJson(e)));
    }
    else {
      print("getLobbiesOfUser responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return List.empty();
  }

}