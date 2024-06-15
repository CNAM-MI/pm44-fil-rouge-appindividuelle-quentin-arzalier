class VoteModel {
  String userId; 
  String lobbyId; 
  String osmId;
  int value; 
  
  VoteModel.fromJson(Map<String, dynamic> json) :
    userId = json['userId'],
    lobbyId = json['lobbyId'],
    osmId = json['osmId'].toString(),
    value = json['value'];  
    
  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 
      'userId': userId, 
      'lobbyId': lobbyId, 
      'osmId': osmId, 
      'value': value, 
    };
  }
}