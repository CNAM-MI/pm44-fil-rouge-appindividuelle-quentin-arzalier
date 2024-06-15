import 'package:flutter/material.dart';

// Basé sur une solution apportée ici 
// https://stackoverflow.com/questions/72867116/negative-to-positive-slider-in-flutter

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key, required this.sliderValue, required this.sliderValueChanged, required this.minValue, required this.maxValue});

  final double sliderValue;
  final void Function(double) sliderValueChanged;
  final double minValue;
  final double maxValue;


  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(alignment: AlignmentDirectional.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex:widget.minValue.abs().round(),
                  child: LinearProgressIndicator(
                    value: 1-widget.sliderValue/widget.minValue,
                    color: Colors.grey,
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  flex:widget.maxValue.abs().round(),
                  child: LinearProgressIndicator(
                    value: widget.sliderValue/widget.maxValue,
                    color: Colors.green,
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: widget.sliderValue,
            activeColor: Colors.transparent,
            inactiveColor: Colors.transparent,
            thumbColor: widget.sliderValue == 0 ? Colors.grey : widget.sliderValue > 0 ? Colors.green : Colors.red,
            min: widget.minValue, 
            max: widget.maxValue,
            divisions: (widget.minValue.abs() + widget.maxValue.abs()).round(),
            label: widget.sliderValue.round().toString(),
            onChanged: widget.sliderValueChanged,
          ),
        ],
      ),
    );
  }
}