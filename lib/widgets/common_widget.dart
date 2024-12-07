import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildBackgroundCard(
    BuildContext context, double scale, double topOffset) {
  return Positioned(
    top: topOffset,
    child: Container(
      width: MediaQuery.of(context).size.width * scale,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
