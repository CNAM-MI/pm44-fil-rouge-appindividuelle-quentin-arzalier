class UserModel {
  String username;
  String userId; 
  
  UserModel.fromJson(Map<String, dynamic> json) :
    username = json['userName'],
    userId = json['userId'];  
    
  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 'userName': username, 'userId': userId };
  }
}