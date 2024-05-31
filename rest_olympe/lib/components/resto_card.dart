import 'package:flutter/material.dart';

class RestoCard extends StatelessWidget {
  const RestoCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}