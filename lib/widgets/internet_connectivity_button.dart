import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InternetConnectivityButton extends StatefulWidget {
  final void Function() onPressed;

  const InternetConnectivityButton({super.key, required this.onPressed});

  @override
  State<InternetConnectivityButton> createState() =>
      _InternetConnectivityButtonState();
}

class _InternetConnectivityButtonState
    extends State<InternetConnectivityButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Kindly check your internet connection ᯤ',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 10),
          CupertinoButton(
            onPressed: widget.onPressed,
            color: Colors.amber,
            padding: const EdgeInsets.all(15),
            child: const Text(
              'Retry',
              style: TextStyle(
                letterSpacing: 2,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
