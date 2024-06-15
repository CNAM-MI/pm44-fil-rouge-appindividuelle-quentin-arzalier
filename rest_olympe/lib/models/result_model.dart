import 'package:rest_olympe/models/restaurant_model.dart';

class ResultModel {
  int voteCount;
  RestaurantModel restaurant;

  ResultModel.fromJson(Map<String, dynamic> json) :
    voteCount = json["voteCount"],
    restaurant = RestaurantModel.fromJson(json["restaurant"]);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 
      'voteCount': voteCount, 
      'restaurant': restaurant.toJson()
    };
  }
}