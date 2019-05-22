import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class SubredditHelper {
  static Color getSubColor(sub) {
    String subColorHex;
    if (sub.runtimeType != Subreddit) return Colors.black12;

    if (sub.data['primary_color'] != null) {
      subColorHex = sub.data['primary_color'];
      subColorHex = subColorHex.replaceAll('#', '');
      var subColorInt = int.parse("0xFF$subColorHex");
      return Color(subColorInt).withOpacity(0.6);
    }
    return Colors.black12;
  }
}