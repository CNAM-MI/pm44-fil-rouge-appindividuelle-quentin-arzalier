import 'package:flutter/material.dart';
import 'package:rest_olympe/shared/layout.dart';

class JoinLobby extends StatefulWidget {
  const JoinLobby({super.key});

  @override
  State<StatefulWidget> createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby> {
  
  @override
  Widget build(BuildContext context) {
    return RestoLayout(showLogo: false, child: const Placeholder());
  }
}