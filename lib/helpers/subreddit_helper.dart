import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class SubredditHelper {
  static Color getSubColor(sub, {defaultColor = Colors.black12, opacity = 0.6}) {
    String subColorHex;
    if (sub.runtimeType != Subreddit) return defaultColor;

    if (sub.data['primary_color'] != null) {
      subColorHex = sub.data['primary_color'];
      subColorHex = subColorHex.replaceAll('#', '');
      var subColorInt = int.parse("0xFF$subColorHex");
      return Color(subColorInt).withOpacity(opacity);
    }
    return defaultColor;
  }
}