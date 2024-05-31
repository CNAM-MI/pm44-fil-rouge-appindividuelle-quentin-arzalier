import 'package:flutter/material.dart';

class RestoLayout extends StatelessWidget {
  const RestoLayout({super.key, required this.showLogo, this.title, required this.child});

  final String? title;
  final bool showLogo;
  final Widget child;

  @override
  Widget build(BuildContext context) { 
    List<Widget> columnChildren = List.empty(growable: true);
    if (showLogo)
    {
      columnChildren.add(const Image(image: AssetImage("assets/images/logo.png")));
    }
    if (!showLogo && title != null)
    {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              height: 1
            ),
          ),
        )
      );
    }

    columnChildren.add(Expanded(child: child));

    return SafeArea(child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover
            )
          ), 
          child: Center(
            child: FractionallySizedBox(
            widthFactor: 0.75,
            heightFactor: 0.75,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: columnChildren,
              )
            )
          ),
        ),
      )
    );
  } 
}