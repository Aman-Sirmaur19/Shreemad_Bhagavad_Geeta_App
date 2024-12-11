import 'dart:math';

import 'package:flutter/material.dart';

class EmptyBookmarks extends StatelessWidget {
  final String msg;

  const EmptyBookmarks({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/morpankh.png', width: 50),
          Text(
            ' $msg ',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: Image.asset('assets/images/morpankh.png', width: 50)),
        ],
      ),
    );
  }
}
