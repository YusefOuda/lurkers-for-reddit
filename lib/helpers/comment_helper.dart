import 'package:flutter/material.dart';

class CommentHelper {
  static getBorderSideColor(depth) {
    var colors = [
      Colors.white,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.yellow,
      Colors.amber,
      Colors.cyan,
      Colors.red
    ];
    return colors[depth % colors.length];
  }
}