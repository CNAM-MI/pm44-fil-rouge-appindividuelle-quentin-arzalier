import 'package:rest_olympe/models/user_model.dart';

class LobbyModel {
  
  String name;         
  double? longitude; 
  double? latitude; 
  int voteRadiusKm; 
  bool isClosed; 
  String adminId; 
  UserModel? admin; 

  
  LobbyModel.fromJson(Map<String, dynamic> json) :
    name = json['name'],
    longitude = json['longitude'],
    latitude = json['latitude'],
    voteRadiusKm = json['voteRadiusKm'],
    isClosed = json['isClosed'],
    adminId = json['adminId'],
    admin = UserModel.fromJson(json['admin']);

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