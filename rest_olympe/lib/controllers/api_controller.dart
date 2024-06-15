import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_olympe/models/restaurant_model.dart';
import 'package:rest_olympe/models/result_model.dart';
import 'package:rest_olympe/models/vote_model.dart';
import 'package:rest_olympe/util/http_initialize.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {

  static Future<UserModel> _getUserFromPrefsAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user"); 
    if (userJson == null) {
      throw ArgumentError.notNull("user");
    }
    return UserModel.fromJson(json.decode(userJson));
  }

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

    final user = await _getUserFromPrefsAsync();

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
    final user = await _getUserFromPrefsAsync();

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
    final user = await _getUserFromPrefsAsync();

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

  static Future<List<VoteModel>?> getLobbyVotes(String lobbyId) async {

    final response = await dio.get("/lobby/$lobbyId/vote");

    if (response.statusCode == 200)
    {
      return List.from(response.data["votes"].map((e) => VoteModel.fromJson(e)));
    }
    else {
      print("getLobbyVotes responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return List.empty();
  }

  static Future<List<UserModel>?> getLobbyUsers(String lobbyId) async {

    final response = await dio.get("/lobby/$lobbyId/user");

    if (response.statusCode == 200)
    {
      return List.from(response.data["users"].map((e) => UserModel.fromJson(e)));
    }
    else {
      print("getLobbyUsers responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return List.empty();
  }

  static Future<List<VoteModel>?> getLobbyVotesOfUser(String lobbyId, String userId) async {

    final response = await dio.get("/lobby/$lobbyId/user/$userId/vote");

    if (response.statusCode == 200)
    {
      return List.from(response.data["votes"].map((e) => VoteModel.fromJson(e)));
    }
    else {
      print("getLobbyVotesOfUser responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return List.empty();
  }

  static Future<List<RestaurantModel>?> getLobbyRestaurants(String lobbyId) async {
    
    final response = await dio.get("/lobby/$lobbyId/restaurant");

    if (response.statusCode == 200)
    {
      return List.from(response.data["results"].map((e) => RestaurantModel.fromJson(e)));
    }
    else {
      print("getLobbyRestaurants responded ${response.statusCode}");
      print("Message : ${response.data}");
    }
    return List.empty();
  }

  static Future<VoteModel?> createOrUpdateVote(String lobbyId, String osmId, int value) async {
    
    final user = await _getUserFromPrefsAsync();

    final response = await dio.post("/lobby/$lobbyId/vote", 
      data: FormData.fromMap({
        "userId": user.userId,
        "osmId": osmId,
        "voteValue": value
      })
    );

    
    if (response.statusCode == 201)
    {
      return VoteModel.fromJson(response.data);
    }
    else if (response.statusCode == 409) // En cas de conflit, on tente de mettre à jour.
    {
      final responsePatch = await dio.patch("/lobby/$lobbyId/user/${user.userId}/vote/$osmId", 
        data: FormData.fromMap({
          "newValue": value
        })
      );
      if (responsePatch.statusCode == 200)
      {
        return VoteModel.fromJson(responsePatch.data);
      }
      else {
        print("createOrUpdateVote responded ${responsePatch.statusCode}");
        print("Message : ${responsePatch.data}");
      }
    }
    else {
      print("createOrUpdateVote responded ${response.statusCode}");
      print("Message : ${response.data}");
    }

    return null;
  }

  static Future<bool> closeLobby(String lobbyId) async
  {
    final user = await _getUserFromPrefsAsync();

    final response = await dio.post("/lobby/$lobbyId/close",
    data: FormData.fromMap({
      'adminId': user.userId
    }));

    if (response.statusCode == 204)
    {
      return true;
    }
    else {
      print("createOrUpdateVote responded ${response.statusCode}");
      print("Message : ${response.data}");
      return false;
    }
  }

  static Future<List<ResultModel>?> getLobbyResults(String lobbyId) async {
    
    final response = await dio.get("/lobby/$lobbyId/result");

    if (response.statusCode == 200)
    {
      return List.from(response.data["results"].map((e) => ResultModel.fromJson(e)));
    }
    else {
      print("createOrUpdateVote responded ${response.statusCode}");
      print("Message : ${response.data}");
      return null;
    }
  }
}