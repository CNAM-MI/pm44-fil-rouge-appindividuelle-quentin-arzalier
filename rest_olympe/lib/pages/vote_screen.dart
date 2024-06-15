import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:rest_olympe/components/custom_slider.dart';
import 'package:rest_olympe/components/resto_card.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/controllers/api_controller.dart';
import 'package:rest_olympe/controllers/signalr_controller.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/restaurant_model.dart';
import 'package:rest_olympe/models/user_model.dart';
import 'package:rest_olympe/models/vote_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key, required this.lobbyId});

  final String lobbyId;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {

  final MapController mapController = MapController();

  LobbyModel? lobby;
  UserModel? currentUser;
  List<VoteModel>? currentVotes;
  List<RestaurantModel>? lobbyRestaurants;

  RestaurantModel? openRestaurant;
  int sliderValue = 0;

  int _getRemainingVotes(){
    if (currentVotes == null) {
      return 0;
    }
    var nbPtsUsed = currentVotes!.fold(0, (previousValue, element) => previousValue + element.value.abs());
    return 100 - nbPtsUsed;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_fetchLobbyData());
    SignalRController.hub.on("LobbyClosed", _redirect);
  }

  @override
  void dispose(){
    SignalRController.hub.off("LobbyClosed", method: _redirect);
    super.dispose();
  }

  void _redirect(List<Object?>? arguments) async{
      Navigator.pushNamed(context, "/lobby", arguments: lobby!.lobbyId);
  }

  Future<void> _fetchLobbyData() async {
    if (!mounted)
    {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user"); 
    if (userJson == null && mounted) {
      Navigator.pushNamed(context, "/login");
      return;
    }
    final user = UserModel.fromJson(json.decode(userJson!));

    var resL = await ApiController.getLobby(widget.lobbyId);
    var resV = await ApiController.getLobbyVotesOfUser(widget.lobbyId, user.userId);
    var resR = await ApiController.getLobbyRestaurants(widget.lobbyId);

    setState(() {
      lobby = resL;
      currentUser = user;
      currentVotes = resV;
      lobbyRestaurants = resR;
    });
  }

  List<Marker> _getMarkerData()
  {
    if (lobby == null || currentVotes == null || lobbyRestaurants == null || currentUser == null) {
      return List.empty();
    }
    List<Marker> children = List.empty(growable: true);


    for (var restaurant in lobbyRestaurants!) {
      var votes = currentVotes!.where((element) => element.osmId == restaurant.osmId);
      var nbPtsUsed = votes.firstOrNull?.value ?? 0;
      children.add(
        Marker(
          point: LatLng(restaurant.lat, restaurant.lon),
          child: StyledButton(
            isPrimary: true, 
            onPressed: () {
              setState(() {
                openRestaurant = restaurant;
                sliderValue = nbPtsUsed;
              });
            }, 
          ),
          alignment: Alignment.topCenter
        )
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    if (lobby != null) {
      return SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(lobby!.latitude ?? 0, lobby!.longitude ?? 0),
                initialZoom: 16,
                minZoom: 14,
                maxZoom: 18
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.restolympe',
                  // Plenty of other options available!
                ),
                MarkerLayer(
                  markers: _getMarkerData(),
                )
              ],
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StyledButton(
                    isPrimary: false,
                    onPressed: () {
                      Navigator.pushNamed(context, "/lobby", arguments: lobby!.lobbyId);
                    }, 
                    child: const Text("Retour")
                  ),
                  RestoCard(
                    child: Text("Remaining votes : ${_getRemainingVotes()}.",
                    textAlign: TextAlign.center,),
                  ),
                ],
              ),
            ),
            if (openRestaurant != null) Container(
              color: const Color.fromARGB(114, 0, 0, 0),
              child: Center(
                child: lobby == null 
                  ? const CircularProgressIndicator()
                  : Center(
                    child: RestoCard(
                      child: Column(
                        children: [
                          Text(openRestaurant!.name),
                          CustomSlider(
                            minValue: -100,
                            maxValue: 100,
                            sliderValue: sliderValue.toDouble(),
                            sliderValueChanged: (double newValue){
                              setState(() {
                                final intValue = newValue.round();
                                var votes = currentVotes!.where((element) => element.osmId == openRestaurant!.osmId);
                                var nbPtsUsed = votes.firstOrNull?.value.abs() ?? 0;
                                if (_getRemainingVotes() - (intValue.abs() - nbPtsUsed)>= 0 || intValue.abs() <= nbPtsUsed)
                                {
                                  sliderValue = intValue;
                                }
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StyledButton(
                                isPrimary: false, 
                                onPressed: () {
                                  setState(() {
                                    openRestaurant = null;
                                  });
                                },
                                child: const Text("Annuler"),
                              ),
                              StyledButton(
                                isPrimary: false, 
                                onPressed: () async {
                                  final newVote = await ApiController.createOrUpdateVote(lobby!.lobbyId, openRestaurant!.osmId, sliderValue);
                                  if (newVote != null)
                                  {
                                    final toReplace = currentVotes!.indexWhere((element) => element.osmId == newVote.osmId,);
                                    print(newVote.osmId);
                                    setState(() {
                                      if (toReplace != -1)
                                      {
                                        currentVotes![toReplace] = newVote;
                                      }
                                      else {
                                        currentVotes!.add(newVote);
                                      }
                                      openRestaurant = null;
                                    });
                                  }
                                },
                                child: const Text("Valider vote"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
              ),
            ),
          ]
        ),
      );
    } else {
      return const Center(child: SizedBox(
        width: 200,
        height: 200,
        child: CircularProgressIndicator()));
    }
  }
}