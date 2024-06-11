import 'package:rest_olympe/models/user_model.dart';

class LobbyModel {
  
  String lobbyId;
  String name;         
  double? longitude; 
  double? latitude; 
  int voteRadiusKm; 
  bool isClosed; 
  String adminId; 
  UserModel? admin; 

  
  LobbyModel.fromJson(Map<String, dynamic> json) :
    name = json['name'],
    lobbyId = json['lobbyId'],
    longitude = json['longitude']?.toDouble(),
    latitude = json['latitude']?.toDouble(),
    voteRadiusKm = json['voteRadiusKm'],
    isClosed = json['isClosed'],
    adminId = json['adminId'],
    admin = json['admin'] != null ? UserModel.fromJson(json['admin']) : null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
      'voteRadiusKm': voteRadiusKm,
      'isClosed': isClosed,
      'adminId': adminId,
      'admin': admin?.toJson(),
    };
  }
}