import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:quickalert/quickalert.dart';

class DurationDropdown extends StatefulWidget {
  final defaultDuration;
  final Function(String)
      onDurationChanged; // Callback pour récupérer la durée sélectionnée

  DurationDropdown(
      {required this.defaultDuration, required this.onDurationChanged});

  @override
  _DurationDropdownState createState() => _DurationDropdownState();
}

class _DurationDropdownState extends State<DurationDropdown> {
  // final String selectedDuration;
  // final ValueChanged<String> onChanged;

  // const DurationDropdown({required this.selectedDuration, required this.onChanged,});

  @override
  Widget build(BuildContext context) {
    String selectedDuration = widget.defaultDuration;
    final List<String> durationList = [
      'Moins d\'une minute',
      '1 à 2 minutes',
      '2 à 3 minutes',
      '3 à 4 minutes',
      '4 à 5 minutes',
      'Plus de 5 minutes',
    ];

    return DropdownButtonFormField<String>(
      value: selectedDuration,
      onChanged: (String? newValue) {
        setState(() {
          selectedDuration = newValue!;
          widget.onDurationChanged(selectedDuration); // Appel du callback
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Non voté',
          child: Text('Non voté'),
        ),
        ...durationList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      style: TextStyle(fontSize: 16.0, color: Colors.black),
      dropdownColor: Colors.grey,
      icon: Icon(Icons.arrow_drop_down_circle, color: Pallete.gradient2),
      decoration: InputDecoration(
        labelText: "Durée du combat",
        labelStyle: TextStyle(color: Pallete.gradient1),
        prefixIcon: Icon(Icons.schedule_rounded, color: Pallete.gradient1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Pallete.gradient1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Pallete.borderColor),
        ),
      ),
    );
  }
}
