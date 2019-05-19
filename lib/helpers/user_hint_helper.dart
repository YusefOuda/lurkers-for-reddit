import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHintHelper {
  static showHintsIfNecessary(GlobalKey<ScaffoldState> key) async {
    var sp = await SharedPreferences.getInstance();
    var seenHideHint = sp.getBool("seenHideHint");
    if (seenHideHint != null && seenHideHint) {
      return _showSaveHintIfNecessary(key);
    }

    key.currentState.showSnackBar(SnackBar(
      duration: Duration(minutes: 5),
      content: Text("Did you know? Swipe left on posts to hide them!"),
      action: SnackBarAction(
        label: "Dismiss",
        onPressed: () {
          sp.setBool("seenHideHint", true);
        },
      ),
    ));
  }

  static _showSaveHintIfNecessary(GlobalKey<ScaffoldState> key) async {
    var sp = await SharedPreferences.getInstance();
    var seenSaveHint = sp.getBool("seenSaveHint");
    if (seenSaveHint != null && seenSaveHint) return;

    key.currentState.showSnackBar(SnackBar(
      duration: Duration(minutes: 5),
      content: Text("Did you know? Long press on posts to save/unsave them!"),
      action: SnackBarAction(
        label: "Dismiss",
        onPressed: () {
          sp.setBool("seenSaveHint", true);
        },
      ),
    ));
  }
}
