import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_olympe/components/resto_card.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/controllers/api_controller.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/shared/layout.dart';

class LobbyList extends StatefulWidget {
  const LobbyList({super.key});

  @override
  State<LobbyList> createState() => _LobbyListState();
}

class _LobbyListState extends State<LobbyList> {
  
  List<LobbyModel> lobbies = List.empty();
  
  @override
  void initState() {
    super.initState();
    unawaited(_fetchLobbies());
  }

  Future<void> _fetchLobbies() async {
    if (mounted)
    {
      final apiResult = await ApiController.getLobbiesOfUser();
      setState(() {
        lobbies = apiResult;
      });
    }
  }

  Widget _lobbyList()
  {
    return Column(
      children: lobbies.map((e) => StyledButton(
        isPrimary: false, 
        onPressed: () {
          Navigator.pushNamed(context, "/lobby", arguments: e.lobbyId);
        }, 
        child: Text(e.name)
        )
      ).toList(),
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return RestoLayout(
      showLogo: false, 
      title: "Mes salons",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: RestoCard(
                child: lobbies.isNotEmpty 
                  ? _lobbyList() 
                  : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: StyledButton(
              isPrimary: false, 
              onPressed: () {
                Navigator.pushNamed(context, "/");
              }, 
              child: const Text("Retour au menu")
            ),
          )
        ],
      )
    );
  }
}