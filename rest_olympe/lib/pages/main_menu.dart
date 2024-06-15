import 'package:flutter/material.dart';
import 'package:rest_olympe/components/styled_button.dart';
import 'package:rest_olympe/shared/layout.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {

    return RestoLayout(
      showLogo: true, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: StyledButton(
              isPrimary: true,
              onPressed: () { 
                Navigator.pushNamed(context, "/lobby/create");
              },
              child: const Text("Créer un salon")
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: StyledButton(
              isPrimary: true,
              onPressed: () { 
                Navigator.pushNamed(context, "/lobby/join");
              },
              child: const Text("Rejoindre un salon")
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: StyledButton(
              isPrimary: true,
              onPressed: () { 
                Navigator.pushNamed(context, "/lobby/list");
              },
              child: const Text("Mes salons")
            ),
          ),
        ],
      )
    );
  }
}