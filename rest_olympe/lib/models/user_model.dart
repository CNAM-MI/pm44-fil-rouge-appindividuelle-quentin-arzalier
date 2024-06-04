class UserModel {
  String username;
  String userId; 
  
  UserModel.fromJson(Map<String, dynamic> json) :
    username = json['username'],
    userId = json['userId'];  
    
  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 'username': username, 'userId': userId };
  }
}