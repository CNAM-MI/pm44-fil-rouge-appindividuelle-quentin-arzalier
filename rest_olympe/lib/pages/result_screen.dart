import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rest_olympe/components/resto_card.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/controllers/api_controller.dart';
import 'package:rest_olympe/models/lobby_model.dart';
import 'package:rest_olympe/models/result_model.dart';
import 'package:rest_olympe/shared/layout.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.lobbyId});

  final String lobbyId;


  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  
  LobbyModel? lobby;
  List<ResultModel>? results;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchLobby());
  }

  Future<void> _fetchLobby() async {
    if (!mounted)
    {
      return;
    }
    final resL = await ApiController.getLobby(widget.lobbyId);
    final resR = await ApiController.getLobbyResults(widget.lobbyId);

    setState(() {
      lobby = resL;
      results = resR;
    });
  }

  List<TableRow> _getTableData()
  {
    if (lobby == null || results == null) {
      return List.empty();
    }
    List<TableRow> children = List.empty(growable: true);

    children.add(
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Rang", textAlign: TextAlign.left),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nom du restaurant", textAlign: TextAlign.center),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Score", textAlign: TextAlign.right),
          ),
        ]
      )
    );

    var rank = 0;
    var previousScore = 0;
    for (var result in results!) {
      if (previousScore != result.voteCount)
      {
        print("Avant $previousScore Apres ${result.voteCount}");
        rank++;
      }
      children.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(rank.toString(), textAlign: TextAlign.left),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(result.restaurant.name, textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(result.voteCount.toString(), textAlign: TextAlign.right),
            ),
          ]
        )
      );
      previousScore = result.voteCount;
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return RestoLayout(
      showLogo: false,
      title: lobby?.name ?? "-", 
      child: Center(
        child: Column(
          children: [
            RestoCard(
              child: lobby == null 
                ? const CircularProgressIndicator()
                : Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(width: 1, color: Colors.black),
                  children: _getTableData()
              )
            ),
            StyledButton(
              isPrimary: false,
              onPressed: () {
                Navigator.pushNamed(context, "/lobby", arguments: lobby!.lobbyId);
              }, 
              child: const Text("Retour")
            ),
          ],
        ),
      )
    );
  }
}