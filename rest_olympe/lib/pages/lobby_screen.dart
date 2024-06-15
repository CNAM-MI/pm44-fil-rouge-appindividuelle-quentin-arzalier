import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rest_olympe/components/resto_card.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/controllers/api_controller.dart';
import 'package:rest_olympe/controllers/signalr_controller.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/user_model.dart';
import 'package:rest_olympe/models/vote_model.dart';
import 'package:rest_olympe/shared/layout.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, required this.lobbyId});

  final String lobbyId;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {

  LobbyModel? lobby;
  List<UserModel>? lobbyUsers;
  List<VoteModel>? lobbyVotes;
  UserModel? currentUser;
  bool qrCodeVisible = false;
  bool endScreenVisible = false;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchLobby());
    SignalRController.hub.on("NewLobbyMember", _updateLobby);
    SignalRController.hub.on("VotesChanged", _updateLobby);
    SignalRController.hub.on("LobbyClosed", _updateLobby);
  }

  @override
  void dispose(){
    SignalRController.hub.off("NewLobbyMember", method: _updateLobby);
    SignalRController.hub.off("VotesChanged", method: _updateLobby);
    SignalRController.hub.off("LobbyClosed", method: _updateLobby);
    super.dispose();
  }

  void _updateLobby(List<Object?>? arguments) async{
    await _fetchLobby();
    setState(() {});
  }
  

  Future<void> _fetchLobby() async {
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
  
    final resL = await ApiController.getLobby(widget.lobbyId);
    final resU = await ApiController.getLobbyUsers(widget.lobbyId);
    final resV = await ApiController.getLobbyVotes(widget.lobbyId);

    setState(() {
      lobby = resL;
      lobbyUsers = resU;
      lobbyVotes = resV;
      currentUser = user;
    });
  }

  List<TableRow> _getTableData()
  {
    if (lobby == null || lobbyUsers == null || lobbyVotes == null || currentUser == null) {
      return List.empty();
    }
    List<TableRow> children = List.empty(growable: true);

    children.add(
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nom d'utilisateur", textAlign: TextAlign.left),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Points dépensés", textAlign: TextAlign.right),
          ),
        ]
      )
    );

    for (var user in lobbyUsers!) {
      var userVotes = lobbyVotes!.where((element) => element.userId == user.userId);
      var nbPtsUsed = userVotes.fold(0, (previousValue, element) => previousValue + element.value.abs());
      var bold = user.userId == currentUser!.userId;
      var isAdmin = user.userId == lobby!.adminId;
      var green = nbPtsUsed == 100;
      
      children.add(
        TableRow(
          decoration: isAdmin ? const BoxDecoration(color: Colors.red) : null,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user.username, 
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$nbPtsUsed pts", 
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: green ? Colors.green : null
                ),
              ),
            )
          ]
        )
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RestoLayout(
          showLogo: false,
          title: lobby?.name ?? "-", 
          child: Column(
            children: [
              RestoCard(
                child: lobby == null 
                  ? const CircularProgressIndicator()
                  : Table(
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth()
                    },
                    border: TableBorder.all(width: 1, color: Colors.black),
                    children: _getTableData()
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StyledButton(
                    isPrimary: false, 
                    onPressed: (){
                      Navigator.pushNamed(context, "/");
                    }, 
                    child: const Text("Retour au menu")
                  ),
                  
                  if (lobby != null && lobby!.isClosed) StyledButton(
                    isPrimary: true, 
                    onPressed: (){
                      Navigator.pushNamed(context, "/lobby/results", arguments: lobby!.lobbyId);
                    },
                    child: const Text("Voir résultats"),
                  ) 
                  else if (lobby != null) StyledButton(
                    isPrimary: true, 
                    onPressed: (){
                      if (lobby != null) {
                        Navigator.pushNamed(context, "/lobby/vote", arguments: lobby!.lobbyId);
                      }
                    }, 
                    child: const Text("Voter")
                  ),
                ],
              ),
              if (lobby != null && currentUser != null && !lobby!.isClosed && lobby!.adminId == currentUser!.userId) StyledButton(
                isPrimary: true, 
                onPressed: (){
                  setState(() {
                    endScreenVisible = true;
                  });
                },
                child: const Text("Mettre fin au vote"),
              ),
            ],
          ),
        ),
        if (lobby != null && !lobby!.isClosed) SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 5,
                left: 5,
                child: StyledButton(
                  isPrimary: false, 
                  onPressed: (){
                    Share.share(
                      "Rejoins mon salon RestOlympe \"${lobby!.name}\" à l'aide du code suivant: ${lobby!.lobbyId.replaceAll("-", "")}",
                      subject: "Invitation à un salon RestOlympe.");
                  }, 
                  child: const Icon(Icons.share)
                ),
              ),
              if (qrCodeVisible) Container(
                color: const Color.fromARGB(114, 0, 0, 0),
                child: Center(
                  child: Container(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: lobby == null 
                      ? const CircularProgressIndicator()
                      : SizedBox(
                        width: 320,
                        height: 320,
                        child: Center(
                          child: QrImageView(
                            data: lobby!.lobbyId,
                            version: QrVersions.auto,
                            size: 300,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Theme.of(context).colorScheme.primary
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        ),
                      ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: StyledButton(
                  isPrimary: qrCodeVisible, 
                  onPressed: (){
                    setState(() {
                      qrCodeVisible = !qrCodeVisible;
                    });
                  }, 
                  child: const Icon(Icons.qr_code)
                ),
              ),
              if (endScreenVisible) Container(
                color: const Color.fromARGB(114, 0, 0, 0),
                child: Center(
                  child: lobby == null 
                    ? const CircularProgressIndicator()
                    : Center(
                      child: RestoCard(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Voulez vous vraiment mettre fin au vote? Cette décision est irréversible.",
                                textAlign: TextAlign.center,  
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                StyledButton(
                                  isPrimary: false, 
                                  onPressed: (){
                                    setState(() {
                                      endScreenVisible = false;
                                    });
                                  },
                                  child: const Text("Annuler"),
                                ),
                                StyledButton(
                                  isPrimary: false, 
                                  onPressed: () async {
                                    final changeWorked = await ApiController.closeLobby(lobby!.lobbyId);
                                    if (changeWorked)
                                    {
                                      setState(() {
                                        lobby!.isClosed = true;
                                        endScreenVisible = false;
                                      });
                                    }
                                    else {
                                      print("Error while closing lobby ${lobby!.lobbyId}.");
                                    }
                                  },
                                  child: const Text("Terminer le vote"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                ),
              ),
            ],
          )
        )
      ],
    );
  }
}