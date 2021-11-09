import 'package:flutter/material.dart';

class CustomGradientButton extends StatelessWidget {
  final String caption;
  final Function onPressed;

  const CustomGradientButton({
    this.caption,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: this.onPressed,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.green[400],
              Colors.lightBlueAccent,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Text(
              caption,
              style: Theme.of(context).textTheme.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
