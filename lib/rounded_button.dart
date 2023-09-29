import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color color;
  final String text;
  RoundedButton({
    required this.onPressed,required this.color, required this.text
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}