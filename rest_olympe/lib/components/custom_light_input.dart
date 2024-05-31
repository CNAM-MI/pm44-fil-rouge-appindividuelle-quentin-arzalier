import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomLightInput extends StatelessWidget {
  const CustomLightInput({super.key, this.label, this.placeholder, this.onSaved, this.validator, required this.isNumeric});

  final bool isNumeric;
  final String? label;
  final String? placeholder;
  final void Function(String?)? onSaved;

  final String? Function(String?)? validator;

  Widget getLightInputField(BuildContext context)
  {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: TextFormField(
          keyboardType: isNumeric ? TextInputType.number : null,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            hintText: placeholder,
          ),
          validator: validator,
          style: const TextStyle(
            color: Colors.black
          ),
          onSaved: onSaved,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (label == null)
    {
      return getLightInputField(context);
    }
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          getLightInputField(context)
        ],
      );
    }
  }
}