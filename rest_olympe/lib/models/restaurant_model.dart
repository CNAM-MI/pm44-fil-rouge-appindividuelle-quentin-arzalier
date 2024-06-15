class RestaurantModel {
  String name;
  String osmId;
  double lon;
  double lat;
  
  RestaurantModel.fromJson(Map<String, dynamic> json) :
    name = json['name'],
    osmId = json['meta_osm_id'],
    lon = json['meta_geo_point']["lon"],
    lat = json['meta_geo_point']["lat"];  
    
  Map<String, dynamic> toJson() {
    return <String, dynamic>{ 
      'name': name, 
      'meta_osm_id': osmId,
      'meta_geo_point': <String, dynamic>{
        'lon': lon,
        'lat': lat
      }
    };
  }
}