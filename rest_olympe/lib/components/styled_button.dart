import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({super.key, required this.isPrimary, required this.onPressed, required this.child});
  
  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,  
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
        foregroundColor: isPrimary 
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSecondary,
        minimumSize: const Size(0 , 45) 
      ), 
      child: child
    );
  }
}